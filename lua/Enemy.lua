-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt

if not Enemy then

Enemy 			=	{}
Enemy.className	=	"Enemy"
Enemy.debug						=	false
Enemy.canfire					=	true
local tmpV						=	Vector4.Create()
local sqrt						=	math.sqrt
local cos						=	math.cos
local sin						=	math.sin
local rad						=	math.rad

local ALLPICKUPS				=	'indestructible=8,rapidfire=8,homingmissile=6,extralife=8,powerup=8,timeshift=6,chaff=6,null=50'
local TESTPICKUPS				=	'indestructible=0,rapidfire=0,homingmissile=0,extralife=0,powerup=0,timeshift=50,chaff=0,null=50'

local DEFAULTPICKUPS			=	ALLPICKUPS		-- default pickup weighted table presented to player - when enemy is destroyed


local DEFAULTENEMYSCORE			=	150
local DEFAULTBULLETDAMAGE		=	10

local AIMTOL					=	22 			-- Aim tol in degrees
local DEFAULTBULLETVEL			=	400
local DEFAULTBULLETDURATION		=	1
local DEFAULTFIRERATE			=	0.5
local DEFAULTFIREPERIOD			=	1/DEFAULTFIRERATE

local DEFAULTMISSILEPERIOD		=	5


local DEFAULTINVIEWDIST			=	360*360	

local kENEMY_MAXTURNANGLE			=	90.0
local kENEMY_ANGULAR_ACCELERATION	=	120.0
local tmpV							=	Vector4.Create()
local scoreTextures	=	{

	[100]	=	"bonus150",
	[150]	=	"bonus150",
	[200]	=	"bonus150",
	[250]	=	"bonus150",
	[300]	=	"bonus150",
	[350]	=	"bonus150",

}

local function buildLuaTable(text)
	local modtext 	=	text:gsub("^%s*(.-)%s*$", "%1")
	local tbl		=	{}
	

		string.gsub(modtext,"([A-Za-z_0-9]+)%W*[=][ ]*([^,}]+)",
			function(var,val)
			
				local ch = string.byte(val)
				if (ch == string.byte("'") ) then
					--val = string.gsub(val, "'", "", 2)
				elseif (ch <= string.byte('9')) then
					-- only store 'value = number' pairs
					val = tonumber(val)	
					tbl[var]	=	val
				else

				end
			end)

	return tbl
end

local function parsePickupText(text)

	local tbl = buildLuaTable(text)
	
	-- go through table - eventName = Percent Chance
	local pdf		=	{}
	local pdfNames	=	{}
	local index		=	0
	local remaining	=	100
	
	for eventName,percentage in pairs(tbl) do
		index			=	index + 1
		pdf[index]		=	percentage
		pdfNames[index]	=	eventName
		remaining		=	remaining	-	percentage
	end

	if (remaining > 0) then
		pdf[index+1]		=	remaining
		pdfNames[index+1]	=	'null'
	end
	
	return {pdf = pdf, names = pdfNames}
end

	function Enemy._CreatePos(posx,posy)

		local enemy = {
			pos			=	Vector4.Create(posx,posy),
			radius		=	4,	
			time		=	0,
			className	=	Enemy.className,
		}

		setmetatable(enemy,{ __index = Enemy })
		Enemy._Init(enemy)
		return enemy
	end

	function Enemy._CreateRaw(rawData)

		local enemy = {
			data		=	rawData,
			pos			=	Vector4.Create(0,0),	
			radius		=	10,
			time		=	0,
			angle		=	0,
			fireperiod		=	DEFAULTFIREPERIOD,	
			inviewdist		=	DEFAULTINVIEWDIST,	
			lastfired		=	0,
			className	=	Enemy.className,
		}

		setmetatable(enemy,{ __index = Enemy })
		Enemy._Init(enemy)
		return enemy
	end


	function Enemy.Create(...)
		local args = {...}
    	local t = args[1]
    	if (not t or type(t) == 'number') then
			return Enemy._CreatePos(...)
		else
			return Enemy._CreateRaw(...)
		end
		
	end

	
	function Enemy.SetDefaultPickups(defpickups)
		Enemy.defaultpickups		=	defpickups
	end
	
	function Enemy._Init(enemy)
		local data	=	enemy.data
		

		enemy.alive					=	true
		if (data) then
			enemy.pos				=	Vector4.Create(data.x,data.y)
			
			enemy.name				=	data.name
			enemy.scalex			=	data.scalex
			enemy.scaley			=	data.scaley
			enemy.flipped			=	data.flipped
			
			enemy.class				=	data.class	
			enemy.properties		=	data.properties
			enemy.angle				=	data.angle
			enemy.radius			=	(data.properties and data.properties.radius) or 32
			enemy.radsq				=	enemy.radius*enemy.radius
			enemy.colour			=	{255,120,60,128}
			enemy.pathinfo			=	data.pathinfo
			
			enemy.realpath			=	data.pathinfo and data.pathinfo.path.realpath 
			enemy.pathsegment		=	data.pathinfo and data.pathinfo.segment	-- NB: segment is 0 based!
			enemy.pathT				=	data.pathinfo and data.pathinfo.t
			
			enemy.link				=	data.linkid
			enemy.reallink			=	nil
			enemy.back				=	false
			
			enemy.phase				=	((data.properties and data.properties.phase) or math.random())*6.28
			enemy.pK				=	(data.properties and data.properties.pk)  or 0.125
			enemy.pRadius			=	(data.properties and data.properties.pradius) or 256
			
			enemy.tSpeed			=	(data.properties and data.properties.speed) or 40
			enemy.turretlength		=	(data.properties and data.properties.turretlength) or 40
			
			if (enemy.realpath) then
				enemy.tValue			=	enemy.realpath:FindPathTValue(enemy.pathsegment,enemy.pathT)
				enemy.realpath:CalcPosition(enemy.pos,enemy.tValue)
				enemy.totalPathLength	=	enemy.realpath:GetTotalLength()
			end
			
			enemy.antishield		=	1-math.min(1,math.max(0,((data.properties and data.properties.shield) or 0)))
			enemy.nummissiles		=	(data.properties and data.properties.missiles) or 2

			enemy.bulletduration	=	(data.properties and data.properties.bulletduration) or DEFAULTBULLETDURATION
			enemy.bulletvelocity	=	(data.properties and data.properties.bulletvelocity) or DEFAULTBULLETVEL
			
			
			enemy.score				=	(data.properties and data.properties.score) or DEFAULTENEMYSCORE
			enemy.inviewdist		=	(data.properties and data.properties.inviewdist) or DEFAULTINVIEWDIST
			enemy.canfire			=	(data.properties and data.properties.canfire) 
			enemy.fireperiod		=	(data.properties and data.properties.firerate and 1/data.properties.firerate) or  DEFAULTFIREPERIOD
			enemy.missileperiod		=	(data.properties and data.properties.missilerate and 1/data.properties.missilerate) or  DEFAULTMISSILEPERIOD
			
			enemy.bulletdamage		=	(data.properties and data.properties.bulletdamage) or  DEFAULTBULLETDAMAGE
			enemy.deadname			=	(data.properties and data.properties.deadname)
			enemy.pickx				=	(data.properties and data.properties.pickx) or 0
			enemy.picky				=	(data.properties and data.properties.picky) or 0
			enemy.scale				=	(data.properties and data.properties.scale) or enemy.scalex
			enemy.turnrate			=	(data.properties and data.properties.turnrate) or 10
			enemy.rps				=	(data.properties and data.properties.rps) or 0
			enemy.strength			=	(data.properties and data.properties.strength) or 255
			enemy.killtext			=	(data.properties and data.properties.killtext and Locale.ModifyText(data.properties.killtext))
--			enemy.pickup			=	parsePickupText((data.properties and data.properties.pickup) or DEFAULTPICKUPS)
			enemy.pickup			=	data.properties and data.properties.pickup and parsePickupText(data.properties.pickup)
			

			-- or 'indestructible=50,rapidfire=50,extralife=0,chaff=0' or "rapidfire=66,indestructible=15,powerup=15")
		end

		enemy.pathCN				=	(enemy.realpath and enemy.realpath.className or 'Nil Path')
		

		-- IF type == 'orbitor' (TODO)
		
		enemy.paratime	=	0
		
		enemy.cx		=	enemy.pos:X()
		enemy.cy		=	enemy.pos:Y()
		enemy.currentAngularSpeed = 0.0
		enemy.currentAngularDir   = true
				
		enemy.direction				=	enemy.angle or math.random(0,359)
		enemy.aimdirection			=	enemy.direction
		
--		local ptime  = enemy.paratime*enemy.pK + enemy.phase
--		local radius = enemy.pRadius
--		local xpos =	enemy.cx + (radius+cos(2*ptime))*sin(5*ptime)
--		local ypos =	enemy.cy + (radius+cos(2*ptime))*cos(3*ptime)
	
		
--		Enemy.SetPosition(enemy,xpos,ypos)
		-- end IF
--		Enemy._BuildAnimations(enemy)

		enemy.animations	=	{}
		enemy.dormant		=	false
		Enemy._BuildData(enemy)

--		enemy.deadname	=	"dead"
		
	end
	
	
	function Enemy.SetDefaultPickups(enemy,pickupstring)
		-- set up default pickup if we have one - so long as one as not already defined.
		if (pickupstring and not enemy.pickup) then
			enemy.pickup			=	parsePickupText(pickupstring)
		end
	end
	
	
	function Enemy._BuildData(enemy)
		enemy.parts 	=	EnemyData.CreateEnemyParts(enemy)
		-- Now Parse Pickups
	end

	
	function Enemy.Debug(enemy)

	end
	
	function Enemy.MarkForMission(enemy)
		enemy.mission 	=	true
	end


	function Enemy.IsAlive(enemy)
		return enemy.alive 
	end

	function Enemy.IsKilled(enemy)
		return not enemy.alive or enemy.dormant
	end

	function Enemy.ApplyDamage(enemy,damage)
		assert(enemy.className == 'Enemy','Enemy.ApplyDamage:WE ARE AN ENEMY:'..(enemy.className or 'NIL'))
		local ddamage	=	(damage or 0)*enemy.antishield
		enemy.strength 	= 	math.max(0,enemy.strength - ddamage)
		if (enemy.strength <= 0 and enemy.alive and not enemy.dormant) then
			Enemy.Kill(enemy,true)
		end
	end
	
	function Enemy.Kill(enemy,explode)

		local xpos,ypos,zpos	=	enemy:GetPosition()
		
		if (explode) then
			local cnt = 0
			for _,part in pairs(enemy.parts) do
				local explosions = part:GetExplosions()
				cnt = cnt + #explosions
			end
		--	assert(false,cnt)
				
			for _,part in pairs(enemy.parts) do
				local explosions = part:GetExplosions()
				if (explosions) then
					for _,explode in pairs(explosions) do
							EventManager.AddSingleShotEvent(
							function(explode)
								ExplosionManager.AddExplosion({x = xpos + (explode.x or 0), y = ypos + (explode.y or 0), z = zpos, scale = explode.scale, 
									framesvert = explode.framesvert, frameshor = explode.frameshor, texture=explode.texture, fps = explode.fps})
							end,
							explode,explode.delay or 0)
					end
				end
			end
		end

		local score = enemy:GetScore()	
		ScoreManager.Record(enemy.name)
		ScoreManager.AddScore(score)
		ParticleManager.AddTextureParticle(scoreTextures[score] or "bonus150",xpos,ypos,0,-8,3.5)

		if (enemy.pickup) then
			local pos	=	enemy:GetVectorPosition()
			local ppos	=	Vector4.Create(enemy.pickx,enemy.picky)
			ppos:Add(ppos,pos)
			PickupManager.AddRandomPickup(ppos,enemy.pickup)
		end
		
		if (enemy.killtext) then
			MessageManager.Add(Message.Create(DisplayableTextWithImage.Create(enemy.killtext),
			SpringBox.Create(1024/2,720/2,-100,nil,nil,nil,3)),true)
		end

		if (enemy.deadname) then
--			enemy.antishield	=	0
--			enemy.strength		=	255
--			enemy.ignorecollide	=	true
			-- Change Name
			enemy.name			=	enemy.deadname
			enemy.dormant		=	true
			Enemy._BuildData(enemy)
		else
			enemy.alive	=	false
		end
		
	end
	

	function Enemy.GetScore(enemy)
		return enemy.score	or DEFAULTENEMYSCORE 
	end

	function Enemy.GetTarget(enemy)
		return enemy.follow
	end
	
	function Enemy.SetTarget(enemy,target)
		enemy.follow = target
	end
	
	function Enemy.Follow(enemy,follow)
		enemy.follow = follow
	end

	
	function Enemy.SetPosition(enemy,x,y,z,w)
		enemy.pos:SetXyzw(x,y,z or 0,w or 0)
	end
	
	function Enemy.SetVectorPosition(enemy,newpos)
		enemy.pos:SetXyzw(newpos:X(),newpos:Y(),newpos:Z(),newpos:W())
	end

	function Enemy.GetTarget(enemy)
		return enemy.follow 
	end

	
	function Enemy.GetVectorPosition(enemy)
		return enemy.pos
	end

	-- Legacy
	function Enemy.GetPosition(enemy)
		local v = enemy.pos
		return v:X(),v:Y(),v:Z()
	end

	function Enemy.GetDirection(enemy)
		return enemy.direction
	end

	function Enemy.GetFiringDirection(enemy)
		for _,part in pairs(enemy.parts) do
			if (part.ctype=='turret') then
				return part.direction
			end
		end
		return enemy.direction
	end

	function Enemy.GetMissileDirection(enemy)
		return enemy.direction
	end

	function Enemy.GetFiringOffset(enemy)
		return {ox = 0, oy = 0, oz = 0}
	end

	function Enemy.GetFiringOffset2(enemy,len,direction)
		local dx,dy = Enemy._MakeDirectionVectorPair(direction,0,0,len)
		return {ox = dx, oy = dy, oz = 0}
	end
	
	function Enemy._MakeDirectionVectorPair(angle,xpos,ypos,size)
		local rsize	=	size or 1
		local ny= -rsize*sin(rad(angle + 90))
		local nx= -rsize*cos(rad(angle + 90))
		return xpos+nx,ypos+ny
	end
	
	
	function Enemy._MakeDirectionVector(angle)
		local ny= -sin(rad(angle + 90))
		local nx= cos(rad(angle + 90))
		return Vector4.Create(nx,ny)
	end
	
	
	
	-- CallBacks (from Trigger Hotspots)
	
	
	function Enemy.ObjectInside(enemy,object,shape)
--		assert(false,'INSIDE '..object.className..)
		Logger.lprint('INSIDE '..object.className)
		local rotation	=	0
		if (enemy.canfire) then
			MissileManager.AddHMissile( enemy, enemy.pos, 80,enemy.direction, 10,object)
		end
	end

	function Enemy.ObjectOutside(enemy,object,shape)
--		assert(false,'OUTSIDE '..object.className)
		Logger.lprint('OUTSIDE '..object.className)
	end


		function Enemy.EntityEntered(enemy,object,shape)
	--		assert(false,'INSIDE '..object.className..)
			Logger.lprint('ENTERED '..object.className)
		end

		function Enemy.EntityLeft(enemy,object,shape)
	--		assert(false,'OUTSIDE '..object.className)
			Logger.lprint('LEFT '..object.className)
		end

	function Enemy.GetTarget(enemy)
		return enemy
	end
	
	
	local	kRECOIL_M	=	100
	local	kRECOIL_R	=	100
	local	kRECOIL_K	=	140
	local 	kRECOIL_FORCE	=	20
	
	function Enemy.StartRecoil(enemy,force)
		enemy.dV		= Enemy._MakeDirectionVector(enemy.direction)	
		enemy.recoilspring	= Spring.Create(-4,0,kRECOIL_M,kRECOIL_R,kRECOIL_K,4)
		
	end

	function Enemy.RecoilUpdate(enemy,dt)
	
		if (not enemy.recoilspring) then
		 	Enemy.StartRecoil(enemy,kRECOIL_FORCE)
		else
			local distFromOrigin = Spring.GetPosition(enemy.recoilspring)
			Vector4.Multiply(Temp.v0,enemy.dV,distFromOrigin)
			Vector4.Add(Temp.v0,Temp.v0,enemy.pos)
			
			Enemy.SetVectorPosition(enemy,Temp.v0)
		end
		
	end
	
	function Enemy.TurnHead(enemy,dt)
		Enemy.Turn(enemy,dt)

		for _,part in pairs(enemy.parts) do
			if (part.ctype == 'turret') then
				part.direction	=	enemy.aimdirection
				enemy.turret	=	part
			elseif (part.ctype == 'rotate') then
				part.direction 	= 	part.direction + dt*1*360
			else
				part.direction 	= 	enemy.class == 'flying' and enemy.aimdirection or enemy.direction 
				part.direction 	= 	 enemy.direction 
				
			end
		end
	
	end
	
	function Enemy.Update(enemy,dt)
		enemy.time			=	enemy.time + dt
		if (not enemy:IsAlive()) then
			return
		end

		-- Allow animation to go on
		
		for _,part in pairs(enemy.parts) do
			part:Update(dt)
		end
		
		if (enemy.dormant) then
			return
		end
		
		-- Find out direction we need to aim at to fire/move to our
		-- player
	
		local followxpos,followypos,_	= enemy.follow:GetPosition() --(enemy.follow:IsAlive() and enemy.follow:GetPosition()) or enemy:GetPosition()
		local enemyxpos,enemyypos,_		= enemy:GetPosition()

		local lx = enemyxpos - followxpos 
		local ly = enemyypos - followypos 

		lx = followxpos - enemyxpos
		ly = followypos - enemyypos

		local viewdist	=	lx*lx + ly*ly

--		local th = -math.atan(ly/lx) 
--		if (lx < 0) then
--			th = th + math.pi 
--		end

		if (enemy.time < (enemy.pausetime or 0)) then
			Enemy.TurnHead(enemy,dt)
			Enemy.AttempFire(enemy,dt,viewdist)	
			return
		end
		
		
		if (enemy.realpath and enemy.tValue and (viewdist < 80*80 and not (enemy.follow and enemy.follow.subtype == 'flying'))) then
			enemy.pausetime	=	enemy.time + math.random(2,5)
		end
		
	
		if (enemy.realpath and enemy.tValue and (viewdist > 80*80 or (enemy.follow and enemy.follow.subtype == 'flying'))) then
			local	speedConst	=	enemy.realpath and (enemy.totalPathLength) or 1
			enemy.tValue	=	enemy.tValue + dt*(enemy.tSpeed or 1)/speedConst
			if (enemy.tValue > 1) then
				enemy.tValue = 0
				if (not enemy.realpath:IsClosed()) then
					enemy.back	 = not enemy.back
				end
			end
			enemy.realpath:CalcPosition(enemy.pos,enemy.tValue,enemy.back)
			Enemy._CalcDirection(enemy)

		elseif (enemy.class == 'flying') then
			Enemy._CalcDirection(enemy)
			--enemy.aimdirection	=	th*180/(math.pi) - 90
			enemy.aimdirection 		=	enemy.direction
			
			enemy.paratime 		= enemy.paratime + dt*(enemy.tSpeed)

			local radius	=	enemy.pRadius
			local k			=	enemy.pK
			local ptime		=	enemy.paratime*k + enemy.phase

			local ypos =	enemy.cy + (radius+cos(2*ptime))*cos(3*ptime)
			local xpos =	enemy.cx + (radius+cos(2*ptime))*sin(5*ptime)
			Enemy.SetPosition(enemy,xpos,ypos)
		end

		Enemy.TurnHead(enemy,dt)
		Enemy.AttempFire(enemy,dt,viewdist)	
			
	end
	
	function Enemy.AttempFire(enemy,dt,viewdist)	
		local turretdirection	=	(enemy.turret and enemy.turret.direction or enemy.direction)

		if Enemy.canfire and enemy.canfire and enemy.follow:IsAlive() and math.abs(turretdirection - enemy.targetbearing) < AIMTOL 
		and (viewdist < enemy.inviewdist) and (enemy.time - enemy.lastfired > enemy.fireperiod) then
			local enemyposx,enemyposy,_	=	enemy:GetPosition()
		
			local ox,oy = Enemy._MakeDirectionVectorPair(turretdirection,0,0,40)
			
			BulletManager.Fire(enemy,enemy.bulletdamage,enemyposx + ox,enemyposy + oy,enemy.bulletvelocity,Enemy.GetFiringDirection(enemy),enemy.bulletduration,nil,1)

			if (enemy.class == 'flying' and (enemy.nummissiles > 0) and (enemy.time - (enemy.lastmissile or 0) > enemy.missileperiod)) then
				if (MissileManager.AddHMissile( enemy, enemy.pos,80,enemy.direction,10,enemy.follow)) then
					enemy.lastmissile = enemy.time
					enemy.nummissiles = enemy.nummissiles - 1
				end
			end
			
			enemy.lastfired = enemy.time
		else
		--	enemy.canfire = false
		end
	
	end


	

	function Enemy._CalcDirection(enemy)

		-- Look in the direction we are moving
		local xpos,ypos,_ = Enemy.GetPosition(enemy)

		local dx = xpos - (enemy.lastx or 0)
		local dy = ypos - (enemy.lasty or 0)

		local th = math.atan2(dy,dx)  

		enemy.direction	=	math.deg(th) + 90

 		enemy.lastx	=	xpos
		enemy.lasty	=	ypos
	
	
	end
	



	function Enemy.Turn(enemy,dt)

		local	diff_vec	=	Temp.v0 
		Vector4.Subtract(diff_vec,enemy.follow:GetVectorPosition(), enemy:GetVectorPosition())
		diff_vec:Normalise2()

		-- Work out target bearing
		
		local rot_tar = math.atan2(diff_vec:Y(), diff_vec:X())
		rot_tar = (math.deg(rot_tar)	+ 90)
		enemy.targetbearing	=	rot_tar % 360

		enemy.angdistance = ((enemy.targetbearing - (enemy.aimdirection % 360)))

		enemy.leftangdist = ((360-enemy.targetbearing)	+ (enemy.aimdirection % 360)) % 360
		enemy.rightangdist = ((enemy.targetbearing + (360-(enemy.aimdirection % 360)))) % 360
		

		local	clockwiseDirection	=	(enemy.rightangdist < enemy.leftangdist) 
		
		
		if ( clockwiseDirection ~= enemy.currentAngularDir ) then
			enemy.currentAngularDir = clockwiseDirection
			enemy.currentAngularSpeed = 0.0
		end

		enemy.currentAngularSpeed = enemy.currentAngularSpeed +(dt * kENEMY_ANGULAR_ACCELERATION*enemy.turnrate)

		if ( enemy.currentAngularSpeed > kENEMY_MAXTURNANGLE ) then
			enemy.currentAngularSpeed = kENEMY_MAXTURNANGLE
		end
		
		local maxTurnAngle = enemy.currentAngularSpeed * dt
		
		if(math.min(enemy.rightangdist,enemy.leftangdist)>maxTurnAngle) then
		
			if (clockwiseDirection) then
				enemy.aimdirection = (enemy.aimdirection + maxTurnAngle) % 360

			else
				-- go anti clockwise
				enemy.aimdirection = (enemy.aimdirection - maxTurnAngle) % 360
			end

		else
			enemy.aimdirection = enemy.targetbearing
		end

	end

	-- Radar Zone Trap Alerts
	function Enemy.EntityEntered(enemy,entity)
	--	assert(false,entity.className)
--		enemy.state		=	1
	end

	function Enemy.EntityLeft(enemy,entity)
	--	assert(false,entity.className)
--		enemy.state		=	0
	end
	

	function Enemy.Render(enemy,rHelper)

		if (enemy:IsAlive()) then

			local epos = enemy:GetVectorPosition()
			local xpos,ypos	=	epos:X(),epos:Y()

			local scale	=	 (enemy.scale or 0.5)		-- (enemy.scale)*(1-0.05*math.random())

			for _,part in pairs(enemy.parts) do
				--local ang = (part.ctype=='turret') and enemy.targetbearing or part.direction
				local ang	=	 part.direction
				EnemyPart.Render(part,rHelper,xpos,ypos,-ang,scale)
			end
			if (enemy.mission and not enemy.dormant) then
				-- Render Mission marker
			--	RenderHelper.DrawCircle(rHelper,xpos, ypos, 32,{255,255,0,60})
				RenderHelper.DrawTexture(rHelper,"smmissionmarker",xpos+32,ypos)
			end
		end
		
		if (@REVEALENEMYSTRENGTH@) then
			Enemy.RenderStrength(enemy,rHelper)
		end
		
	--	Enemy.RenderRegion(enemy,rHelper)
		
		if (enemy.class == 'flying' and Enemy.debug) then
 			Enemy.RenderFlightPath(enemy,rHelper)
		end
		

	end
	
	function Enemy.RenderRegion(enemy,rHelper)
		local epos = enemy:GetVectorPosition()
		local xpos,ypos	=	epos:X(),epos:Y()
		RenderHelper.DrawText(rHelper,xpos, ypos, string.format("Region: %02d",Enemy.GetRegion(enemy)),1,{red=127,green=127,blue=127,alpha=127})
	end
	
--	function Enemy.Render(enemy,rHelper)
--		if (enemy:IsAlive()) then
--			local epos = enemy:GetVectorPosition()
--			local xpos,ypos	=	epos:X(),epos:Y()
--			RenderHelper.DrawCircle(rHelper,xpos, ypos, 32,{255,255,0,60})
--		end
--	end
	
	function Enemy.RenderFlightPath(enemy,rHelper)

		local radius	=	enemy.pRadius
		local k			=	enemy.pK
		
		for time = 0,40,0.1 do
			local ptime		=	time*k + enemy.phase
			local ypos =	enemy.cy + (radius+cos(2*ptime))*cos(3*ptime)
			local xpos =	enemy.cx + (radius+cos(2*ptime))*sin(5*ptime)
			RenderHelper.DrawCircle(rHelper,xpos, ypos, 2,{255,255,0,60})
		end

	end
	
	function Enemy.RenderOLD(enemy,rHelper)

		if (enemy:IsAlive()) then

			local epos = enemy:GetVectorPosition()
			local xpos,ypos	=	epos:X(),epos:Y()

			for _,anim in pairs(enemy.animations) do
				RenderHelper.DrawTexture(rHelper,anim:GetRenderTexture(),xpos,ypos,-enemy.direction ,enemy.scale or 0.5)
			end

			if (Enemy.debug) then
				Enemy.RenderDebug(enemy,rHelper)
			end

		end

		
		
	end



	
	function Enemy.RenderDebug(enemy,rHelper)
		local epos = enemy:GetVectorPosition()
	 	RenderHelper.SetColour(rHelper, enemy.colour or {255, 0, 0, 128} )
		RenderHelper.DrawCircle(rHelper,epos:X(), epos:Y(), enemy.radius or 4)
		Enemy._RenderArrowHead(rHelper,enemy.direction,epos,40,45,{255,0,0,255})
		RenderHelper.DrawText(rHelper,string.format("@ %.1f,%.1f dir = %d",epos:X(),epos:Y(),enemy.direction),epos:X(),epos:Y(),1,{red=128,green=0,blue=0,alpha=128})
		
		if (true) then
			return
		end
		
		local pstr	=	Enemy.GetPropertiesString(enemy)

		RenderHelper.DrawText(rHelper,"Name: "..enemy.name.."\n"..pstr..enemy.pathCN..' target bearing = '..(enemy.targetbearing or 0).." DIRECTION = "..enemy.direction,epos:X()+enemy.radius, epos:Y())
		RenderHelper.DrawText(rHelper," angdist = "..(	enemy.angdistance or 0)
			..' leftang = '..(enemy.leftangdist or 0)..' rightangdist ='..(enemy.rightangdist or 0),epos:X()+enemy.radius, epos:Y()+80)
	
		if (enemy.attached) then
			--assert(false,enemy.attached:toString())
			--enemy.attached:Render(rHelper)
		end
		
	end

	function Enemy._RenderArrowHead(rHelper,direction,baseVector,stemLength,tipAngle,colour)
		

		local xbase,ybase	=	baseVector:X(),baseVector:Y()

		local tipLength		=	stemLength*0.20

		local ly = ybase + stemLength*sin(rad(direction - 90))
		local lx = xbase + stemLength*cos(rad(direction - 90))

		local t1y = tipLength*sin(rad(direction - 90 + tipAngle))
		local t1x = tipLength*cos(rad(direction - 90 + tipAngle))

		local t2y = tipLength*sin(rad(direction - 90 - tipAngle))
		local t2x = tipLength*cos(rad(direction - 90 - tipAngle))


		RenderHelper.DrawLine(rHelper,xbase, ybase, lx,ly,colour)
		RenderHelper.DrawLine(rHelper,lx, ly, lx-t1x, ly-t1y,colour)
		RenderHelper.DrawLine(rHelper,lx, ly, lx-t2x, ly-t2y,colour)
	end
	
	
	function Enemy.GetPropertiesString(enemy)
		return Enemy._GetProperties(enemy.properties)
	end
	
	function Enemy._GetProperties(properties)	
		local str 			=	{}
		table.insert(str,"PROPERTIES\n")
		for property,propvalue in pairs(properties) do
			table.insert(str,property.." = "..Enemy._GetValueString(propvalue).."\n")
		end
		table.insert(str,"\n")
		return table.concat(str)
	end

	function Enemy._GetValueString(value)
		local t = type(value)
		if (t == 'boolean') then
			return value and 'true' or 'false'
		elseif (t == 'table') then
			return "{table} ="..Enemy._GetProperties(value)
		elseif (t == 'string') then
			return "'"..value.."'"
		else
			return value
		end
	end
	
	
	-- Collision Stuff
	
	function Enemy.IsColliding(enemy,x,y,rrad)
		local pradsq	=		rrad and rrad*rrad or 0
		local dx,dy		=		(x - enemy.pos:X()),(y - enemy.pos:Y())
		local d			=		dx * dx + dy * dy
		return d < pradsq + enemy.radsq
	end


	function Enemy.IsCollidingPoly(enemy,px,py)
		local epos = enemy:GetVectorPosition()
		local xpos,ypos	=	epos:X(),epos:Y()
	
		for _,part in pairs(enemy.parts) do
			local isturret = (part.ctype=='turret')
			local ang =  isturret and enemy.targetbearing or part.direction
			if not isturret and EnemyPart.CollidePoly(part,xpos,ypos,px,py,-ang,enemy.scale) then
				return true
			end
		end
		return false

	end
	
	function Enemy.IsCollidingLine(enemy,line2d)
		-- TODO
		return false
	end
	
	function Enemy.RenderStrength(enemy,renderHelper)
		local xpos,ypos		=	enemy:GetPosition()
		local	strfract	=	enemy.strength/255
		local   hgtfract	=	0.125
		
		local 	uvs	=	{
							0,0,
							0,hgtfract,
							strfract,hgtfract,
							strfract,0
						}
						
		RenderHelper.DrawTextureUvs(renderHelper,"strengthbar",xpos,ypos-32,uvs)
	end
	
	
	function Enemy.GetRegion(enemy)
		return	EnemyManager.GetRegion(Enemy.GetPosition(enemy))
	end

	function Enemy.InNeighbouringRegion(enemy,region)
		return EnemyManager.NeighbouringRegions(Enemy.GetRegion(enemy),region)
	end
	
end
