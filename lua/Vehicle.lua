-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if	not Vehicle then
Vehicle					=	{}
local debug				=	true
local sin				=	math.sin
local cos				=	math.cos
local rad				=	math.rad
local atan2				=	math.atan2
local deg				=	math.deg


local cFrac			=	0.5
local carVertices 		=	{-0.5, -0.5*cFrac, 0.5, -0.5*cFrac, 0.5, 0.5*cFrac, -0.5, 0.5*cFrac}
local turretVertices 	=	{	-0.125,0.5,
								-0.125,-0.30,
								-0.25,-0.30,
								0,-0.5,
								0.25,-0.30,
								0.125,-0.30,
								0.125,0.5
								}

local time				=	0

local CARLENGTH			=	48
local WHEELRADIUS		=	CARLENGTH/4
local CARHALFLENGTH		=	CARLENGTH*0.5
local CARHALFWIDTH		=	CARHALFLENGTH*cFrac
local rHelper			=	nil
local turretAngle		=	0
local Dynamics			=	nil


function SetColour(colour)
	local cv		=	colour or {255,255,255,255}
	if (rHelper) then
		RenderHelper.SetColour(rHelper,cv[1] or 255,cv[2] or 255, cv[3] or 255, cv[4] or 255)
	end
end

function DrawText(text,x,y)
	if (rHelper) then
		RenderHelper.DrawText(rHelper,text,x,y)
	end
end

function DrawLine(x1,y1,x2,y2)
	if (rHelper) then
		RenderHelper.DrawLine(rHelper, x1, y1, x2, y2)
	end
end

function DrawCircle(cx,cy,radius)
	if (rHelper) then
		RenderHelper.DrawCircle(rHelper,cx,cy,radius)
	end
end

function DrawPolygon(vertices)
	if (rHelper) then
		RenderHelper.DrawPolygon(rHelper,vertices)
	end
end


	local function PlotWheel(wVect,colour)
		SetColour(colour)
		DrawCircle(wVect.x,wVect.y,4)
	end
	

	
	local function PlotArrowHead(direction,baseVector,stemLength,tipAngle,colour)
		
		SetColour(colour)

		local xbase,ybase	=	baseVector.x,baseVector.y
		local tipLength		=	stemLength*0.20

		local ly = ybase + stemLength*sin(rad(direction - 90))
		local lx = xbase + stemLength*cos(rad(direction - 90))

		local t1y = tipLength*sin(rad(direction - 90 + tipAngle))
		local t1x = tipLength*cos(rad(direction - 90 + tipAngle))

		local t2y = tipLength*sin(rad(direction - 90 - tipAngle))
		local t2x = tipLength*cos(rad(direction - 90 - tipAngle))


		DrawLine(xbase, ybase, lx,ly)
		DrawLine(lx, ly, lx-t1x, ly-t1y)
		DrawLine(lx, ly, lx-t2x, ly-t2y)
	end
	

	local function PlotCarDynamics()
		local frontWheel	=	Dynamics.GetFrontWheel()
		local backWheel		=	Dynamics.GetBackWheel()
		
		-- Draw Direction Vector from Front Wheel
		PlotArrowHead(Dynamics.GetHeading(),frontWheel,40,45,{255,0,0})
		PlotArrowHead(Dynamics.GetHeading()+Dynamics.GetSteering(),frontWheel,20,45,{255,255,0})

		PlotWheel(frontWheel,{255,255,0})
		PlotWheel(backWheel,{255,0,255})
	end


	local function rotate(angle,px,py,cx,cy)
		local	cs		=	math.cos(math.rad(angle+90))
		local	sn		=	math.sin(math.rad(angle+90))
		local 	tx		=	px*cs - py*sn + cx 
		local 	ty		=	px*sn + py*cs + cy
		return tx,ty
	end
	
	local function transFormPolygon(poly,angle,scale,cx,cy)
		local tPoly		=	{}
		local numCoords	=	math.modf(#poly/2)
		
		for index = 1, #poly,2 do
			if (type(poly[index]) == 'number') then
				local px,py 		= scale*poly[index],scale*poly[index + 1]
				local tx,ty 		= rotate(angle,px,py,cx,cy)
				tPoly[index] 		= 	tx
				tPoly[index + 1]	=	ty

			else
				assert(false,'not yet implemented ')
			end
			
		end
		return tPoly
		
	end

	
	local function DrawTurret(angle,cx,cy)
		SetColour( {255, 255, 255, 255} )
		DrawCircle(cx,cy,4)
		DrawPolygon(transFormPolygon(turretVertices,angle,40,cx,cy))
	end
	
	
	local function DrawCar(carVertices,carAngle,wheelAngle,cx,cy)
		SetColour( {255, 255, 255, 255} )

		DrawCircle(cx,cy,4)
		DrawPolygon(transFormPolygon(carVertices,carAngle,CARLENGTH,cx,cy))

		local wx,wy		=	rotate(carAngle,CARHALFLENGTH,CARHALFWIDTH,0,0)
		DrawPolygon(transFormPolygon(carVertices,carAngle+wheelAngle,WHEELRADIUS,cx-wx,cy-wy))

		wx,wy		=	rotate(carAngle,-CARHALFLENGTH,CARHALFWIDTH,0,0)
		DrawPolygon(transFormPolygon(carVertices,carAngle+wheelAngle,WHEELRADIUS,cx+wx,cy+wy))

		wx,wy		=	rotate(carAngle,CARHALFLENGTH,-CARHALFWIDTH,0,0)
		DrawPolygon(transFormPolygon(carVertices,carAngle,WHEELRADIUS,cx+wx,cy+wy))

		wx,wy		=	rotate(carAngle,-CARHALFLENGTH,-CARHALFWIDTH,0,0)
		DrawPolygon(transFormPolygon(carVertices,carAngle,WHEELRADIUS,cx-wx,cy-wy))
	
	end
	

	function Vehicle.Init(pos,dynamics,heading,physics)
		Dynamics	=	dynamics or LandDynamics
		Dynamics.Init(pos,heading,physics)
	end
	
	function Vehicle.SetPositionXY(x,y)
		Dynamics.SetPosition({x = x,y = y})
	end
	
	function Vehicle.SetPosition(pos)
		Dynamics.SetPosition({x = pos:X(),y = pos:Y()})
	end

	function Vehicle.SetHeading(direction)
		Dynamics.SetHeading(direction)
	end

	function Vehicle.SetSpeed(speed)
		Dynamics.SetSpeed(speed)
	end

	

	function Vehicle.Update(dt)
		time		=	time	+ dt
		Dynamics.Update(dt)
   	end


	function Vehicle.Turret(turret)
		turretAngle 		= 	180*turret
	end

	function Vehicle.BrakesOn()
		Vehicle.SetSpeed(0)
		Dynamics.SetThrottle(0,0)
	end

	function Vehicle.Throttle(throttle)
		Dynamics.SetThrottle(throttle)
	end

	function Vehicle.GetPosition()
		return Dynamics.GetPosition()
	end

	function Vehicle.GetSpeed()
		return Dynamics.GetSpeed()
	end

	function Vehicle.GetMaxSpeed()
		return Dynamics.GetMaxSpeed()
	end

	function Vehicle.Recalc()
		return Dynamics.Recalc()
	end


	function Vehicle.GetHeading()
		return Dynamics.GetHeading()
	end
	

	function Vehicle.AxisMove(steer,throttle)
		Dynamics.AxisMove(steer,throttle)
	end


	function Vehicle.SetTurretAngle(angle)
		turretAngle 		= 	angle
	end
	
	function Vehicle.Render(renderHelper)
		-- Draw Car
		if (debug) then
		
		rHelper			=	renderHelper
			
		local location 	= Dynamics.GetPosition()
		DrawCar(carVertices,Dynamics.GetHeading(),Dynamics.GetSteering(),location.x,location.y)
		DrawTurret(turretAngle-90,location.x,location.y)
		

		if (applyBrake) then
			SetColour( {255, 0, 0, 255} )
			DrawCircle(location.x,location.y,4)
		end

		PlotCarDynamics()
--		RenderInstructions()
		end
		
	end
	


	function RenderInstructions()

		SetColour( {255, 255, 255, 255} )

		DrawText(helpText,100,100)
		DrawText(string.format("carspeed %f",Dynamics.GetSpeed()),100,120)

	end
	

end
	
