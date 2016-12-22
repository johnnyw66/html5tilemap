-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not MissileManager then

MissileManager = { }
MissileManager.className="MissileManager"
local 	MAXHOMINGMISSILES		=	2
local 	MAXPLAYERHOMINGMISSILES	=	2
local 	MAXNORMALMISSILES		=	4

local	missiles	=	{}
local 	player		=	nil
local 	normalmissiles			=	0
local 	homingmissiles			=	0
local 	playerhomingmissiles	=	0

	
local	enabled			=	true
local   callback		=	nil
	function MissileManager.Init( ply,cb )
		player	=	ply
		enabled	=	true
		callback	=	cb
		MissileManager.Reinit()
	end


  	function MissileManager.Reinit()
		missiles	=	{}
		homingmissiles			=	0
		playerhomingmissiles	=	0
		normalmissiles			=	0
	end

	function MissileManager.Allow()
		enabled		=	true
	end

	function MissileManager.Disallow()
		enabled		=	false
	end
	

	function MissileManager.AddMissile( firedby, pos, damage,  left )
		if (enabled and normalmissiles < MAXNORMALMISSILES) then
			local isplayer 	=	firedby == player
			local missile = Missile.Create( pos,  damage,  isplayer, left, firedby:GetMissileDirection())
			normalmissiles	=	normalmissiles + 1
			table.insert(missiles,missile)
			if (callback) then
				callback(missile,'fire')
			end
			return true
		end
		return false
	end

 
	function MissileManager.AddHMissile( firedby, pos, damage,  rot, lifespan, who)
		
		local isplayer 	=	firedby == player
		local rotation	=	firedby.direction - 90
		local missile	=	nil
		
		if (enabled) then
			if (isplayer and who) then
				if (playerhomingmissiles < MAXPLAYERHOMINGMISSILES) then
					missile = HomingMissile.Create( pos ,  rotation,  who,  damage, lifespan or 15)
					playerhomingmissiles	=	playerhomingmissiles + 1
				end
			else
				if (homingmissiles < MAXHOMINGMISSILES) then
					missile = HomingMissile.Create( pos ,  rotation,  who or player,  damage, lifespan or 15)
					homingmissiles	=	homingmissiles + 1
				end
			end
			if (missile) then
				table.insert(missiles,missile)
				if (callback) then
					callback(missile,'fire')
				end
				return true
			end
		end
		return false
	end
			
	function MissileManager.GetHomeMissilesFired()
		return playerhomingmissiles,MAXPLAYERHOMINGMISSILES
	end

	function MissileManager.Tease(me)

		for idx,missile in pairs(missiles) do
			if (missile.className == 'HomingMissile' and (missile.following and missile.following.className == 'Player')) then
				HomingMissile.Follow(missile,me)
				if (callback) then
					callback(missile,'chaffmiss')
				end
				return
			end
		end
		
	end
	
	function MissileManager.ReleaseMissile(missile)
       	if (callback) then
			callback(missile,'free')
		end
    end
    

	function MissileManager.Update(dt)
		
		local removeList	=	{}		
		local activeList	=	{}		

		for idx,missile in pairs(missiles) do
		
			local collision_line = missile:GetCollisionLine(dt)
			
			missile:Update(dt)
			
			if (missile:IsMarkedForDeath()) then
				table.insert(removeList,missile)
				if (missile.className == 'Missile') then
					normalmissiles	=	normalmissiles - 1
				else
					if (missile.following and missile.following.className ~= 'Player') then
						playerhomingmissiles	=	playerhomingmissiles - 1
					else
						homingmissiles	=	homingmissiles - 1
					end
				end
			else
				table.insert(activeList,missile)

				local	bx,by	=	missile:GetCoords()
				local 	homing	=	missile.className == HomingMissile.className
				
				if (missile.isPlayer) then	
					local enemy = (homing and player.ontarget) and EnemyManager.IsCollidingEnemy(player.ontarget,bx,by,40) or EnemyManager.IsColliding(bx,by,0)

					--if (homing and player.ontarget) then
					--	enemy	=	EnemyManager.IsCollidingEnemy(player.ontarget,bx,by,40)
					--else
					--	enemy	=	 EnemyManager.IsColliding(bx,by,0)
					--end
					
					if (enemy) then
						enemy:ApplyDamage(missile.damage)
						missile:ApplyDamage(300)
						if (callback) then
							callback(missile,missile.className == Missile.className and 'hitenemy' or 'hmhitenemy')
						end
					end
				else
					if (player:IsColliding(bx,by,0)) then
						player:ApplyDamage(missile.damage)
						missile:ApplyDamage(300)
						if (callback) then
							callback(missile,'hitplayer')
						end
					end
				end
				
			end
		end
		
		-- Clean up current List
		missiles	=	activeList	
		
	end
	
	
	function MissileManager.Render( renderHelper)
		for idx,missile in pairs(missiles) do
			missile:Render(renderHelper)
		end
	
	end
	
	function MissileManager.Cleanup()
		MissileManager.Reinit()
	end
	
	
end
