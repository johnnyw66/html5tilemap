-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not TileMap then

-- New Single Layer version of TileMap - Optimised 

TileMap					=	{}
TileMap.className		=	'TileMap'
TileMap.debug			=	false

local	consoleFix		=	@FIXCONSOLE@			-- set to true to fudge for console errors

local	tileSize		=	0
local	posmatrix		=	Matrix44.Create()
local	uvData			=	nil
local	posData			=	nil
local 	zeroPosTable	=	nil
local	mapX			=	-1
local	mapY			=	-1
local	mapuvCol 		= 	Vector4.Create(1,1,1,1)
local 	fineX,fineY
local 	mappixx,mappixy

local	mapTilesDown,mapTilesAcrosss,mapPixelWidth,mapPixelHeight	
local	screenDim,maxPixWidth,maxPixHeight
local	dimx2,dimy2
local	dimx2,dimy2
local	mapdata	

local	hashits		=	false
local	collisioninfo	=	{}
local	collideIndex	=	256

	
	
	
	local function round(num)
	    local floor = math.floor(num)
	    local ceiling = math.ceil(num)
	    if (num - floor) >= 0 then
	        return ceiling
	    end
	    return floor
	end

	local function GetMapIndex(x,y)
		-- TODO REMOVE THESE ASSERTS ON RELEASE!
		assert(mapdata[y],'SingletonTileMap:GetMapIndex(on y) NIL'..(x or 'nil')..','..(y or 'nil'))
		assert(mapdata[y][x],'SingletonTileMap:GetMapIndex(on x) NIL'..(x or 'nil')..','..(y or 'nil'))

		return mapdata[y][x]
	end

	local function CreateUVsQuadTable(textureName,tSize,anticlk)
		
		local 	tid				=	Texture.Find(textureName)
		assert(tid,'SingletonTileMap:CreateUVsQuadTable:CAN NOT LOAD '..(textureName or 'NIL TEXTURENAME'))
		local	tilesetWidth 	= 	tid:GetWidth()
		local 	tilesetHeight 	= 	tid:GetHeight()

		local	tilesAcross		=	math.floor(tilesetWidth/tSize)
		local	tilesDown		=	math.floor(tilesetHeight/tSize)
		

		local	blocks	=	{}
		
		-- Tiles start from index 0

		for frame = 0,tilesAcross*tilesDown - 1 do

			local qw			=	1/tilesAcross
			local qh			=	1/tilesDown
			local x				=	(frame % tilesAcross)
			local y				=	math.floor(frame / tilesAcross)
			
			local px			=	consoleFix and 1/(64) or 0
			local zeroOff 		= px
			local oneOff 		= 1 - px
			
			local blk = anticlk and {
								x*qw,		y*qh,
								x*qw,		(y+1)*qh,
								(x+1)*qw,	(y+1)*qh,
								(x+1)*qw,	y*qh
						} or
						{
								(x+zeroOff)*qw,	(y+zeroOff)*qh,
								(x+oneOff)*qw,	(y+zeroOff)*qh,
								(x+oneOff)*qw,	(y+oneOff)*qh,
								(x+zeroOff)*qw,	(y+oneOff)*qh
						}

			blocks[frame]	=	blk
	
		end

		return tid,blocks,tilesAcross,tilesDown
		
	end

	local function updateUVTables(mx,my)
		local	uvTable						=	{}
		local idx = 1
		for x=0, tilesDisplayWidth  do
				local xpos = x+mx
		    	for y=0, tilesDisplayHeight    do
						local ypos = y+my
		      			local uvEntry =  quadTable[GetMapIndex(xpos,ypos)]
						for _,uv in pairs(uvEntry or {}) do
							uvTable[idx] = uv
							idx = idx + 1
						end	
		    	end
		end
		
		MemoryContainer.Reset(uvData)
		MemoryContainer.WriteFloat32(uvData,uvTable)

	end
	

	local function SetMapPixelPosition(pixx,pixy)
		mappixx				=	pixx < 0 and 0 or (pixx > maxPixelWidth  and maxPixelWidth or pixx)
		mappixy				=	pixy < 0 and 0 or (pixy > maxPixelHeight  and maxPixelHeight or pixy)
		
		local newMapX		=	1+math.floor(mappixx / tileSize)
		local newMapY		=	1+math.floor(mappixy / tileSize)
		fineX				=	mappixx % tileSize
		fineY				=	mappixy % tileSize

		if (newMapX ~= mapX or newMapY ~= mapY) then
			updateUVTables(newMapX,newMapY)
		end
		
		mapX				=	newMapX
		mapY				=	newMapY
		return mappixx,mappixy
	end
	

	function TileMap.InitTileMap(tilesetName,mapData,scrnDim,tSize)
		screenDim					=	scrnDim

		dimx						=	(scrnDim and scrnDim:X() or 1280)
		dimy						=	(scrnDim and scrnDim:Y() or 720)
	
		dimx2						=	dimx/2 
		dimy2						=	dimy/2
		
		tileSize					=	tSize
		
		tilesDisplayWidth 			= 	round(dimx/tileSize) 
  		tilesDisplayHeight 			= 	round(dimy/tileSize) 

		mapdata						=	mapData
		
		mapTilesDown				=	#mapData
		mapTilesAcross				=	#mapData[1]
		
		mapPixelWidth				=	mapTilesAcross*tileSize
		mapPixelHeight				=	mapTilesDown*tileSize

		maxPixelWidth				=	mapPixelWidth - tilesDisplayWidth*tileSize - 1
		maxPixelHeight				=	mapPixelHeight - tilesDisplayHeight*tileSize - 1
		quadCount					=	math.max(1,tilesDisplayWidth+1) * math.max(1,tilesDisplayHeight+1)
		sizeofContainer 			=	(tilesDisplayWidth+1)*(tilesDisplayHeight+1)*4*8
		
 		uvData 						= 	MemoryContainer.Create(sizeofContainer)
 		posData 					=	MemoryContainer.Create(sizeofContainer)
		local	antiClockwise		=	false
	 	tilemapTexture,quadTable,tileSetAcross,tileSetDown	=	CreateUVsQuadTable(tilesetName,tileSize,antiClockwise)

	   zeroPosTable = {}
       local idx = 1

	   for x=0, tilesDisplayWidth do
		  local xstart =  x*tileSize
		  local xend = xstart + tileSize
          for y=0, tilesDisplayHeight   do
				local ystart = y*tileSize
				local yend = ystart + tileSize
				local poss = anti and  {xstart,-ystart,xstart,-yend,xend,-yend,xend,-ystart} or {xstart,-ystart,xend,-ystart,xend,-yend,xstart,-yend}
				for _,posEl in pairs(poss) do
					zeroPosTable[idx] = posEl
				 	idx = idx + 1
				end
		    end
		end

		MemoryContainer.Reset(posData)
		MemoryContainer.WriteFloat32(posData,zeroPosTable)

		SetMapPixelPosition(0,0)
	
	end
			
	function  TileMap.GetMapDimensionsXY()
		return mapPixelWidth,mapPixelHeight
	end
	
		

	function TileMap.DrawMap(renderer,cenx,ceny)
	
		Renderer.SetOverlay(renderer,0)
		local topx,topy = SetMapPixelPosition(math.floor(cenx - dimx2),math.floor(ceny - dimy2))

		posmatrix:SetTranslation(-fineX,fineY,0,MATRIX_REPLACE)
		posmatrix:SetScale(1,1,1,1)
		Renderer.DrawQuads2d(renderer,0,quadCount,tilemapTexture,posmatrix,posData,uvData,mapuvCol)
		

		Renderer.SetOverlay(renderer,1)
		Renderer.Camera2dSetPosition(renderer,Vector4.Create(topx+dimx2,-(topy+dimy2)))

		Renderer.DrawCircle2d(renderer,math.floor(cenx),-math.floor(ceny),4)
		Renderer.DrawCircle2d(renderer,topx,-topy,40)
		
	end

	
--	function TileMap.Create(maps[1],screenDim)
--	function TileMap.GetMapDimensions(tilemap)		-- returns Vector
-- 	function TileMap.IsCollidable(tilemap,pixx,pixy)	-- returns true if > collindex
--	function TileMap.GetCentreCoords(tileMap,pixx,pixy)
--  function TileMap.CalcScreenNumber(tileMap,player)
--  function TileMap.TestCollideable(tileMap,pixx,pixy) ?
--  function TileMap.RenderFromCamera(tileMap,renderHelper,camera)
-- 	function TileMap.RenderCollision(tileMap,renderHelper)
--	function TileMap.ToggleDebug(tileMap)
--  function TileMap.GetCollisionPoly(tilemap,pixx,pixy)

		
	local function ClearCollisionForTile(tileIndex)
		collisioninfo[tileIndex] = nil
	end


	local function CreateCollisionInfo(tileinfo)

		assert(tileinfo and type(tileinfo) == 'table',"TileMap:CreateCollisionInfo - Expecting 'tileinfo' table")
		local pstr = {}

		if (TileMap.debug) then
			for key,property in pairs(tileinfo) do
				table.insert(pstr,"KEY "..key.." = "..type(property).."\n")	
			end
		end
		
		local collision = 	nil
		
		local angle 	=	tileinfo.angle or 0
		if (tileinfo.points) then
			collision = CollidePolygon.Create(tileinfo,tileSize)
		elseif (tileinfo.properties) then
			collision = CollidePolygon.Create(tileinfo.properties,tileSize)
		elseif (tileinfo.width or tileinfo.numpoints or (tileinfo[1] and tileinfo[1].px)) then
			collision = CollidePolygon.Create(tileinfo,tileSize)
		elseif (tileinfo.radius) then
			collision = CollideCircle.Create(tileinfo.radius*0.5*tileSize)
		else
			collision = CollideCircle.Create(root2*tileSize)
		end
		
		return collision -- {collision = collision,debug = table.concat(pstr)}
	end
	
	
	local function CreateCollisionFromPoints(tileIndex,points)
		local properties = {points = points}
		collisioninfo[tileIndex] = CreateCollisionInfo(properties)
	end
	
	
	
	local function setupCollision(tileInfo)

		collisioninfo = {}

		if (tileInfo) then
			for tileIndex,aTileInfo in pairs(tileInfo) do
				collisioninfo[tileIndex] = CreateCollisionInfo(aTileInfo)
			end
		end
	end

	function TileMap.Create(mapmetadata,screenDim)
		local tilemap	=	{
			className	=	TileMap.className,
		}
		
		local pixwidth	=	mapmetadata.mapinfo.width
		local pixheight	=	mapmetadata.mapinfo.height
		local drawindex	=	mapmetadata.mapinfo.drawindex
		local tsize		=	mapmetadata.mapinfo.twidth	
		local mapdata	=	mapmetadata.mapdata
		
		hashits			=	mapmetadata.mapinfo.hashits
		collideIndex	=	hashits and (mapmetadata.mapinfo.collideindex or 256) or 256

		local tName		=	string.match(mapmetadata.mapinfo.image, "([%a%d_]+)$")
		
		TileMap.InitTileMap(tName,mapdata,screenDim,tsize)

		setupCollision(mapmetadata.mapinfo.tileinfo)
		
		setmetatable(tilemap,{__index = TileMap})
		return tilemap
	end



	function TileMap.GetMapDimensions(tilemap)		-- returns Vector
		return Vector4.Create(mapPixelWidth,mapPixelHeight)
	end
	

	function TileMap.IsCollideable(tilemap,pixx,pixy)		
		return hashits and (GetMapIndex(math.modf(pixx/tileSize) + 1,math.modf(pixy/tileSize) + 1) >= collideIndex)
	end
	
	-- TODO CRAP!  tidy up!
	
	function TileMap.GetCentreCoords(tilemap,pixx,pixy)		
		local xpos	=	math.modf(pixx/tileSize) + 1
		local ypos	=	math.modf(pixy/tileSize) + 1
		local cx 	=	xpos*tileSize - 0.5 * tileSize
		local cy 	=	ypos*tileSize - 0.5 * tileSize
		return cx,cy

	end
	
	function TileMap.CalcScreenNumber(tileMap,player)
		return 0
	end
	
	function TileMap.RenderFromCamera(tileMap,renderHelper,camera)
		local renderer	=	renderHelper.renderer
		
		local topx,topy = SetMapPixelPosition(math.floor(camera.leftx),math.floor(camera.topy))

		posmatrix:SetTranslation(-fineX,fineY,0,MATRIX_REPLACE)
		posmatrix:SetScale(1,1,1,1)
		Renderer.DrawQuads2d(renderer,0,quadCount,tilemapTexture,posmatrix,posData,uvData,mapuvCol)
	end


	function TileMap.RenderFromXY(tileMap,renderer,x,y)
		local topx,topy = SetMapPixelPosition(math.floor(x- dimx2),math.floor(y - dimy2))

		posmatrix:SetTranslation(-fineX,fineY,0,MATRIX_REPLACE)
		posmatrix:SetScale(1,1,1,1)
		Renderer.DrawQuads2d(renderer,0,quadCount,tilemapTexture,posmatrix,posData,uvData,mapuvCol)
	end
	
	
	function TileMap.RenderCollision(tilemap,renderHelper)

		local fMapX,fMapY	=	math.floor(mapX),math.floor(mapY)

		local tsize = tileSize
	
		for x=0, tilesDisplayWidth  do
			local xpos = x+fMapX
			for y=0, tilesDisplayHeight - 1  do
				local ypos	=	y + fMapY
  				local tileIndex =  GetMapIndex(xpos,ypos)
				local collision =  collisioninfo[tileIndex]
				if (collision) then
					local pos = Vector4.Create((xpos  - 0.5)*tileSize,(ypos - 0.5)*tileSize)
					collision:Render(renderHelper,pos)
				else
					if (tileIndex >= collideIndex) then
						local xs,ys = (xpos  - 1)*tileSize,(ypos - 1)*tileSize
						RenderHelper.DrawRect(renderHelper,xs,ys,tileSize,tileSize,{red=127,green=0,blue=0,alpha=120})	
					end
				end
			end
			
		end
	
	end
	
	
	function TileMap.ToggleDebug(tileMap)
		TileMap.debug	=	not TileMap.debug
	end
	
	function TileMap.GetCollisionPoly(tilemap,pixx,pixy)
		local mapindex = (GetMapIndex(math.modf(pixx/tileSize) + 1,math.modf(pixy/tileSize) + 1))
		local colInfo = collisioninfo[mapindex]
		return colInfo
	end

	function TileMap.AnalyseMap(tileMap)
		local tileCount = {}
		local uniqueTiles	=	0
		for y = 1,#mapdata do
			for x =1,#mapdata[y] do
				local tidx = mapdata[y][x]
				if (not tileCount[tidx]) then
					tileCount[tidx] = 0
					uniqueTiles = uniqueTiles + 1
				end
				tileCount[tidx] = tileCount[tidx] + 1
			end
		end
		local imageTileCount= tileSetAcross*tileSetDown
		return uniqueTiles,imageTileCount,tileCount
	end
	
	
end
	
