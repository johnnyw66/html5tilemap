-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Camera) then
Camera				=	{}
Camera.className	=	"Camera"
Camera.INTERPRATE	=	0.4
Camera.debug		=	false

	function Camera.Create(screenDim,mapDim,follow,interp)
	
		local camera = {
				follow		=	follow,
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
				interp		=	interp or Camera.INTERPRATE,
				className	=	Camera.className,
		}

		setmetatable(camera, { __index = Camera }) 

		Camera.Init(camera)
		return camera 

	end

	function Camera.SetRestriction(camera,minx,maxx,miny,maxy)
		camera.minx	=	minx
		camera.maxx	=	maxx
		camera.miny	=	miny
		camera.maxy	=	maxy - 64			-- Fudge! Somewrong caclulation
	end
	
	function Camera.Init(camera)
		if (camera.follow) then
			camera.x,camera.y,camera.z 	=	camera.follow:GetPosition()
		end
		
		Camera.SetRestriction(camera,camera.centrex,camera.mapwidth-camera.centrex,camera.centrey,camera.mapheight-camera.centrey)

		camera.vpos		=	Vector4.Create(camera.x,camera.y)

	end

	function Camera.Follow(camera,follow,snap)
		camera.follow		=	follow
		if (snap) then
			local x,y,z	=	follow:GetPosition()
			camera.x	=	x
			camera.y	=	y
		end
		
	end
	
	function Camera.Update(camera,dt)
		camera.time = camera.time + dt  
		if (camera.follow) then
			local followx,followy,followz = camera.follow:GetPosition()
			camera.x = camera.x + math.modf((followx	-	camera.x)*dt/camera.interp)
			camera.y = camera.y + math.modf((followy	-	camera.y)*dt/camera.interp)
--			camera.x	=	camera.follow.x
--			camera.y	=	camera.follow.y

			camera.x = (camera.x > camera.maxx) and camera.maxx or camera.x
			camera.x = (camera.x < camera.minx) and camera.minx or camera.x

			camera.y = (camera.y > camera.maxy) and camera.maxy or camera.y
			camera.y = (camera.y < camera.miny) and camera.miny or camera.y

			
			camera.leftx	=	camera.x - camera.centrex
			camera.rightx	=	camera.x + camera.centrex
			camera.topy		=	camera.y - camera.centrey
			camera.bottomy 	=	camera.y + camera.centrey

			camera.diffx	=	camera.leftx
			camera.diffy	=	camera.topy
			

		end
		
	end
	
	function Camera.GetPosition(camera)
		return camera.x,camera.y,camera.z
	end
	
	function Camera.GetVectorPosition(camera)
		camera.vpos:SetXyzw(camera.x,camera.y,camera.z,0)
		return camera.vpos
	end
	
	-- Used to Render Game Objects - must support the function Render(renderHelper,object,x,y)
	-- which are relative to the camera.
	
	function Camera.RenderObjectFromCameraView(camera,object,renderHelper)
		local x,y,z = object:GetPosition()
		object:Render(renderHelper,x-math.floor(camera.diffx),y - math.floor(camera.diffy))
--		RenderHelper.DrawText(renderHelper,string.format(" TOP CAM POS %f,%f",camera.leftx,camera.topy),600,600)
	end
	
	function Camera.Render(camera,renderHelper)
		if (Camera.debug) then
			RenderHelper.DrawCircle(renderHelper,camera.centrex,camera.centrey,8,{red=127,green=127,blue=40,alpha=0})
			RenderHelper.DrawText(renderHelper,string.format(" CAM POS %f,%f MAX X %f MAX Y %f",camera.x,camera.y,camera.maxx,camera.maxy),camera.centrex,camera.centrey)
		end
	end
	
end
