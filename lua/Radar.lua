-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not Radar then
Radar = {}
Radar.className		=	'Radar'
Radar.DEFAULT_PIXELRADIUS	=	60
Radar.DEFAULT_CX			=	1024 - Radar.DEFAULT_PIXELRADIUS
Radar.DEFAULT_CY			=	10 + Radar.DEFAULT_PIXELRADIUS
Radar.DEFAULT_RANGE			=	2048

local sin 			=	math.sin
local cos			=	math.cos
local rad			=	math.rad
local abs			=	math.abs
local acos			=	math.acos
local deg			=	math.deg


local tmpV			=	Vector4.Create()
local tPos			=	Vector4.Create()
local tM		  	=	Matrix44.Create()	
local scale 		=	Radar.scale

local BLIPDURATION	=	1.5
local ANGLETOL		=	10


	function Radar.Create(cx, cy, range, pixelRadius)
		local radar = {
			cx				=	cx or Radar.DEFAULT_CX,
			cy				=	cy or Radar.DEFAULT_CY,
			range			=	range or Radar.DEFAULT_RANGE,
			direction		=	0,
			angularspeed	=	200,
			seen			=	{},
			time			=	0,
			pixelRadius		=	pixelRadius or Radar.DEFAULT_PIXELRADIUS,
			className		=	Radar.className,
		}
		setmetatable(radar,{ __index = Radar })
		Radar._Init(radar)
		return radar 
		
	end
	
	function Radar._Init(radar)
		radar.scale			=	(radar.pixelRadius / radar.range)
		radar.sMatrix		=	Matrix44.Create() 
		local sMatrix		=	radar.sMatrix
		sMatrix:SetRow(1,Vector4.Create(radar.scale,0,0,0))
		sMatrix:SetRow(2,Vector4.Create(0,radar.scale,0,0))
		sMatrix:SetRow(3,Vector4.Create(0,0,1,0))
		sMatrix:SetRow(4,Vector4.Create(0,0,0,1)) 
	end
	
	
	
	
	
	function Radar.GetRange(radar)
		return radar.range
	end
	
	
	function Radar._AngleToDirectionVector(angleDeg,radi)
		local 	radius	=	radi or 1
		local	rangle	=	rad(angleDeg + 270)
		local x,y		=	radius*cos(rangle),radius*sin(rangle)
	
		return x,y
	end
	
	
	function Radar.Update(radar,dt,viewer,enemies)
	
		local direction	=	viewer.direction
		local pos		=	viewer:GetVectorPosition()
		
		radar.time		=	radar.time + dt
	
		radar.direction	=	(radar.direction + dt*radar.angularspeed) % 360

		-- Matrix
		-- Translate -pos
		-- Scale radar.scale,radar.scale (x,y)
		-- Rotate -direction
	
		
		local tMatrix	=	Matrix44.Create()
		--TODO temp Vectors and only create new pos matrix if we need to!
		tMatrix:SetRow(1,Vector4.Create(1,0,0,-pos:X()))
		tMatrix:SetRow(2,Vector4.Create(0,1,0,-pos:Y()))
		tMatrix:SetRow(3,Vector4.Create(0,0,1,0))
		tMatrix:SetRow(4,Vector4.Create(0,0,0,1)) 


		local	rangle	=	rad(-direction)
		local cs,sn		=	cos(rangle),sin(rangle)
		
		local rotMatrix	=	Matrix44.Create()
		--TODO temp Vectors and only create new rotation matrix if we need to!
		
		rotMatrix:SetRow(1,Vector4.Create(cs,-sn,0,0))
		rotMatrix:SetRow(2,Vector4.Create(sn,cs,0,0))
		rotMatrix:SetRow(3,Vector4.Create(0,0,1,0))
		rotMatrix:SetRow(4,Vector4.Create(0,0,0,1)) 
		
		local radarmatrix	=	Matrix44.Create()
		tM:Multiply(radar.sMatrix,tMatrix)
		radarmatrix:Multiply(rotMatrix,tM)
		
		
		local lx,ly = Radar._AngleToDirectionVector(radar.direction)
		local seen = radar.seen
		
		for eIdx,enemy in pairs(enemies) do
			local rpos = enemy:GetVectorPosition()
			local nx,ny = Radar._Transform2D(radarmatrix,rpos:X(),rpos:Y())  
			local l		=	math.sqrt(nx*nx + ny*ny)	
			local dot = (lx*nx + ly*ny)/l
			if ( l < radar.pixelRadius and abs(deg(acos(dot))) < ANGLETOL) then
				table.insert(seen,{time = radar.time, x = nx, y = ny})
			end
		end
		
		local removeList	= {}
		
		for idx,seen in pairs(radar.seen) do
			if (radar.time > seen.time + BLIPDURATION) then
				table.insert(removeList,idx)
				radar.seen[idx] = nil
			end
		end


		
		
	end
	

	
	function Radar._Transform2D(matrix,x,y)  
	  -- 	local dest = Vector4.Create()		
			local r1 = matrix:GetRow(1)
			local r2 = matrix:GetRow(2)
			tPos:SetXyzw(x,y,0,1) 
			return Vector4.Dot4(r1,tPos),Vector4.Dot4(r2,tPos)
	--    	Vector4.TransformPoint(dest,matrix,Vector4.Create(x,y,0,1)) 
	-- 		return dest:X(),dest:Y()
		end



	
	
	function Radar.Render(radar,rHelper)
		
		Radar.DrawRadarHud(radar,rHelper)
		
		for idx,seen in pairs(radar.seen) do
			Radar.DrawEnemyBlip(radar,rHelper,seen.x,seen.y,(radar.time - seen.time)/BLIPDURATION)
		end
		
	end
	
	function Radar.DrawRadarHud(radar,rHelper)
		local cx,cy,pixelRadius	=	radar.cx,radar.cy,radar.pixelRadius

		RenderHelper.SetColour(rHelper, {red=128, green=128, blue=128, alpha=128} )
	    RenderHelper.DrawCircle(rHelper, cx, cy, pixelRadius,{red=0, green=128, blue=0, alpha=40})

		RenderHelper.SetColour(rHelper, 255, 255, 255, 255 )
	  	RenderHelper.DrawCircle(rHelper, radar.cx, radar.cy, 1)

		RenderHelper.DrawLine(rHelper, cx, cy, cx, cy - pixelRadius)
	    RenderHelper.DrawLine(rHelper, cx, cy, cx, cy + pixelRadius)
		RenderHelper.DrawLine(rHelper, cx, cy, cx - pixelRadius, cy )
	    RenderHelper.DrawLine(rHelper, cx, cy, cx + pixelRadius, cy )
		
		local lx,ly = Radar._AngleToDirectionVector(radar.direction,pixelRadius)
		RenderHelper.DrawLine(rHelper, cx, cy, lx+cx, ly+cy,{255,255,255,80})
		
	end
	
	function Radar.DrawEnemyBlip(radar,rHelper,x,y,intensity)
		RenderHelper.SetColour(rHelper, 255, 0, 0, 255*(1-intensity) )
		RenderHelper.DrawCircle(rHelper, radar.cx+x, radar.cy+y, 2*(1-intensity))
	end
	
end
