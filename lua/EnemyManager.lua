-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not EnemyManager)  then

EnemyManager = { }

EnemyManager.className	=	"EnemyManager" 
EnemyManager.time 		=	0 
local ICON_RETICLE		=	"reticle"
local modf				=	math.modf
local lockedon			=	nil

local regionWidth,regionHeight,regionsAcross,regionsDown

	function EnemyManager.Init(enemies,player,screenDim,mapDim,cb)
		lockedon				=	nil
		EnemyManager.localsize	=	0
		EnemyManager.time 		=	0 
		EnemyManager.enemies 	=	enemies
		EnemyManager.player		=	player
		EnemyManager.screenDim	=	screenDim
		EnemyManager.mapDim		=	mapDim
		EnemyManager.callback	=	cb or function(ev,p)  SoundManager.SoundHook(ev) end
		EnemyManager.CalcRegions()
		EnemyManager._BuildLocalList()
		EnemyManager.AllowFire()
	
	end
	
	function EnemyManager.SetDefaultPickups(pickups)
			Enemy.SetDefaultPickups(pickups)
	end
	

	local function causeEvent(ev,par)
		if (EnemyManager.callback) then
			EnemyManager.callback(ev,par)
		end
		
	end
	
	local function _MakeDirectionVectorPair(angle,xpos,ypos,size)
		local rsize	=	size or 1
		local rang	=	math.rad(angle + 90)
		local ny= -rsize*math.sin(rang)
		local nx= -rsize*math.cos(rang)
		return xpos+nx,ypos+ny
	end
	
	local DEFAULTCROSSHAIR_FREQUENCY	=	0.25
	local RAPIDCROSSHAIR_FREQUENCY		=	2.25
	
	
	

	
	function EnemyManager.LockTarget(enemy)
		lockedon		=	enemy
		local player	=	EnemyManager.player
		player.ontarget	=	enemy
	--	player:ChangedCrossHairFreq(RAPIDCROSSHAIR_FREQUENCY)
		player.chfreq	=	RAPIDCROSSHAIR_FREQUENCY
	
		causeEvent("locked")
	end

	function EnemyManager.UnLockTarget()
		local player	=	EnemyManager.player
		lockedon		=	nil
		player.ontarget	=	nil
		--player:ChangedCrossHairFreq(DEFAULTCROSSHAIR_FREQUENCY)
		player.chfreq	=	DEFAULTCROSSHAIR_FREQUENCY
		
		causeEvent("unlocked")
	end
	
	local function isPotentialNewTarget(enemy,xhair,yhair)
		return (not enemy.dormant and enemy:IsAlive() and enemy ~= lockedon and Enemy.IsColliding(enemy,xhair,yhair,10))
	end
	

	function EnemyManager.IsLocal(enemy)
		-- TODO SPEED THIS UP!
		local player	=	EnemyManager.player
		return EnemyManager.NeighbouringRegions(enemy:GetRegion(),player:GetRegion())	
		--return true
	end
	
	function EnemyManager.LockCrossHair(missileLen)

		local player	=	EnemyManager.player
		if (lockedon and (not lockedon.localobject or lockedon.dormant or not lockedon:IsAlive() or not EnemyManager.IsLocal(lockedon))) then
			EnemyManager.UnLockTarget()
			return 
		end
	
		local yocals = EnemyManager.GetLocalEnemies()
		local player		=	EnemyManager.player
		local xhair,yhair	=	_MakeDirectionVectorPair(player.direction,player.x,player.y,Missile.MISSILE_LEN)
		
		for _,enemy in pairs(yocals) do
			if (isPotentialNewTarget(enemy,xhair,yhair)) then
				EnemyManager.LockTarget(enemy)
				return 
			end
		end
		
	end

	
	function EnemyManager.AllowFire()
		Enemy.canfire		=	true
	end
	
	function EnemyManager.DisallowFire()
		Enemy.canfire		=	false
	end
	
	function EnemyManager.Update(dt)
    	EnemyManager.time = EnemyManager.time + dt 

		-- Update Enemy
		local removelist = {}

		local localEnemies	=	EnemyManager.GetLocalEnemies()
		
		for idx,enemy in pairs(localEnemies) do
			enemy:Update(dt)
			if (not enemy:IsAlive()) then
				table.insert(removelist,idx)		-- place global idx in list
			end
		end
		-- Get rid of the chaff
		for _,idx in pairs(removelist) do
			EnemyManager._RemoveEnemy(localEnemies[idx])
		end

		EnemyManager._BuildLocalList()
		
	end
	


	function EnemyManager.IsCollidingGroundEnemies(x,y)
		local localEnemies	=	EnemyManager.GetLocalEnemies()
		
		for idx,enemy in pairs(localEnemies) do
		
			if (enemy.class ~= 'flying') then
				if (not enemy.dormant and enemy:IsCollidingPoly(x,y,enemy.radius or 4)) then
					return enemy
				end
			end
		end
		return false
	end

	function EnemyManager.IsCollidingAirEnemies(x,y)
		local localEnemies	=	EnemyManager.GetLocalEnemies()
		for idx,enemy in pairs(localEnemies) do
			if (enemy.class == 'flying') then
				if (not enemy.dormant and enemy:IsColliding(x,y,4)) then
					return enemy
				end
			end
		end
		return false
	end
	
	function EnemyManager.IsCollidingEnemy(enemy,x,y,rad)
		if (not enemy.dormant and enemy:IsColliding(x,y,rad or 10)) then
			return enemy
		end
		return nil
	end
	
	function EnemyManager.IsColliding(x,y,rad)
		local localEnemies	=	EnemyManager.GetLocalEnemies()
		for idx,enemy in pairs(localEnemies) do
			if (not enemy.dormant and enemy:IsColliding(x,y,rad)) then
				return enemy
			end
		end
		return nil
	end
	
	function EnemyManager.RenderGround(rHelper)
		local localEnemies	=	EnemyManager.GetLocalEnemies()
		for idx,enemy in pairs(localEnemies) do
			if (enemy.class ~= 'flying') then
				enemy:Render(rHelper)
			end
		end
	end

	function EnemyManager.RenderLocked(rHelper)
		local player = EnemyManager.player 
		local locked		=	player.alive and player.GetLocked and player:GetLocked()
		if (locked and locked.alive) then
			local x,y,z = locked:GetPosition()
			RenderHelper.DrawTexture(rHelper,ICON_RETICLE,x,y, 0,1+0.5*math.sin(6*EnemyManager.time*2))
			--RenderHelper.DrawText(rHelper,ICON_RETICLE,x,y,0.75)
			--	RenderHelper.DrawCircle(rHelper,x,y, 16+8*math.sin(6*EnemyManager.time*2),{255,64,0,64})
		end
	end
	
	function EnemyManager.RenderAir(rHelper)
		local localEnemies	=	EnemyManager.GetLocalEnemies()
		for idx,enemy in pairs(localEnemies) do
			if (enemy.class == 'flying') then
				enemy:Render(rHelper)
			end
		end
	end
	
	
	function EnemyManager._RemoveEnemy(enemy)
		assert(EnemyManager.enemies[enemy.idx] == enemy,'SOMETHING GONE WRONG HERE!')
		EnemyManager.enemies[enemy.idx]	=	nil
		
	end

	function EnemyManager._BuildLocalList()
		EnemyManager.localenemies	=	EnemyManager.enemies
	end
		
	function EnemyManager._BuildLocalList()
		local localEnemies		=	{}
		EnemyManager.localsize			=	0
		
		local enemies =	EnemyManager.enemies
		local playerRegion	=	EnemyManager.player:GetRegion()
		for idx,enemy in pairs(enemies) do
			if (enemy:InNeighbouringRegion(playerRegion)) then
				enemy.localobject	=	true
				enemy.idx		=	idx		-- mark current idx in full enemy table
				table.insert(localEnemies,enemy)
				EnemyManager.localsize			=	EnemyManager.localsize	+ 1
			else
				enemy.localobject	=	false
			end
			
		end
		EnemyManager.localenemies	=	localEnemies

	end
	
	
	
	function EnemyManager.GetLocalEnemies()
		return EnemyManager.localenemies	
	end
	

	local function round(num)
	    local floor = math.floor(num)
	    local ceiling = math.ceil(num)
	    if (num - floor) >= 0 then
	        return ceiling
	    end
	    return floor
	end

	function EnemyManager.NeighbouringRegions(region1,region2)	
		return EnemyManager.neighbourhoodTable[region1][region2] 
	end
	
	-- Comment out this function below if you want localised updates/rendering
	function EnemyManager.XNeighbouringRegions(region1,region2)	
		return true or EnemyManager.neighbourhoodTable[region1][region2] 
	end
	
	function EnemyManager.GetRegion(pixx,pixy)
			local regionAcross	=	modf(pixx/regionWidth)
			local regionDown	=	modf(pixy/regionHeight)
			return regionDown*regionsAcross + regionAcross	
	end
	
	
	function EnemyManager.BuildNeighhoodTable(numberOfColumns,numberOfRows)
	
	--	assert(false,string.format("nemyManager.BuildNeighhoodTable cols=%d,rows%d",numberOfColumns,numberOfRows))
		local neighbourTable = {}

		local _CA = function(col,row)
						local screensPerRow	=	numberOfColumns
						local screenNumber	=	((row  - 1)* screensPerRow + (col -1)) 
						return screenNumber		
					end
					
		for row = 1, numberOfRows do
			for column = 1, numberOfColumns do

				neighbours = {}
				if (row + 1) <= numberOfRows then
					table.insert(neighbours, _CA(column, row + 1))
					if (column + 1 <= numberOfColumns) then
						table.insert(neighbours, _CA(column + 1, row + 1))
					end
					if (column - 1 > 0) then
						table.insert(neighbours, _CA(column - 1, row + 1))
					end
				end
				if (row - 1) > 0 then
					table.insert(neighbours, _CA(column, row - 1))
					if (column + 1 <= numberOfColumns) then
						table.insert(neighbours, _CA(column + 1, row - 1))
					end
					if (column - 1 > 0) then
						table.insert(neighbours, _CA(column - 1, row - 1))
					end
				end
				if (column + 1 <= numberOfColumns) then
					table.insert(neighbours, _CA(column + 1, row))
				end
				if (column - 1 > 0) then
					table.insert(neighbours, _CA(column - 1, row))
				end

				local ca = _CA(column,row)
				neighbourTable[ca]	=	{}
				neighbourTable[ca][ca] = true	
				
				for k,nghbr in pairs(neighbours) do
					neighbourTable[ca][nghbr] = true	
				end
				
			end
		end
		return neighbourTable
	end
	
	function EnemyManager.CalcRegions()
		regionWidth	=	EnemyManager.screenDim:X()*1.25
		regionHeight	=	EnemyManager.screenDim:Y()*1.25
		regionsAcross	=	round(EnemyManager.mapDim:X()/regionWidth)
		regionsDown		=	round(EnemyManager.mapDim:Y()/regionHeight)
	
		EnemyManager.neighbourhoodTable = EnemyManager.BuildNeighhoodTable(regionsAcross,regionsDown)
		
		

	end
	
end

