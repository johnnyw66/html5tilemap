-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not PlayerLandVehicle) then
PlayerLandVehicle				=	{}
PlayerLandVehicle.className	=	"Player"

PlayerLandVehicle.STEPX		=	8
PlayerLandVehicle.STEPY		=	8

PlayerLandVehicle.STATE_ALIVE	=	0

local kENEMY_MAXTURNANGLE			=	360.0
local kENEMY_ANGULAR_ACCELERATION	=	360.0
local FULLSTRENGTH					=	255

local BULLETDEBOUNCE				=	0.5
local MISSILEDEBOUNCE				=	2
local INDESTRUCTIBLE_DURATION		=	30
local RAPIDFIRE_DURATION			=	30
local TURRETFIXEDDURATION			=	2		-- number of seconds fix on turret direction - from last turret move or turret fire (bullet)
local rad			=	math.rad
local deg			=	math.deg
local sin			=	math.sin
local cos			=	math.cos
local sqrt			=	math.sqrt

local scalearound	=	0.95
local sunangle		=	22

local COLLISIONLENGTH	=	32

	local function causeEvent(player,event)
		if (player.eventMgr) then
			player.eventMgr(event,player)
		end
	end


	function PlayerLandVehicle.Create(eventMgr,properties,name,tilemap,x,y,direction,dynamics,physics)
		Logger.lprint("PlayerLandVehicle.Create")
	
		local player = {
				id					=	1,
				x 					=	x or 0,
				y					=	y or 0,
				z					=	0,
				eventMgr			=	eventMgr,
				dynamics			=	dynamics or LandDynamics,
				physics				=	physics,
				radius				=	16,
				state 				=	PlayerLandVehicle.STATE_ALIVE,	
				direction			=	direction,
				blade				=	0,
				wanteddirection		=	direction,
				turretbearing		=	direction,
				lastturretmove		=	direction,
				bodySprite			=	nil,
				bladeSprite			=	nil,
				currentAngularSpeed =	0.0,
				currentAngularDir	=	true,
				hoverFreq			=	0.25,
				velx				=	0,
				vely				=	0,
				analhor				=	0,
				analvert			=	0,
				time				=	0,
				moving				=	false,
				lastbulletshot		=	0,
				lastmissileshot		=	0,
				turretfixed			=	false,
				tilemap				=	tilemap,
				chaff				=	4,
				mapDim				=	TileMap.GetMapDimensions(tilemap),
				alive				=	true,
				strength			=	FULLSTRENGTH,
				bulletdamage		=	80,	
				missiledamage		=	100,
				bulletdebounce		=	BULLETDEBOUNCE,
				homingmissiles		=	4,
				parts				=	{},
				lives				=	3,
				damagemultiplier	=	1,
				subtype				=	'land',
				rapidfire			=	false,
				debug				=	false,
				properties			=	properties,
				name				=	name,
				className			=	PlayerLandVehicle.className,
		}

		setmetatable(player, { __index = PlayerLandVehicle }) 
	
		PlayerLandVehicle.Init(player)
		causeEvent(player,"PlayerCreated")
		return player 

	end

	function PlayerLandVehicle.GetGameData(player)
		return {lives=player.lives,homingmissiles = player.homingmissiles,chaff = player.chaff}
	end

	function PlayerLandVehicle.RestoreGameData(player,data)
		player.lives			=	data.lives	or 3
		player.chaff			=	data.chaff	or 4
		player.homingmissiles	=	data.homingmissiles	or 4
	end

	function PlayerLandVehicle.Respawn(player)
		player.alive		=	true
		player.strength		=	FULLSTRENGTH
		causeEvent(player,"AlivePlayerLandVehicle")
	end

	function PlayerLandVehicle.GetChaff(player)
		return player.chaff	
	end
	
	function PlayerLandVehicle.GetLives(player)
		return player.lives	
	end

	function PlayerLandVehicle.IncrementLives(player)
		player.lives	=	player.lives + 1
	end

	function PlayerLandVehicle.DecrementLives(player)
		if player.lives > 0 then
			player.lives	=	player.lives - 1
		end
	end
	
	function PlayerLandVehicle.GetFiringOffset(player)
		return {ox = 0, oy = 0, oz = 0}
	end

	function PlayerLandVehicle.GetPosition(player)
		return	player.x,player.y,player.z
	end

	function PlayerLandVehicle.GetVectorPosition(player)
		return	Vector4.Create(player.x,player.y,player.z)
	end
	
	function PlayerLandVehicle.GetX(player)
		return player.x 
	end
	
	function PlayerLandVehicle.GetY(player)
		return player.y 
	end
	
	function PlayerLandVehicle.GetZ(player)
		return player.z
	end
	
	function PlayerLandVehicle.GetDirection(player)
		return player.direction 
	end

	function PlayerLandVehicle.GetMissileDirection(player)
		return player.turretbearing
	end

	function PlayerLandVehicle.GetDirectionPair(player,size)
		local v =  PlayerLandVehicle._MakeDirectionVector(player.direction,size)
		return v:X(),v:Y()
	end
	
	function PlayerLandVehicle.GetState(player)
	   	return player.state
	end
	
	function PlayerLandVehicle.IsAlive(player)
		return player.alive
	end
	
	function PlayerLandVehicle.ApplyDamage(player,damage)
		local ddamage	=	(damage or 0)*(@PLAYERINDESTRUCTIBLE@ and 0 or player.damagemultiplier)
		player.strength 	= 	math.max(0,player.strength - ddamage)
		if (player.strength <= 0 and player:IsAlive()) then
			player:Kill(true)
			player:DecrementLives()
		end
	end
	
	function PlayerLandVehicle.Finish(player)
		causeEvent(player,"FinishPlayerLandVehicle")
	end

	
	function PlayerLandVehicle.Kill(player,explode)
		player.alive	=	false
		causeEvent(player,"KillPlayerLandVehicle")
		if (explode) then
			local xpos,ypos,zpos	=	player:GetPosition()
			for _,part in pairs(player.parts) do
				local explosions = part:GetExplosions()
				if (explosions) then
					for _,explode in pairs(explosions) do
						ExplosionManager.AddExplosion({x = xpos + (explode.x or 0), y = ypos + (explode.y or 0), z = zpos})
					end
				end
			end
			ExplosionManager.AddExplosion({x = xpos , y = ypos , z = zpos})
		end
		
	end
	

	
	
	
	function PlayerLandVehicle.Init(player)
	
		local properties 			=	player.properties
		assert(properties,'PLAYER MUST HAVE PROPERTIES DEFINED')
		player.radius				=	properties.radius or player.radius
		player.scale				=	properties.scale or 1
		player.damagemultiplier		=	properties.damagemultiplier or (1-math.min(1,math.max(0,(properties.shield or 0))))
		player.odamagemultiplier	=	player.damagemultiplier 
		player.bulletdamage			=	properties.bulletdamage or player.bulletdamage
		player.bulletduration		=	(properties.bulletduration or 1) 
		player.bulletvelocity		=	(properties.bulletvelocity or 400) 
		player.missiledamage		=	properties.missiledamage or player.missiledamage
		player.bulletdebounce		=	(properties.firerate and 1/properties.firerate) or  BULLETDEBOUNCE
		player.obulletdebounce		=	player.bulletdebounce
		player.missiledebounce		=	(properties.missilerate and 1/properties.missilerate) or  MISSILEDEBOUNCE
		player.turretlength			=	(properties.turretlength or 24) 
		player.colllength			=	properties.collisionlength or (player.name == 'playervehicle1' and 32 or 48)
		

		--assert(false,player.direction)
		player.radsq		=	player.radius*player.radius
	
		player.bodySprite = Sprite.Create()
		player.turretSprite = Sprite.Create()
		player.crossHairSprite = Sprite.Create()



		local classname		=	player.name	
		local parts			=	EnemyData[classname] or {{frames = {"outhouse4"}}}
		assert(parts,'NO PARTS DEFINITION FOR '..classname)
		local numParts		=	#parts
		local partsStr		=	{}
		
		for partIndex,part in pairs(parts) do
			table.insert(partsStr,part.frames[1])
		end
	
		local frames  		=	parts[1].frames
		local fps			=	parts[1].fps or 10
		
		local texture = Texture.Find(parts[1].frames[1])
		Sprite.SetTexture(player.bodySprite,texture)

		print("Number of Frames "..#frames.." FPS = "..fps)
		local	tanim  = TextureAnim.Create(#frames,fps)

		for idx,frameName in pairs(frames) do
		--	print("FrameName "..idx.." = "..frameName)
			tanim:AddFrame(frameName)
		end
		
		player.bodyanimation	=	tanim
		
		player.bodyanimation:Play(true)

		local texture = Texture.Find(parts[2].frames[1])
		Sprite.SetTexture(player.turretSprite,texture)
		
		player.turretx,player.turrety 	=		parts[2].offset.x,  parts[2].offset.y
		
		
		
		local plywidth	=	texture:GetWidth() 
		local plyheight	=	texture:GetHeight() 
		
		local texture = Texture.Find("crosshair")
		Sprite.SetTexture(player.crossHairSprite,texture)

		player.minx				=	plywidth/2
		player.miny				=	plyheight/2

		player.maxx				=	player.mapDim:X() - plywidth/2
		player.maxy				=	player.mapDim:Y() - plyheight/2
		player.targetbearing	=	player.direction 
		player.lastx			=	0
		player.lasty 			=	0
		
		
		player.rapidfire		=	false
		
		local heading			=	player.direction

		PlayerLandVehicle.Respawn(player)
		
		Missile.SetMissileLength(properties.missilelength or 320)
		
		Vehicle.Init({x = player.x, y = player.y, name = player.name},player.dynamics or SimpleLandDynamics,player.direction,player.physics)
		
	end

	function PlayerLandVehicle.Indestructible(player,indesvalue)
		player.damagemultiplier	=	indesvalue or player.odamagemultiplier
	end

	function PlayerLandVehicle.Destructible(player)
		player.damagemultiplier	=	player.odamagemultiplier
	end
	
	function PlayerLandVehicle.ShowPlayerShieldIcon(player)
		return Util.ShowIcon(player.time,player.startshield,INDESTRUCTIBLE_DURATION)
	end

	function PlayerLandVehicle.ShowPlayerRapidFireIcon(player)
		return Util.ShowIcon(player.time,player.startrapid,RAPIDFIRE_DURATION)
	end

	function PlayerLandVehicle.CollectPickup(player,pickupType)
		Logger.lprint('PlayerLandVehicle.CollectPickup:'..(pickupType or 'unknown'))
		
		if (pickupType == 'extralife') then
			player:IncrementLives()
		elseif(pickupType == 'chaff') then
			player.chaff = player.chaff + 1
		elseif(pickupType == 'timeshift' or pickupType == 'extratime') then
			causeEvent(player,"TimeShift")
		elseif(pickupType == 'powerup') then
			player.strength = FULLSTRENGTH
		elseif(pickupType == 'partialdamage') or (pickupType == 'indestructible') then
				local mf	=	pickupType == 'indestructible' and 0 or 0.125
				player.startshield	=	player.time
				player:Indestructible(mf)
				EventManager.AddSingleShotEvent(
					function(player)
						-- Ignore any events which have been overridden by gathering new pickups
						-- The 0.5 is here because of small (Game DeltaTime) discrepancies between EventManager Times
						-- and Player updates
						if (player.time - player.startshield >= INDESTRUCTIBLE_DURATION - 0.5) then
							player:Destructible()
						end
					end,
				player,INDESTRUCTIBLE_DURATION)
		elseif(pickupType == 'homingmissile') then
			player.homingmissiles	=	player.homingmissiles + 1
		elseif(pickupType == 'rapidfire') then

			player.bulletdebounce	=	player.obulletdebounce/2

			player.rapidfire		=	true
			player.startrapid		=	player.time
			
			
			EventManager.AddSingleShotEvent(
				function(player)
					-- Ignore any events which have been overridden by gathering new pickups
					-- The 0.5 is here because of small (Game DeltaTime) discrepancies between EventManager Times
					-- and Player updates
					if (player.time - player.startrapid >= RAPIDFIRE_DURATION - 0.5) then
						player.bulletdebounce	=	player.obulletdebounce
						player.rapidfire		=	false
					end	
				end,
				player,RAPIDFIRE_DURATION)
		end
		
		
	end
	
	local function CollideTileMap(player,tileMap,pixx,pixy)

		if (TileMap.IsCollideable(tileMap,pixx,pixy)) then
			local cpoly = TileMap.GetCollisionPoly(tileMap,pixx,pixy)
			if (cpoly) then
				local cx,cy = TileMap.GetCentreCoords(tileMap,pixx,pixy)
				local poly	= cpoly and cpoly.polygon
				if (poly:IsPointInside(pixx-cx,pixy-cy)) then
					table.insert(player.collisions,{x = pixx,y = pixy, polygon = poly, cx = cx, cy = cy})
					return true
				else
					return false
				end
			else
				return true
			end
		else
			return false
		end
	end

	local function CollideTileMap2(player,tileMap,pixx,pixy)
		assert(player.className == 'Player','OH NO NOT A PLAYER:'..player.className)
		assert(tileMap.className == 'TileMap','OH NO NOT A TileMAP')
		if (TileMap.IsCollideable(tileMap,pixx,pixy)) then
			local cpoly = TileMap.GetCollisionPoly(tileMap,pixx,pixy)
			if (cpoly) then
				local cx,cy = TileMap.GetCentreCoords(tileMap,pixx,pixy)
				local poly	= cpoly and cpoly.polygon
				if (poly:IsPointInside(pixx-cx,pixy-cy)) then
					table.insert(player.collisions,{x = pixx,y = pixy, polygon = poly, cx = cx, cy = cy})
					return true
				else
					return false
				end
			else
				return true
			end
		else
			return false
		end
		return false
	end

	function PlayerLandVehicle.HasMoved(player)
		return (player.lastx ~= player.x or player.lasty ~= player.y)
	end
	
	function pack(...)
	      return { ... }, select("#", ...)
	end
	
	-- Brakes On - used for end of game sequence..
	
	function PlayerLandVehicle.BrakesOn(player)
		Vehicle.BrakesOn()
	end


	function PlayerLandVehicle.Update(player,dt)
		
		player.collx,player.colly	=	0,0
		if (not player:IsAlive()) then
			return
		end


		player.time = player.time + dt  
		
		-- fix turret if no turret movement
		if (player.time > player.lastturretmove + TURRETFIXEDDURATION) then
				player.turretfixed	=	true
		end
		
		
		local olddirection 	= 	player.direction 
		local oldx			=	player.x
		local oldy			=	player.y
		local oldspeed		=	Vehicle.GetSpeed()
		local maxspeed		=	Vehicle.GetMaxSpeed()

		player.bodyanimation:Update(dt*oldspeed/maxspeed)

		
		Vehicle.Update(dt)

		local acc		=	{}
		local loc		= 	Vehicle.GetPosition()
		acc.x			=	loc.x
		acc.y			=	loc.y
		acc.direction	=	Vehicle.GetHeading()
		local speed		=	Vehicle.GetSpeed()
		local collisionlength	=	player.colllength
		
		player.collisions	=	{}
		local pangle		=	speed >= 0 and acc.direction or (acc.direction + 180)
		local collx,colly	=	PlayerLandVehicle._MakeDirectionVectorPair(pangle,acc.x,acc.y,collisionlength)
--		local collx2,colly2	=	PlayerLandVehicle._MakeDirectionVectorPair(pangle+22,acc.x,acc.y,collisionlength)
	
		player.collx,player.colly	=	collx,colly
--		player.collx2,player.colly2	=	collx2,colly2
		
		if (not CollideTileMap2(player,player.tilemap,collx,colly) 
			--	and not CollideTileMap2(player,player.tilemap,collx2,colly2) 
			-- and
			--not CollideTileMap2(player,player.tilemap,PlayerLandVehicle._MakeDirectionVectorPair(player.direction+180,acc.x,acc.y,collisionlength)) 
			--and
			--not CollideTileMap2(player,player.tilemap,PlayerLandVehicle._MakeDirectionVectorPair(player.direction+90,acc.x,acc.y,16)) and
			--not CollideTileMap2(player,player.tilemap,PlayerLandVehicle._MakeDirectionVectorPair(player.direction-90,acc.x,acc.y,16))
		) 
		and (	not EnemyManager.IsCollidingGroundEnemies(collx,colly) 
				--and
				--and
				--not EnemyManager.IsCollidingGroundEnemies(PlayerLandVehicle._MakeDirectionVectorPair(player.direction+90,acc.x,acc.y,16)) 
				--and
				--not EnemyManager.IsCollidingGroundEnemies(PlayerLandVehicle._MakeDirectionVectorPair(player.direction-90,acc.x,acc.y,16)) 
			) 
		then
			player.x			=	acc.x
			player.y			=	acc.y
			player.direction	=	acc.direction
			
		else
			Vehicle.SetPositionXY(oldx,oldy)	
			Vehicle.SetHeading(olddirection)	
			Vehicle.SetSpeed(0)
			Vehicle.Recalc()	

		end
		
		Vehicle.SetTurretAngle(player.turretbearing)
	
		player.tipx,player.tipy	=	PlayerLandVehicle._MakeDirectionVectorPair(player.direction,player.x,player.y,32)
		
		if (player.turretfixed) then
			player.turretbearing	=	player.direction
		end
		PlayerLandVehicle.LockCrossHair(player)

	end
		
	
	function PlayerLandVehicle._MakeDirectionVector(angle,size)
		local rsize	=	size or 1
		local ny= -rsize*sin(rad(angle + 90))
		local nx= -rsize*cos(rad(angle + 90))
		return Vector4.Create(nx,ny)
	end

	function PlayerLandVehicle._MakeDirectionVectorPair(angle,xpos,ypos,size)
		local rsize	=	size or 1
		local ny= -rsize*sin(rad(angle + 90))
		local nx= -rsize*cos(rad(angle + 90))
		return xpos+nx,ypos+ny
	end

	function PlayerLandVehicle._CalcDirection(player)

		-- Look in the direction we are moving
		local xpos,ypos,_ = PlayerLandVehicle.GetPosition(player)

		local dx = xpos - (player.lastx or 0)
		local dy = ypos - (player.lasty or 0)

		local th = math.atan2(dy,dx)  

 		player.lastx	=	xpos
		player.lasty	=	ypos
		return deg(th) + 90
	end	
	
	function PlayerLandVehicle.CalcScreenStuff(player)
	--	player.x / totalMapWidth
	--	player.y / totalMapHeight
	end
	
	

	function PlayerLandVehicle.Restrict(player)
		if (player.x < player.minx) then
			player.x = player.minx
		end
	
		if (player.x > player.maxx) then
			player.x = player.maxx
		end
	
		if (player.y < player.miny) then
			player.y	=	player.miny
		end
		if (player.y > player.maxy) then
			player.y	= player.maxy
		end
	
	end
	
	
	function PlayerLandVehicle.PlayerUp(player)
		player.analvert	=	-1
	end
	
	function PlayerLandVehicle.PlayerDown(player)
		player.analvert	=	1
	end
	
	function PlayerLandVehicle.PlayerLeft(player)
		player.analhor	=	-1
	end

	function PlayerLandVehicle.PlayerRight(player)
		player.analhor	=	1
	end


	function PlayerLandVehicle.PlayerSelect(player)
		player:BulletSelect(player.turretbearing)
	end


	local function rotate(x,y,angle)
			local rangle	=	math.rad(angle)
	--	
			local cos = math.cos(rangle) 
			local sin = -math.sin(rangle)

			local nx = x*cos - y*sin 
			local ny = x*sin + y*cos

			return nx,ny
	--		return 0,0
	end
	
	function PlayerLandVehicle.BulletSelect(player,direction)
	
		if (not player.lastbulletshot or player.time > player.lastbulletshot  + player.bulletdebounce) then

			local cdirection	= 	direction or player.turretbearing
			local pos			=	Vector2.Create(player.x,player.y)
			local bulletdamage	=	player.bulletdamage
			local tx,ty			=	rotate(player.turretx,-player.turrety,-player.direction)
			local turretLength	=	player.turretlength	
			local dx,dy			=	rotate(0,-turretLength,-player.turretbearing)	
			
			local animationPackage = RenderHelper.CreateAnimationPackage(2,1,"bullets_landsmall",12)
			
			BulletManager.Fire(player,bulletdamage,player.x+tx+dx,player.y+ty+dy,player.bulletvelocity,cdirection,player.bulletduration,animationPackage,1)
			
			--	EventManager.AddSingleShotEvent(
			--	function(par)
			--		BulletManager.Fire(player,bulletdamage,player.x+10,player.y+10,400,cdirection,8,animationPackage,1)
			--		BulletManager.Fire(player,bulletdamage,player.x-10,player.y-10,400,cdirection,8,animationPackage,1)
			--		
			--	end,
			--	nil,0.25)
			
			player.lastbulletshot	=	player.time
			
			player.turretfixed		=	false
			player.lastturretmove	=	player.time
			
		end
	end


	local function fireMissile(player)
		local MISSILEDAMAGE		=	player.missiledamage
		local pos			=		Vector2.Create(player.x,player.y)
	
		if (MissileManager.AddMissile( player, pos, MISSILEDAMAGE,  true)) then
		
			EventManager.AddSingleShotEvent(
					function(par)
						MissileManager.AddMissile( player, pos, MISSILEDAMAGE,  false)
					end,
					nil,0.25)
			
			player.lastmissileshot	=	player.time
			return true
		else
			return false
		end
		
	end

	local function fireHMissile(player,target)
		local MISSILEDAMAGE		=	player.missiledamage*4.5
		local pos				=	Vector4.Create(player.x,player.y)
	
		if (MissileManager.AddHMissile( player, pos, MISSILEDAMAGE,0,15,target)) then
			player.lastmissileshot	=	player.time
			return true
		else
			return false
		end
	end

	function PlayerLandVehicle.GetLocked(player)
		return (player.homingmissiles > 0) and player.ontarget
	end

	function PlayerLandVehicle.GetNumberOfHomingMissiles(player)
		return player.homingmissiles
	end
	

	function PlayerLandVehicle.LockCrossHair(player)
		EnemyManager.LockCrossHair(Missile.MISSILE_LEN)
	end
	
	function PlayerLandVehicle.UnLockCrossHair(player)
		EnemyManager.UnLockTarget()
	end
	
	function PlayerLandVehicle.MissileSelect(player)
	
		if (not player.lastmissileshot or player.time > player.lastmissileshot  + player.missiledebounce) then

			if (player.homingmissiles > 0 and player.ontarget and not player.ontarget.dormant) then
				if (fireHMissile(player,player.ontarget)) then
					player.homingmissiles	=	player.homingmissiles - 1
					PlayerLandVehicle.UnLockCrossHair(player)
				end
			else
				fireMissile(player)
			end
		end
		
	end
	
	

	function PlayerLandVehicle.XXXMissileSelectXXX(player)
	
		if (not player.lastmissileshot or player.time > player.lastmissileshot  + player.missiledebounce) then
			local MISSILEDAMAGE		=	player.missiledamage
			
			local tx,ty			=	rotate(player.turretx,-player.turrety,-player.direction)	
			
			local pos			=	Vector2.Create(player.x+tx,player.y+ty)
			
			MissileManager.AddMissile( player, pos, MISSILEDAMAGE,  true)
			
				EventManager.AddSingleShotEvent(
				function(par)
					MissileManager.AddMissile( player, pos, MISSILEDAMAGE,  false)
				end,
				nil,0.25)
			player.lastmissileshot	=	player.time
		end
		
	end
	
	function PlayerLandVehicle.ChaffSelect(player)
		if (player.chaff > 0) then
			player.chaff = player.chaff - 1
	 		for i = 1, 5	do
				EventManager.AddSingleShotEvent(
				function()
					local x,y = player:GetPosition()
					for z = 1, 5 do
					EventManager.AddSingleShotEvent(
						function()	
		 					local direction = 	player.direction + math.random(0,90) - 45 + 180
		 					local velx		=	96*math.sin(math.rad(direction)) 	
		 					local vely		=	-96*math.cos(math.rad(direction)) 
	 						local prt 		=	ParticleManager.AddChaff(x,y,velx,vely,math.random(2,3) + 3)
							MissileManager.Tease(prt)
						end,
					nil,
					z*0.125*0.5)		
					end
				end,
				nil,
				i*0.25
				)
	 		end
		end
	end
	
	
	

	
	
	function PlayerLandVehicle.Render(player,renderHelper,x,y)

		
		if (player:IsAlive()) then
			PlayerLandVehicle.RenderBody(player,renderHelper,x,y)
			if (player.debug) then
				PlayerLandVehicle.RenderDebug(player,renderHelper,x,y)
			end
			
		end
--		RenderHelper.DrawCircle(renderHelper,player.collx or 0,player.colly or 0,4,{255,255,0})
--		RenderHelper.DrawCircle(renderHelper,player.collx2 or 0,player.colly2 or 0,4,{255,255,255})
--		Vehicle.Render(renderHelper)

	end
	
	function PlayerLandVehicle.RenderDebug(player,renderHelper,x,y)
		PlayerLandVehicle.RenderMove(player,renderHelper)
		local xpos,ypos	=	player.x,player.y
		RenderHelper.DrawCircle(renderHelper,xpos,ypos, player.radius,{255, 0, 0, 128})
		if (player.tipx) then
			local cx,cy = TileMap.GetCentreCoords(player.tilemap,player.tipx,player.tipy)
			RenderHelper.DrawCircle(renderHelper,cx,cy,4,{255,255,0})
		end
--		RenderHelper.DrawText(renderHelper,string.format("REGION = %02d, x,y = %.2f,%.2f",(player:GetRegion() or -1),xpos,ypos),xpos,ypos)
	end

	function PlayerLandVehicle.RenderMove(player,renderHelper)
		local move = player.move
		if (move) then
			local xtip,ytip		=	PlayerLandVehicle._MakeDirectionVectorPair(player.direction,0,0,player.colllength)
			RenderHelper.DrawLine(renderHelper,xtip+move.oldx,ytip+move.oldy,xtip+move.x,ytip+move.y,{0,255,0})
			RenderHelper.DrawCircle(renderHelper,xtip+move.oldx,ytip+move.oldy,4,{0,255,0})
			RenderHelper.DrawCircle(renderHelper,xtip+move.x,ytip+move.y,4,{255,255,0})
		end
		
		if (player.collisions) then
			for _,col in pairs(player.collisions) do
				RenderHelper.DrawLine(renderHelper,col.x,col.y,col.cx,col.cy,{red=127,green=0,blue=127,alpha=127})
				--RenderHelper.DrawCircle(renderHelper,col.cx,col.cy,10,{255,0,255})
				--local str = (col.polygon and string.format("%f,%f",col.polygon.x,col.polygon.y) or "NONE")
				--RenderHelper.DrawText(renderHelper,str,col.cx,col.cy+20)	
			end
			
		end
		
	end
	
	function PlayerLandVehicle.RenderShadow(player,renderHelper,x,y)
			local xpos,ypos	=	player.x,player.y
			local extra		=	scalearound - player.scale
			local shadowoffx,shadowoffy	=	PlayerLandVehicle._MakeDirectionVectorPair(180+player.direction+sunangle,xpos,ypos,40)
			RenderHelper.DrawSprite(renderHelper,player.shadowSprite,shadowoffx,shadowoffy,0.85*(1 + extra),-(player.direction or 0))
	end
	
	
	
	function PlayerLandVehicle.RenderBodyPart(player,renderHelper,scale)
		local xpos,ypos			=	player.x, player.y
		local scale,direction 	=	(scale or player.scale),-(player.direction or 0)
		local sprite			=	player.bodySprite
		local animation			=	player.bodyanimation
		
		
		local tid 	= animation:GetRenderTexture()
		local uvs	= tid.uvs

		if (uvs) then
			assert(false,'UVS NOT SUPPORTED')
			Sprite.SetUvs(sprite,
				uvs.tlu,uvs.tlv,
				uvs.blu,uvs.blv,
				uvs.bru,uvs.brv,
				uvs.tru,uvs.trv
			)
		
			RenderHelper.DrawSprite(renderHelper,sprite,xpos,ypos,scale,direction)
		
		else
			RenderHelper.DrawTexture(renderHelper,tid,xpos,ypos,direction,scale)
		end

	end
	
	
	
	function PlayerLandVehicle.RenderBodyDEPRECATED(player,renderHelper,x,y)
	
		local xpos,ypos		=	x or player.x, y or player.y
		local tx,ty			=	rotate(player.turretx,-player.turrety,-player.direction)	
		
		RenderHelper.DrawSprite(renderHelper,player.bodySprite,xpos,ypos,player.scale,-(player.direction or 0))
		RenderHelper.DrawSprite(renderHelper,player.turretSprite,xpos+tx,ypos+ty,player.scale,-player.turretbearing)
--		RenderHelper.DrawText(renderHelper,string.format("REGION = %d, %.2f,%.2f",(player:GetRegion() or -1),xpos,ypos),xpos,ypos)
--		Heart.PlotPlayer(renderHelper,player,WorldClock.GetClock())

		PlayerLandVehicle.RenderCrossHair(player,renderHelper)
		PlayerLandVehicle.RenderStrength(player,renderHelper)
		Hud.DrawDirection(renderHelper)
	end
	

	function PlayerLandVehicle.RenderBody(player,renderHelper,x,y)


		local xpos,ypos		=	x or player.x, y or player.y
		local tx,ty			=	rotate(player.turretx,-player.turrety,-player.direction)	
		local scale			=	player.scale*(1-0.05*math.random())
		--RenderHelper.DrawSprite(renderHelper,player.bodySprite,xpos,ypos,player.scale,-(player.direction or 0))

		PlayerLandVehicle.RenderBodyPart(player,renderHelper,scale)
		
		RenderHelper.DrawSprite(renderHelper,player.turretSprite,xpos+tx,ypos+ty,scale,-player.turretbearing)

		PlayerLandVehicle.RenderCrossHair(player,renderHelper)
		PlayerLandVehicle.RenderStrength(player,renderHelper)
		Hud.DrawDirection(renderHelper)

	end
	
	function PlayerLandVehicle.RenderCrossHair(player,renderHelper)
		local tx,ty			=	rotate(player.turretx,-player.turrety,-player.direction)	
		local xpos,ypos		=	player.x+tx,player.y+ty
		local	amp			=	sin(6*player.time*(player.chfreq or 0.25))
		local xhair,yhair	=	PlayerLandVehicle._MakeDirectionVectorPair(player.turretbearing,xpos,ypos,Missile.MISSILE_LEN)
		RenderHelper.DrawSprite(renderHelper,player.crossHairSprite,xhair,yhair,0.75*amp,-(player.turretbearing or 0))
	end

	function PlayerLandVehicle.RenderStrength(player,renderHelper)
		local xpos,ypos		=	player.x,player.y
		local	strfract	=	player.strength/FULLSTRENGTH
		local   hgtfract	=	0.125
		
		local 	uvs	=	{
							0,0,
							0,hgtfract,
							strfract,hgtfract,
							strfract,0
						}
						
		RenderHelper.DrawTextureUvs(renderHelper,"strengthbar",xpos,ypos-32,uvs)
	end



    function PlayerLandVehicle.AngleMove(player,analx,analy)
		local d		=	sqrt(analx*analx + analy*analy)

		if (d > 0.5) then
			local angle				=	math.deg(math.atan2(analy,analx))
			player.turretbearing 	=	angle + 90
			PlayerLandVehicle.BulletSelect(player,player.turretbearing)
			player.lastturretmove	=	player.time
			player.turretfixed		=	false
			Vehicle.SetTurretAngle(player.turretbearing)
		end
	--	Logger.lprint("D = "..d.." angle = "..angle) 
		
   	end
  	
	function PlayerLandVehicle.AxisMove(player,analx,analy)
		player.analhor    =	analx or 0
		player.analvert	  =	analy or 0
		Vehicle.AxisMove(player.analhor,player.analvert)
   	end

  	
	function PlayerLandVehicle.GetJoystickXAxis(player)
		local hor = player.analhor
		player.analhor = 0
		return hor
	end


	function PlayerLandVehicle.GetJoystickYAxis(player)
		local vert = player.analvert
		player.analvert = 0
		return vert
	end
	
	
	-- Collision
	
	function PlayerLandVehicle.IsColliding(player,x,y,rrad)
		local radsq	=		rrad and rrad*rrad or 0
		local dx,dy		=		(x - player.x),(y - player.y)
		local d			=		dx * dx + dy * dy
--		if (d < radsq + player.radsq) then
--			assert(false,' '..dx.." dy "..dy.." d "..d.." radsq "..radsq.." player.radsq "..player.radsq)
--		end
		return d < radsq + player.radsq
	end
	
	
	
	function PlayerLandVehicle.GetRegion(player)
		local region = EnemyManager.GetRegion(player:GetPosition())
		return	region
	end
	
	function PlayerLandVehicle.InNeighbouringRegion(player,region)
		return EnemyManager.NeighbouringRegions(player:GetRegion(player),region)
	end
	
	
	
end
