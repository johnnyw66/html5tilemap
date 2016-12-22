-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not LandDynamics then

LandDynamics			=	{}
LandDynamics.className	=	'LandDynamics'

local sin				=	math.sin
local cos				=	math.cos
local rad				=	math.rad
local atan2				=	math.atan2
local deg				=	math.deg


local time				=	0
local MAXSPEED			=	200
local MAXTHROTTLE		=	-MAXSPEED
local FRICTION			=	0.95
local MAXANGLE			=	45

local carSpeed			=	0
local carHeading		=	0
local carThrottle		=	0
local steerAngle		=	0
local frontWheel		=	{x = 512,y = 200}
local backWheel			=	{x = 512,y = 360}
local carLocation		=	{x = 512, y = 360}
local carLength			=	32


	
	-- Calculate BackWheel from carHeading and 
	-- carLength
	local function CalcBackWheel()
		local ly = frontWheel.y + carLength*sin(rad(180+carHeading - 90))
		local lx = frontWheel.x + carLength*cos(rad(180+carHeading - 90))
		backWheel.x	=	lx
		backWheel.y	=	ly
		carLocation.x = (frontWheel.x + backWheel.x) / 2
		carLocation.y = (frontWheel.y + backWheel.y) / 2
	end

	local function CalcFrontWheel()
		local ly 		= 	carLocation.y + 0.5*carLength*sin(rad(carHeading - 90))
		local lx 		= 	carLocation.x + 0.5*carLength*cos(rad(carHeading - 90))
		frontWheel.x	=	lx
		frontWheel.y	=	ly
	end

	local function ResetCar(pos,heading)
		carLocation		=	pos or {x = 512, y = 360}
		carSpeed		=	0
		carHeading		=	heading or 0
		LandDynamics.Recalc()
	end
	
	function LandDynamics.Recalc()
		CalcFrontWheel()
		CalcBackWheel()
	end
	
	function LandDynamics.Init(pos,heading,physics)
		ResetCar(pos,heading)
		LandDynamics.SetPhysicsTbl(physics)
	end


	function LandDynamics.SetPhysicsTbl(tbl)
		LandDynamics.SetPhysics(tbl.maxspeed,tbl.maxthrottle,tbl.friction,tbl.maxangle)	
		
	end
	
	function LandDynamics.SetPhysics(maxspeed,maxthrottle,friction,maxangle)
		MAXSPEED	=	maxspeed or 200
		MAXTHROTTLE	=	maxthrottle or -MAXSPEED
		FRICTION	=	friction or 0.95
		MAXANGLE	=	maxangle or 45
	end

	
	
	function LandDynamics.Update(dt)
		time		=	time	+	dt
		carSpeed	=	carSpeed + carThrottle*dt - FRICTION*carSpeed*dt

		if (carSpeed < 0) then
			carSpeed = math.max(carSpeed,-MAXSPEED)
		else
			carSpeed = math.min(carSpeed,MAXSPEED)
		end
		
	
		backWheel.x	=	backWheel.x	+ carSpeed * dt * cos(rad(carHeading-90))
		backWheel.y	=	backWheel.y	+ carSpeed * dt * sin(rad(carHeading-90))
		frontWheel.x	=	frontWheel.x + carSpeed * dt * cos(rad(carHeading+steerAngle-90))
		frontWheel.y	=	frontWheel.y + carSpeed * dt * sin(rad(carHeading+steerAngle-90))

		carLocation.x = ((frontWheel.x + backWheel.x) / 2)
		carLocation.y = ((frontWheel.y + backWheel.y) / 2)

		carHeading = 90+math.deg(atan2( frontWheel.y - backWheel.y , frontWheel.x - backWheel.x ))


		-- Adjust Backwheel	

		local ly = frontWheel.y + carLength*sin(rad(180+carHeading - 90))
		local lx = frontWheel.x + carLength*cos(rad(180+carHeading - 90))
		backWheel.x	=	lx
		backWheel.y	=	ly

	end

	-- quant3
	-- +/-{1,0}
	local quant3 = function(x)
		return x < -0.5 and -1 or x > 0.5 and 1 or 0
	end

	-- quant5
	-- +/-{1,0.5,0}
	local quant5 = function(x)
		return x < -0.75 and -1 or x < -0.25 and -0.5 or x < 0.25 and 0 or x < 0.75 and 0.5 or 1
	end



	-- quant32
	-- +/-{1,0.5,0}
	local quant32 = function(x)
		return x < -0.75 and -1 or x < -0.25 and -0.5 or x < 0.25 and 0 or x < 0.75 and 0.5 or 1
		-- -0.75 -> -0.75 - 0.25
		-- -
	end

	local noquant = function(x)
		return x
	end

	function LandDynamics.AxisMove(ax,ay)
		local quant	= quant32
		LandDynamics.Steer(quant(ax))
		LandDynamics.SetThrottle(ay)
	end
	
	function LandDynamics.Steer(steer)
		steerAngle	=	MAXANGLE*steer
	end

	function LandDynamics.GetSteering()
		return steerAngle
	end

	
	function LandDynamics.SetThrottle(throttle)
		carThrottle	=	MAXTHROTTLE*throttle
	end
	
	function LandDynamics.GetHeading()
		return carHeading
	end
	
	function LandDynamics.GetPosition()
		return carLocation
	end


	function LandDynamics.SetPosition(pos)
		carLocation	=	pos or {x = 0, y = 0}
	end

	function LandDynamics.SetHeading(angle)
		carHeading	=	angle or 0 
	end

	function LandDynamics.SetSpeed(speed)
		carSpeed	=	speed
	end


	function LandDynamics.GetSpeed()
		return carSpeed
	end

	function LandDynamics.GetMaxSpeed()
		return MAXSPEED
	end

	function LandDynamics.GetFrontWheel()
		return frontWheel
	end

	function LandDynamics.GetBackWheel()
		return backWheel
	end

	

end
	
