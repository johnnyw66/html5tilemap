-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not CameraOrbitor) then

-- CameraOrbitor - an in game object generated at the end of playing a level - 
-- Generates a series of Bezier curves around the playing map area, which the 'orbitor' (an invisible object)
-- moves round after the end of a game.
-- The game 'camera' will made to follow this cameraorbitor object - allowing
-- the player to view other parts of the map they may not have visited.
-- This could aid them when they replay a level.


CameraOrbitor				=	{}
CameraOrbitor.className		=	"CameraOrbitor"
CameraOrbitor.debug			=	false

--
-- The following table was produced by BezTool
-- source found in trunk/tools/BezTool
-- see also trunk/source/generic/CameraOrbitor.lua
--
local bezRelTable = {
{{x = 0.205078, y = 0.495833},{x = 0.467773, y = 0.195833},{x = 0.752930, y = 0.498611},{x = 0.452148, y = 0.793056}},
{{x = 0.203125, y = 0.493056},{x = 0.469727, y = 0.195833},{x = 0.753906, y = 0.494444}},
{{x = 0.452148, y = 0.788889},{x = 0.203125, y = 0.495833},{x = 0.464844, y = 0.201389}},
{{x = 0.752930, y = 0.493056},{x = 0.451172, y = 0.790278},{x = 0.205078, y = 0.498611}},
}
	function CameraOrbitor.Create(screenDim,mapDim,spline)
	
		local cameraorbitor = {
				x 			=	0,
				y			=	0,
				z			=	0,
				leftx		=	0,
				topy		=	0,
				time		=	0,
				mapwidth	=	mapDim:X(),
				mapheight	=	mapDim:Y(),
				centrex		=	screenDim:X()/2,
				centrey		=	screenDim:Y()/2,
				vpos		=	Vector4.Create(),
				spline		=	spline,
				className	=	CameraOrbitor.className,
		}

		setmetatable(cameraorbitor, { __index = CameraOrbitor }) 

		CameraOrbitor.Init(cameraorbitor)
		return cameraorbitor 

	end

	function CameraOrbitor.Init(cameraorbitor)
		-- Define a Spline
		-- From Map Data
		if (not cameraorbitor.spline) then
		
			local dBez = { type = 'bezier', nodes = {}, primitiveType='path', closed = false, }
			
			dBez.nodes					=	{}

			local mapWidth,mapHeight	=	cameraorbitor.mapwidth,cameraorbitor.mapheight

			
			for _,bez in pairs(bezRelTable) do
				local bz	=  {}
				for _,rtPoint in pairs(bez) do
					local rx,ry	=	rtPoint.x*mapWidth,rtPoint.y*mapHeight
					table.insert(bz,{x = rx, y = ry})
				end
				table.insert(dBez.nodes,bz)
			end
			
			cameraorbitor.path	=	Spline.Create(dBez)
			cameraorbitor.totalPathLength	=	cameraorbitor.path:GetTotalLength()
		end

		cameraorbitor.tValue		=	0
		cameraorbitor.back			=	false
		cameraorbitor.tSpeed 		=	256
		cameraorbitor.speedConst	=	cameraorbitor.path and cameraorbitor.totalPathLength or 1
		cameraorbitor.speedFact		=	cameraorbitor.tSpeed/cameraorbitor.speedConst	
		
	end

	function CameraOrbitor.Update(cameraorbitor,dt)
		cameraorbitor.time = cameraorbitor.time + dt 
		
		cameraorbitor.tValue	=	cameraorbitor.tValue + dt*cameraorbitor.speedFact	

		if (cameraorbitor.tValue > 1) then
			cameraorbitor.tValue = 0
			if (not cameraorbitor.path:IsClosed()) then
				cameraorbitor.back	 = not cameraorbitor.back
			end
		end
		cameraorbitor.path:CalcPosition(cameraorbitor.vpos,cameraorbitor.tValue,cameraorbitor.back)

		cameraorbitor.x		=	cameraorbitor.vpos:X()
		cameraorbitor.y		=	cameraorbitor.vpos:Y()
		
	end
	
	function CameraOrbitor.GetPosition(cameraorbitor)
		return cameraorbitor.x,cameraorbitor.y,cameraorbitor.z
	end
	
	function CameraOrbitor.GetVectorPosition(cameraorbitor)
		cameraorbitor.vpos:SetXyzw(cameraorbitor.x,cameraorbitor.y,cameraorbitor.z,0)
		return cameraorbitor.vpos
	end
	
	
	function CameraOrbitor.Render(cameraorbitor,renderHelper)
		if (CameraOrbitor.debug) then
			RenderHelper.DrawCircle(renderHelper,cameraorbitor.x,cameraorbitor.y,16,{red=127,green=63,blue=40,alpha=10})
	--		cameraorbitor.path:_RenderDebug(renderHelper)
		end
		
--		for _,pt in pairs(cameraorbitor.bezpoints) do
--			RenderHelper.DrawCircle(renderHelper,pt.x,pt.y,16,{red=127,green=63,blue=40,alpha=127})
--		end
		
	end
	
end
