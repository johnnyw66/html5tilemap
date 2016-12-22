-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not RenderHelper) then
RenderHelper = {}
RenderHelper.classname="RenderHelper"
RenderHelper.tmpV = Vector4.Create()
RenderHelper.tmpV1 = Vector4.Create()
RenderHelper.tmpV2 = Vector4.Create()
RenderHelper.tmpV3 = Vector4.Create()
RenderHelper.tmpV4 = Vector4.Create()
RenderHelper.White = Vector4.Create(1,1,1,1)
RenderHelper.Black = Vector4.Create(0,0,0,1)
RenderHelper.Red = Vector4.Create(1,0,0,1)
RenderHelper.Blue = Vector4.Create(0,0,1,1)
RenderHelper.Green = Vector4.Create(0,1,0,1)
RenderHelper.tmpSprite = Sprite.Create()
RenderHelper.defaultSpriteColour	= RenderHelper.White
RenderHelper.lastcolour				=	Vector4.Create(1,1,1,1)

RenderHelper.fontcolour = 	Vector4.Create(1,1,1,1)
local defaultColour		=	{red=127,green=127,blue=127,alpha=127}
	
	function RenderHelper.Create()
		local renderhelper = {}
		renderhelper.className	 	=	RenderHelper.classname
  	  	renderhelper.screen			=	ArcadeGame.GetScreen()
		local dim 					=	Screen.GetSize(renderhelper.screen)
		renderhelper.renderer		=	Renderer.Create( Vector4.Create( 0, 0 ),dim,Vector4.Create(1,1) )
		
		-- Set all 16 Overlays to be in the same camera position
		
		for index = 0,15 do
			Renderer.SetOverlay(renderhelper.renderer,index)
			Renderer.Camera2dSetPosition(renderhelper.renderer,Vector4.Create( Vector4.X(dim)/2, -Vector4.Y(dim)/2))
			Renderer.Camera2dSetScale(renderhelper.renderer,Vector4.Create(1,1))
			Renderer.Camera2dSetRotation(renderhelper.renderer,0)
		end
		
		Renderer.SetTarget(renderhelper.renderer, renderhelper.screen )
  
		renderhelper.horalignment = "center"
		renderhelper.veralignment = "center"
		renderhelper.fonts	=	{}

		Renderer.SetFontVertAlignment(renderhelper.renderer,renderhelper.veralignment)
		Renderer.SetFontHorzAlignment(renderhelper.renderer,renderhelper.horalignment)
		
		
	  	setmetatable(renderhelper,{ __index = RenderHelper }) 
	
	  	return renderhelper 

	end

	-- Below 'under contract'
	function RenderHelper.DrawText(renderhelper,text,x,y,scale,rgba,halign,valign)
		if (type(text)=="number") then
			RenderHelper.DrawTextOLD(renderhelper,text,x,y,scale,rgba,halign,valign)
		else
			RenderHelper.DrawTextOLD(renderhelper,x,y,text,scale,rgba,halign,valign)
		end
	end

    function RenderHelper.DrawTextNoScale(renderhelper,text,x,y,rgba,halign,valign)
      		--Logger.print("RenderHelper.DrawText ",text)
		local horalign = halign or renderhelper.horalignment
		local vertalign = valign or renderhelper.veralignment

		local fontc = 	RenderHelper.fontcolour
		Vector4.SetXyzw(RenderHelper.tmpV,x,-y)

		if (rgba) then
			Vector4.SetXyzw(RenderHelper.tmpV2,rgba.red/128,rgba.green/128,rgba.blue/128,rgba.alpha/128)
			fontc = RenderHelper.tmpV2
		end

		Renderer.SetFontHorzAlignment(renderhelper.renderer,horalign)
		Renderer.SetFontVertAlignment(renderhelper.renderer,vertalign)

		Renderer.DrawText2d(renderhelper.renderer,
						RenderHelper.tmpV,
						""..text,fontc)

		Renderer.SetFontHorzAlignment(renderhelper.renderer,renderhelper.horalignment)
		Renderer.SetFontVertAlignment(renderhelper.renderer,renderhelper.veralignment)

	end

	function RenderHelper.DrawTextOLD(renderhelper,x,y,text,scale,rgba,halign,valign)
		--Logger.print("RenderHelper.DrawText ",text)
		local lscale = scale or 1
		local horalign = halign or renderhelper.horalignment
		local vertalign = valign or renderhelper.veralignment
		
		local fontc = 	RenderHelper.fontcolour
		RenderHelper.SetFontScale(renderhelper,lscale,lscale)
		Vector4.SetXyzw(RenderHelper.tmpV,x,-y)

		if (rgba) then
			Vector4.SetXyzw(RenderHelper.tmpV2,rgba.red/128,rgba.green/128,rgba.blue/128,rgba.alpha/128)
			fontc = RenderHelper.tmpV2
		end

		Renderer.SetFontHorzAlignment(renderhelper.renderer,horalign)
		Renderer.SetFontVertAlignment(renderhelper.renderer,vertalign)
	
		Renderer.DrawText2d(renderhelper.renderer,
						RenderHelper.tmpV,
						""..text,fontc)

		Renderer.SetFontHorzAlignment(renderhelper.renderer,renderhelper.horalignment)
		Renderer.SetFontVertAlignment(renderhelper.renderer,renderhelper.veralignment)
		
	end

	function RenderHelper.CreateFont(renderhelper,resourceName,size,keyName)
		local kName	=	keyName	 or resourceName
		local font 	= 	Font.Create(resourceName, size)
		--assert(false,kName.."=>"..resourceName)
		renderhelper.fonts[kName]	=	font
	end
	
	function RenderHelper.SetFont(renderhelper,fonttype)
		local fnt = renderhelper.fonts[fonttype]
		if (fnt) then
    		Renderer.SetFont(renderhelper.renderer,fnt)
		else
        	Renderer.SetFont(renderhelper.renderer,fonttype)
		end
    end

	function RenderHelper.GetFontHeight(renderhelper)
		return RenderHelper.GetTextSize(renderhelper,"0"):Y()
	end

	function RenderHelper.GetFontWidth(renderhelper,txt)
		return RenderHelper.GetTextSize(renderhelper,txt):X()
	end

	function RenderHelper.SetFontScale(renderhelper,sx,sy)
		Renderer.SetFontScale(renderhelper.renderer,sx,sy)
    end
	
	function RenderHelper.SetFontColour(renderhelper,rgba)
		--Logger.print("RenderHelper.SetFontColour ",text)
        Vector4.SetXyzw(RenderHelper.fontcolour,rgba.red/128,rgba.green/128,rgba.blue/128,rgba.alpha/128)
	end
	
	function RenderHelper.SetFontAlignment(renderhelper,veralignment,horalignment)
		renderhelper.horalignment = horalignment 
		renderhelper.veralignment = veralignment
		Renderer.SetFontHorzAlignment(renderhelper.renderer,horalignment)
		Renderer.SetFontVertAlignment(renderhelper.renderer,veralignment)
	end
	
	function RenderHelper.GetFontAlignment(renderhelper)
          return renderhelper.veralignment,renderhelper.horalignment
    end

	function RenderHelper.RenderSpriteRote(renderhelper,x,y,textid,rotate,scale,rgba)

	end

	function RenderHelper.DrawCircle(renderhelper,x,y,radius,rgba,mode)
		Renderer.DrawCircle2d(renderhelper.renderer,x,-y,radius or 4,16,RenderHelper.ConvertRGBA(rgba,RenderHelper.tmpV1),mode)
	end

	function RenderHelper.DrawCircleX(renderhelper,x,y,radius,rgba,mode)
		RenderHelper.ConvertRGBA(rgba,RenderHelper.tmpV1)
		--love.graphics.setBlendMode("alpha")
		Renderer.DrawCircle2d(renderhelper.renderer,x,-y,radius or 4,8,RenderHelper.tmpV1)
	--	assert(false,RenderHelper.tmpV1:toString())
	end
	
	function RenderHelper.ConvertRGBA(rgba,cVector)
		assert(cVector,'No RGBA cVector')

		if (rgba) then
			if (rgba.red or rgba.blue or rgba.green or rgba.alpha) then
				Vector4.SetXyzw(cVector,(rgba.red or 0)/128,(rgba.green or 0)/128,(rgba.blue or 0)/128,(rgba.alpha or 128)/128)
				return cVector
			else
				Vector4.SetXyzw(cVector,(rgba[1] or 0)/255,(rgba[2] or 0)/255,(rgba[3] or 0)/255,(rgba[4] or 255)/255)
				return cVector
			end
			
		else
			return RenderHelper.White
		end
	end
	
	function RenderHelper.DrawRect(renderhelper,x,y,wid,hgt,rgba)
		Vector4.SetXyzw(RenderHelper.tmpV,x,-y)
		Vector4.SetXyzw(RenderHelper.tmpV2,x+wid,-(y+hgt))
		Renderer.DrawRect2d(renderhelper.renderer,RenderHelper.tmpV,RenderHelper.tmpV2,rgba and 
																	RenderHelper.ConvertRGBA(rgba,RenderHelper.tmpV3) or
																	 RenderHelper.ConvertRGBA(renderhelper.lastcolour,RenderHelper.tmpV3))
	end
	
    function RenderHelper.DrawBox(renderhelper,x,y,wid,hgt,rgba)
	   RenderHelper.DrawLine(renderhelper,x,y,x+wid,y,rgba)
	   RenderHelper.DrawLine(renderhelper,x+wid,y,x+wid,y+hgt,rgba)
	   RenderHelper.DrawLine(renderhelper,x+wid,y+hgt,x,y+hgt,rgba)
	   RenderHelper.DrawLine(renderhelper,x,y+hgt,x,y,rgba)
	end

	function RenderHelper.DrawPolygon(renderhelper,vertices)

		for index = 1, #vertices,2 do
			local x1 = vertices[index]
			local y1 = vertices[index+1]
			local x2 = vertices[index+2] or vertices[1]
			local y2 = vertices[index+3] or vertices[2]
			RenderHelper.DrawLine(renderhelper,x1,y1,x2,y2)
		end

	end
	
	function RenderHelper.DrawLine(renderhelper,x,y,x2,y2,rgba)
		Vector4.SetXyzw(RenderHelper.tmpV,x,-y)
		Vector4.SetXyzw(RenderHelper.tmpV2,x2,-y2)
		Renderer.DrawLine2d(renderhelper.renderer,RenderHelper.tmpV,RenderHelper.tmpV2,RenderHelper.ConvertRGBA(rgba,RenderHelper.tmpV3))
	end

	function RenderHelper.DrawRawTexture(renderhelper,tex,x,y)

		local sprite = RenderHelper.tmpSprite
		Vector4.SetXyzw(RenderHelper.tmpV,x,-y)
		Vector4.SetXyzw(RenderHelper.tmpV1,1,1)
		
		Sprite.SetColor(sprite,RenderHelper.defaultSpriteColour)
		Sprite.SetPosition(sprite,RenderHelper.tmpV)
		Sprite.SetRotation(sprite,0)
		Sprite.SetScale(sprite,RenderHelper.tmpV1)
		Sprite.SetTexture(sprite,tex)
		
		Renderer.DrawSprite(renderhelper.renderer,sprite)
	end
	
    function RenderHelper.GetTextSize(renderhelper,text)
        return  Renderer.GetTextSize(renderhelper.renderer,text)
    end

	function RenderHelper.DrawTextureScale(renderhelper,textid,x,y,xscale,yscale,rgba)
		local sprite = RenderHelper.tmpSprite
		local tex = RenderHelper.TextureFind(textid)
		local width = Texture.GetWidth(tex)
		local height = Texture.GetHeight(tex)
		Vector4.SetXyzw(RenderHelper.tmpV,x,-y)
		Vector4.SetXyzw(RenderHelper.tmpV1,xscale or 1,yscale or 1)
		Sprite.SetColor(sprite,RenderHelper.ConvertRGBA(rgba or defaultColour,RenderHelper.tmpV3))
		Sprite.SetPosition(sprite,RenderHelper.tmpV)
		Sprite.SetRotation(sprite,rotation or 0)
		Sprite.SetScale(sprite,RenderHelper.tmpV1)	
		Sprite.SetTexture(sprite,tex)
		
		Renderer.DrawSprite(renderhelper.renderer,sprite)
	end
	
	function RenderHelper.DrawImage(renderhelper,textid,x,y,rotation,lscale,rgba,uvs)
		RenderHelper.DrawTexture(renderhelper,textid,x,y,rotation,lscale,rgba,uvs)
	end
	
	function RenderHelper.DrawTexture(renderhelper,textid,x,y,rotation,lscale,rgba,uvs)
		local sprite = RenderHelper.tmpSprite
		local tex = RenderHelper.TextureFind(textid)
		local width = Texture.GetWidth(tex)
		local height = Texture.GetHeight(tex)
		local scale = lscale or 1

		Vector4.SetXyzw(RenderHelper.tmpV,x,-y)
		Vector4.SetXyzw(RenderHelper.tmpV1,scale,scale)
		Sprite.SetColor(sprite,RenderHelper.ConvertRGBA(rgba,RenderHelper.tmpV3))
		Sprite.SetPosition(sprite,RenderHelper.tmpV)
		Sprite.SetRotation(sprite,rotation or 0)
		Sprite.SetScale(sprite,RenderHelper.tmpV1)	
		Sprite.SetTexture(sprite,tex)

		if (uvs) then
			Sprite.SetUvs(sprite,uvs)
		end

		Renderer.DrawSprite(renderhelper.renderer,sprite)
	end
	

	function RenderHelper.DrawSprite(renderhelper,sprite,x,y,lscale,rotate,rgba)
	
		local scale = lscale or 1

		Vector4.SetXyzw(RenderHelper.tmpV,x,-y)
		Vector4.SetXyzw(RenderHelper.tmpV1,scale,scale)
		Sprite.SetColor(sprite,RenderHelper.ConvertRGBA(rgba,RenderHelper.tmpV3))
		Sprite.SetPosition(sprite,RenderHelper.tmpV)
		Sprite.SetScale(sprite,RenderHelper.tmpV1)	
		Sprite.SetRotation(sprite,rotate or 0)
	
		Renderer.DrawSprite(renderhelper.renderer,sprite)
	end
	
	-- Static Method useful for debugging missing assets
	function RenderHelper.TextureFind(resourceName)
		return Texture.Find(resourceName) or Texture.Find((Constants and Constants.UNKNOWNTEXTURE) or "unknown")
--		return Texture.Find("unknown")
	end


	function RenderHelper._SetColours(renderhelper,red,green,blue,alpha)
		assert(red <=1,'1')
		assert(green <=1,'1')
		assert(blue <=1,'1')
		assert(alpha <=1,'1')
		RenderHelper.tmpV:SetXyzw(red,green,blue,alpha)
		RenderHelper.lastcolour:SetXyzw(red,green,blue,alpha)
	end
	
	function RenderHelper.SetColour(renderhelper,rgba,green,blue,alpha)
		if (rgba) then
			if (type(rgba) == 'table') then
				if (rgba.red or rgba.blue or rgba.green or rgba.alpha) then
					RenderHelper._SetColours(renderhelper,(rgba.red or 128)/128, (rgba.green or 128)/128, (rgba.blue or 128)/128, (rgba.alpha or 128)/128 )
				else
					RenderHelper._SetColours(renderhelper,(rgba[1] or 255)/255, (rgba[2] or 255)/255, (rgba[3] or 255)/255, (rgba[4] or 255)/255 )
				end
			
			else
				RenderHelper._SetColours(renderhelper, (rgba or 255)/255, (green or 255)/255, (blue or 255)/255, (alpha or 255)/255 )
			end
		end

	end


	-- NEW

	
	function RenderHelper.DrawTextureUvs(renderHelper,textureName,x,y,uvs)
		local sprite	=	Sprite.Create()
		local tex		=	RenderHelper.TextureFind(textureName)
		local fract		=	0.25

		local uvs2		=	{
				0,0,
				0,1,
				fract,1,
				fract,0
		}
		
		Sprite.SetTexture(sprite,tex)
		Sprite.SetUvs(sprite,unpack(uvs))
	
		Vector4.SetXyzw(RenderHelper.tmpV,x,-y)
--		Vector4.SetXyzw(RenderHelper.tmpV1,scale,scale)
--		Sprite.SetColor(sprite,RenderHelper.ConvertRGBA(rgba,RenderHelper.tmpV3))
		Sprite.SetPosition(sprite,RenderHelper.tmpV)
		Renderer.DrawSprite(renderHelper.renderer,sprite)
		
	end
	
	 function RenderHelper.CreateTextureAnimation(spritesAcross,spritesDown,textureName,fps)
		local sprite	=	Sprite.Create()
		local tid		=	RenderHelper.TextureFind(textureName)
		local fWidth	=	math.modf(tid:GetWidth()/spritesAcross)
		local fHeight	=	math.modf(tid:GetHeight()/spritesDown)
		
		
		Sprite.SetTexture(sprite,tid)

		local anim 				=	TextureAnim.Create(spritesAcross*spritesDown,fps or 20)
	
		for frame = 0,spritesAcross*spritesDown - 1 do

			local qw			=	1/spritesAcross 
			local qh			=	1/spritesDown
			local x,y			=	(frame % spritesAcross),math.modf(frame / spritesAcross)
	
			TextureAnim.AddFrame(anim,{frame = frame + 1,
				uvs = {
							tlu = 	x*qw,		tlv = 	y*qh,
							blu = 	x*qw,		blv = 	(y+1)*qh,
							bru	= 	(x+1)*qw,	brv	=	(y+1)*qh,
							tru	=	(x+1)*qw,	trv	=	y*qh
			
						},
						textureid	=	textureName
					})
	
		end
		return anim,sprite,fWidth,fHeight
		
	end

	 function RenderHelper.CreateAnimationPackage(spritesAcross,spritesDown,textureName,fps)
		local anim,sprite = RenderHelper.CreateTextureAnimation(spritesAcross,spritesDown,textureName,fps)
		return {anim = anim,sprite = sprite}
	end
	
	function RenderHelper.SetOverlay(renderhelper,overlay)
		renderhelper.renderer:SetOverlay(overlay)
	end
	
	function RenderHelper.GetOverlay(renderhelper,overlay)
		return renderhelper.renderer:GetOverlay()

	end
	
	function RenderHelper.GetCamera2dPosition(renderhelper)
		return renderhelper.renderer:Camera2dGetPosition()
	end

	function RenderHelper.SetCamera2dPosition(renderhelper,pos)
--		return renderhelper.renderer:Camera2dSetPosition(pos)
		return renderhelper.renderer:Camera2dSetPosition(Vector4.Create(math.modf(pos:X()),math.modf(pos:Y())))
	end

	function RenderHelper.GetCamera2dScale(renderhelper)
		return renderhelper.renderer:Camera2dGetScale()
	end

	function RenderHelper.SetCamera2dScale(renderhelper,scale)
		return renderhelper.renderer:Camera2dSetScale(scale)
	end

	function RenderHelper.GetCamera2dRotation(renderhelper)
		return renderhelper.renderer:Camera2dGetRotation()
	end

	function RenderHelper.SetCamera2dRotation(renderhelper,rotation)
		return renderhelper.renderer:Camera2dSetRotation(rotation)
	end

end
