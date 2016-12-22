if (not Game) then
Game			=	{ }
Game.className	= 	'Game'

Resource.Run("LoadSource")

-- Temp Vectors			
local sprPos				=	Vector4.Create(0,0)
local tmpCam				=	Vector4.Create()


local GAMEOVERANNOUNCEMENTDURATION	=	5			-- TODO move to Constants.lua
local REPORTDURATION				=	60			-- TODO move to Constants.lua

local quitKey						=	0

-- Game State Constants

local	STATE_MENU		=	0
local	STATE_LOADASSETS	=	1
local	STATE_LEVELINTRO	=	2
local	STATE_LEVELOUTRO	=	3
local	STATE_PLAY			=	10
local	STATE_ANNOUNCE		=	11
local	STATE_RESTART		=	12
local	STATE_TESTAUDIO		=	80

local	STATE_PAUSED		=	98

local 	STATE_GAMEOVER		=	99

-- This table must consist of all the names for 
local lookupEnemyNames		=	{}

local radar					--	Radar Object
local gMap,sMap,dMap		--  Layered TileMaps (to be deprecated)

--  objects holding in game data - refer to DAME editor for
-- 	more details

local maps,paths,sprites,players,shapes,tileMap

local camera				=	nil
local player				=	nil				--	
local screenDim				=	nil
local mapDim				=	nil
local renderHelper			=	nil
local gameObject			=	nil
local time					=	0
local maxNasties			=	250


local enemies				=	{}				-- List of Nasties

local   FIRSTSTATE			=	@TESTAUDIO@ and STATE_TESTAUDIO or STATE_MENU

local	state				=	FIRSTSTATE		-- Current Game State STATE_MENU	
local 	laststate			=	FIRSTSTATE

local 	timeToComplete		=	0				-- time to complete current state (in seconds)
local barT					=	0				-- Bar Loading Timer

local MAXLOADASSETSDURATION	=	5				-- TODO Set this in Constants
local gameData				=	nil				-- Player's last game, game data.


	-- As define in DAME tile editor, game designer
	-- can produce a list of start places
	-- for our player object.
	-- Pick one of these positions and select
	-- the player Type.
	
	-- Returns start position (x,y,z),
	-- PlayerType table ('object')
	-- and LandDynamics object type (SimpleLandDynamics or LandDynamics)
	
	local function PickPositionAndType(plylist,dim)
		local pPos,pType,pDynamics,pPhysics	=	{x = dim:X()/2, y = dim:Y()/2, z = 0, angle=0},(PlayerHelicopter),(nil),(nil)
		local properties,name	=	nil,'unknown'

		if (plylist and #plylist > 0) then
			ply			=	plylist[math.random(1,#plylist)]
			name 		=	ply.name

			properties			=	ply.properties
			local physicsStr	=	properties.physics

			pPhysics	=	 physicsStr and Util.BuildLuaTable(physicsStr or "") or {}
			
			
			if (name == 'playerHelicopter') then
				pType	=	PlayerHelicopter
			
			elseif(name == 'playervehicle1') then
				
				pType		=	PlayerLandVehicle
				pDynamics	=	SimpleLandDynamics
			
			elseif(name == 'playervehicle2') then
				
				pType	=	PlayerLandVehicle
				pDynamics	=	SimpleLandDynamics
				
			elseif(name == 'playervehicle3') then
				pType	=	PlayerHelicopter
			else
				pType	=	PlayerHelicopter
			end
			pPos.x,pPos.y,pPos.z	=	ply:GetPosition(ply)
			pPos.angle				=	ply.angle
		end
		
		return properties,name,pPos,pType,pDynamics,pPhysics
	end
	

	-- Call Back for PopUp Messages
	function Game.PopUpEvent()
		SoundManager.SoundHook("PopupMessage","PopupMessageEvent")
	end

	-- Call Back for Bullet Fire/Explosion
	
	function Game.BulletEvent(bullet,event)
		if (event == 'fire') then
			SoundManager.SoundHook("BulletFired","BulletEvent")
		else
			-- bullet destroyed
			SoundManager.SoundHook("BulletDestroyed","BulletEvent")
		end
		
	end

	-- Call Back for Missile Explosion
	
	function Game.MissileEvent(missile,event)

		if (event == 'chaffmiss') then
			-- Chaff has managed to tease missile away from player
			SoundManager.SoundHook("MissileTeased","MissileEvent")
			
			
		elseif (event == 'hmhitenemy') then
			-- 'HOMING MISSILE HIT ENEMY'

		elseif (event == 'hitenemy') then
			-- 'NORMAL MISSILE HIT ENEMY'

		elseif (event == 'hitplayer') then

		elseif (event == 'fire') then
			SoundManager.SoundHook("MissileFired","MissileEvent")
		else
			SoundManager.SoundHook("MissileDestroyed","MissileEvent")
		end
	end


	function Game.ExplosionEvent(event)
		SoundManager.SoundHook("Explosion"..(event or '?'),"ExplosionEvent")
	end

	-- Call Back for Pickup Collection
	
	function Game.PickupEvent(pickup,by,event)
		if (event == 'collected') then
			SoundManager.SoundHook("PickupCollected","PickupEvent")
		elseif (event == 'spawned') then
			SoundManager.SoundHook("PickupGenerated","PickupEvent")
		else 
			SoundManager.SoundHook("PickupRemoved","PickupEvent")
		end
	end


	-- Call Back for Score Event 
	
	function Game.ScoreEvent(event,score)
		
		SoundManager.SoundHook(event,"ScoreEvent")
		
	--	if (event == 'BestScore') then
	--
	--	end
	--	elseif (event == )
	--		SoundManager.SoundHook("StartNextRound","ScoreEvent")
	--	end
		
	end

	-- Call Back for Hud Event 
	
	function Game.HudEvent(event,bool)
		SoundManager.SoundHook(event..(bool and "_True" or "_False"),"HudEvent")
	end

	-- Call Back for Enemy Event 
	
	function Game.EnemyEvent(event,enemy)
		SoundManager.SoundHook(event,"EnemyEvent")
	end

	-- Call Back for Player Event 

	function Game.PlayerEvent(event,player)
		
		SoundManager.SoundHook(event,"PlayerEvent")
		if (event == "TimeShift") then
			MissionManager.ExtraTime()
		end
		
	end

	-- Call Back for MenuBoard Event 

	function Game.MenuBoardEvent(event)
		SoundManager.SoundHook(event,"MenuBoardEvent")
		if (event == "AllMissionsCompleted") then
			-- Reset Missions and Scores
			Levels.ResetAll()
			Game.DeletePlayerGameData()
			ScoreManager.Init(Game.ScoreEvent)
		end
		
	end
	
	
	function Game.Play(levName,dimx,dimy,reset)
		Logger.lprint("GAME PLAY "..(reset and 'RESET IS TRUE' or 'RESET IS FALSE'))
		
		local lName	=	levName or "LEVEL_JUNGLE1test"	
		Game.ChangeState(STATE_LOADASSETS) --MAXLOADASSETSDURATION,STATE_LEVELINTRO)
		
		AssetLoader.ReleaseAll()

		
		AssetLoader.LoadAssets(lName,
			function(list,failed)
				Logger.lprint("GroupName "..lName)
				local luaFile =AssetLoader.GetLuaAssetName(lName)	

				Game._Init(luaFile,dimx,dimy)
				Game.RestorePlayerGameData()
				
				SoundManager.FadeToGameMusic()
				
				if (reset) then
					Logger.lprint(">>>>>>>>><<<<<<<<<<<<<<<<>>>>>>>>>>RESET SCOREMANAGER!")
					ScoreManager.Init(Game.ScoreEvent)
				else
					ScoreManager.StartRound()
				end
				Game.ChangeState(STATE_LEVELINTRO,15,STATE_PLAY)
				Util.MemoryDebug()
			end
		)
	end
	


	function Game._Init(levName,dimx,dimy)
		
		screenDim					=	Vector4.Create(dimx or 1024,dimy or 720)
		renderHelper 				=	RenderHelper.Create(screenDim)

		Game.LoadFonts()	

		local lName							=	levName or "LEVEL_JUNGLE1test"
		maps,paths,sprites,players,shapes	=	MapReader.loadLevel(lName)

		AssetLoader.Release(levName)
		local defaultPickups		=	maps[1].mapinfo.properties and maps[1].mapinfo.properties.defaultpickup
		mapDim						=	Vector4.Create(maps[1].mapinfo.width,maps[1].mapinfo.height)
		tileMap						=	maps[1] and TileMap.Create(maps[1],screenDim)
		local 	properties,classname,pPos,playerType,pDynamics,pPhysics	=	PickPositionAndType(players,mapDim)
		player 						=	playerType.Create(Game.PlayerEvent,properties,classname,tileMap,pPos.x,pPos.y,pPos.angle,pDynamics,pPhysics)
		camera						=	Camera.Create(screenDim,mapDim)
		cameraorbitor				=	CameraOrbitor.Create(screenDim,mapDim)		-- used for end of game sequences

		--radar						=	Radar.Create(screenDim:X()-60,10+60,1280,60)

		

		camera:Follow(player,true)
		RenderHelper.SetOverlay(renderHelper,1)
		RenderHelper.SetCamera2dPosition(renderHelper,Vector4.Create(0,0))
		RenderHelper.SetOverlay(renderHelper,0)
		
		enemies						=	{}

		for idx,enemy in pairs(sprites) do
			enemy:SetTarget(player)
			enemy:SetDefaultPickups(defaultPickups)	
			table.insert(enemies,enemy)
		end

		Game.InitJoySticks()
		Game.InitManagers()

		--Game.Tests()
		Game.InitEnemyNames()
		
		Logger.lprint("Loaded #maps "..#maps.." #shapes "..#shapes.." #sprites "..#sprites.." #paths "..#paths)
	end
	
	function Game.TestExplosion()
		local x,y,z	=	player:GetPosition()
		ExplosionManager.AddExplosion({x = x,y = y, z = z})
		EventManager.AddSingleShotEvent(Game.TestExplosion,nil,5)
	end
	
	function Game.Tests()
	
		assert(EventManager and EventManager.AddSingleShotEvent,'What the hell?')
		
		EventManager.AddSingleShotEvent( function()
				--  DisplayableText.Create(text,pos2DVector,scale,halign,valign,colour)      
					MessageManager.Add(Message.Create(DisplayableText.Create('COME ON JOHN',nil,4),SpringBox.Create(screenDim:X()/2,screenDim:Y()/2,-100,nil,nil,nil,3)),true)
					if (love) then
						gameObject:_FocusOff(object)
						EventManager.AddSingleShotEvent( function()
								gameObject:_FocusOn()
							end,nil,5)
					end
			end,nil,10)
		
	end
	
	
	-- Initialise ALL Managers
	-- need to do this before running any level.
	
	function Game.InitManagers()
		EventManager.Init()

		MissionManager.Init(shapes,Game.MissionEventCallBack)
		TriggerManager.Init(shapes)
		BulletManager.Init(player,Game.BulletEvent)

		
		MessageManager.Init(Game.PopUpEvent)
		
		MissileManager.Init(player,Game.MissileEvent)

		PickupManager.Init(player,Game.PickupEvent)
	
		ExplosionManager.Init(player,Game.ExplosionEvent)

		ParticleManager.Init()
		
		EnemyManager.Init(enemies,player,screenDim,mapDim,Game.EnemyEvent)
		
		MenuBoard.Init(renderHelper,ScoreManager,Game.MenuBoardEvent)			-- renderHelper is passed for text formatting
		
		SoundManager.Init(true)
		
		Hud.Init(player,ScoreManager,MissionManager,MissileManager,Game.HudEvent)

		Easter.Init(
			function(idx)
				Logger.lprint("Easter Egg Granted "..(idx or -1))
				if (idx == 1 and player.Indestructible) then
					player:Indestructible(0)
					player.startshield	=	player.time
				end
			end
		)
		

		Levels.Init()
		
	end


	-- CallBack which handles Mission Events
	-- Starting, Completing or Failing.
	-- Callback is triggered with the mission Object
	-- and the 'reason' for the event - (a string).
		
	function Game.MissionEventCallBack(mission,reason)
	
		local MISSIONMESSAGESIZE	=	4
		local MISSIONMESSAGECOLOUR	=	{red=0,green=127,blue=0,alpha=127}

		--  DisplayableText.Create(text,pos2DVector,scale,halign,valign,colour)      

		local message	=	"?"
		if (reason == 'MISSIONSTART') then
			SoundManager.SoundHook("MissionStart","GameEvent")
		
			message	=	Mission.GetMissionText(mission) or 'MISSION START TEXT MISSING'

		elseif (reason == 'MISSIONTIMELOW') then
			SoundManager.SoundHook("MissionTimeLow","GameEvent")
			message	=	Locale.GetLocaleText('LOW ON TIME!')
			
		elseif (reason == 'MISSIONCOMPLETE') then
			SoundManager.SoundHook("MissionCompleted","GameEvent")
			lastMissionWasASuccess	=	true
			message	=	Mission.GetCompletedText(mission) or 'MISSION COMPLETED TEXT MISSING'
			ScoreManager.AddScore(mission:GetMissionCompletedBonus())
--			missionsCompleted	=	missionsCompleted + 1
			Game.ChangeState(STATE_GAMEOVER,GAMEOVERANNOUNCEMENTDURATION,STATE_LEVELOUTRO)
			if (@REVEALGAMEMAP@) then
				EventManager.AddSingleShotEvent( function()
										camera:Follow(cameraorbitor,false)
								end,
								nil,
								GAMEOVERANNOUNCEMENTDURATION*0.8)
			end
										
			ScoreManager.TallyUp()
			MenuBoard.SendScore()
			Levels.LevelComplete()
			Game.BrakesOn()
			Game.FinishUpGame()
			Game.SavePlayerGameData()
			EnemyManager.DisallowFire()
				
			EventManager.AddSingleShotEvent( function()
					if (Levels.AllLevelsCompleted()) then
						MenuBoard.ShowAllMissionsCompleted()
					else
						MenuBoard.ShowScore()
					end
					Game.ChangeState(STATE_MENU)
				end,nil,GAMEOVERANNOUNCEMENTDURATION+REPORTDURATION)
			
		elseif (reason == 'MISSIONFAILED') then
			SoundManager.SoundHook("MissionFailed","GameEvent")
			lastMissionWasASuccess	=	false

			message	=	Mission.GetFailedText(mission) or 'MISSION FAILED TEXT MISSING'
			Game.ChangeState(STATE_GAMEOVER,GAMEOVERANNOUNCEMENTDURATION,STATE_LEVELOUTRO)
			camera:Follow(cameraorbitor,false)
			ScoreManager.TallyUp()	
			MenuBoard.SendScore()
			Levels.LevelFailed()
			Game.BrakesOn()
			Game.FinishUpGame()
			Game.DeletePlayerGameData()
			EnemyManager.DisallowFire()

			EventManager.AddSingleShotEvent( function()
					MenuBoard.ShowScore()
					Game.ChangeState(STATE_MENU)
				end,nil,GAMEOVERANNOUNCEMENTDURATION+REPORTDURATION)
			
		end
		
		if (message) then
			MessageManager.Add(Message.Create(DisplayableTextWithImage.Create(message),
			SpringBox.Create(screenDim:X()/2,screenDim:Y()/2,-100,nil,nil,nil,3)),true)
		end
		

	end
	
	function Game.SavePlayerGameData()
		assert(player,'Game.SaveGameData:PLAYER IS NIL')
		gameData		=	player:GetGameData()
		Logger.lprint("GAMEDATA:LAST MISSION GAME DATA SAVED.")
		
	end


	function Game.BrakesOn()
		if (player) then
			Logger.lprint(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>BRAKESON and FINISH!!!")
			player:Finish()
			player:BrakesOn()
		end
	end

	function Game.DeletePlayerGameData()
		gameData		=	nil
	end
	
	function Game.RestorePlayerGameData()
		assert(player,'Game.RestoreGameData:GAME DATA HAS NOT BEEN SAVED OR PLAYER IS NIL')
		if (gameData) then
			Logger.lprint("GAMEDATA:LAST MISSION GAME DATA RESTORED")
			player:RestoreGameData(gameData)
			gameData = nil
		end
	end
	
	
	function Game.DeInitManagers()
		
	end
	

	function Game.DebugVector(v,msg)
		Logger.lprint(string.format("%s: %f %f\n",msg,v:X(),v:Y()))
	end
	
	function Game.ChangeState(newstate,duration,next)
		if (newstate) then
			state			=	newstate	
			timeToComplete	=	duration and (time + duration) or 0
			nextState		=	next
		end
	end
	
	
	

	function Game.PauseKeyCheck(dt)
		local pauseKeyPressed	=	Pad.WasJustPressed(Pad.GetPad(1),Constants.KEY_DEBUG)
		
		if (pauseKeyPressed) then
			if (state == STATE_PAUSED) then
				state	=	laststate
				Game.UnMuteSound()
			else
				laststate	=	state
				state = STATE_PAUSED
				Game.MuteSound()
			end
		end
		
		if (state == STATE_PAUSED) then
			EventManager.Update(dt)
			return true
		else
			return false
		end
		
	end
	
	--	Main Update Loop
	-- 	Called a particular Update function
	-- 	depending on the game's particular
	-- 	'state'
	
	function Game.Update(dt)
		
		if (@CABINET@) then
			local paused = not gameObject:HasFocus()
			if (paused) then
				if (not (state == STATE_PAUSED)) then
					laststate	=	state
					state = STATE_PAUSED
					Game.MuteSound()
				else
					--Logger.lprint("HMMMMM PAUSED!!!")
					EventManager.Update(dt)
				end
				return
			else
				if (state == STATE_PAUSED) then
					state	=	laststate
					Game.UnMuteSound()
				end
			end
		end
		
		if (Game.PauseKeyCheck(dt)) then
			return
		end
		
		
	
		time = time + dt
		
		
		MenuBoard.Update(dt)

		if (cameraorbitor) then
			CameraOrbitor.Update(cameraorbitor,dt)
		end
		
		if (state == STATE_RESTART) then
			if (player.lives > 0) then
				SoundManager.SoundHook("PlayerRespawn","GameEvent")
				MessageManager.Add(Message.Create(DisplayableTextWithImage.Create(Locale.GetLocaleText("GO FOR IT!")),
				SpringBox.Create(screenDim:X()/2,screenDim:Y()/2,-100,nil,nil,nil,3)),true)
				player:Respawn()
				Game.ChangeState(STATE_PLAY)
				EnemyManager.DisallowFire()
--				player:Indestructible()
				
				EventManager.AddSingleShotEvent( function()
								EnemyManager.AllowFire()
--								player:Destructible()
					end,nil,5)
				
			else
				lastMissionWasASuccess	=	false
			
				SoundManager.SoundHook("GameOver","GameEvent")
				MessageManager.Add(Message.Create(DisplayableTextWithImage.Create(Locale.GetLocaleText("GAME OVER")),
				SpringBox.Create(screenDim:X()/2,screenDim:Y()/2,-100,nil,nil,nil,3)),true)
				--Game.ChangeState(STATE_GAMEOVER,5,STATE_MENU)
				Game.ChangeState(STATE_GAMEOVER,GAMEOVERANNOUNCEMENTDURATION,STATE_LEVELOUTRO)
				camera:Follow(cameraorbitor,false)		
				EnemyManager.DisallowFire()
				ScoreManager.TallyUp()	
				MenuBoard.SendScore()
				Levels.LevelFailed()
				Game.BrakesOn()
				Game.FinishUpGame()
				Game.DeletePlayerGameData()
				
				EventManager.AddSingleShotEvent( function()
						MenuBoard.ShowScore()
						Game.ChangeState(STATE_MENU)
					end,nil,GAMEOVERANNOUNCEMENTDURATION+REPORTDURATION)
				
			end
		elseif (state == STATE_LEVELOUTRO)  or (state == STATE_GAMEOVER)  then
			-- We are panning round the level map
			-- Wait until the player wants to exit.
			Camera.Update(camera,dt)
			-- Fudges needed to Reduce Enemy Rendering 
			if (@REVEALGAMEMAP@) then
				player.x,player.y,player.z = Camera.GetPosition(camera)
				player.alive		=	false
				player:Indestructible()
			end

			player:Update(dt)
			EnemyManager.DisallowFire()
			EnemyManager.Update(dt)
			MissileManager.Update(dt)
			ExplosionManager.Update(dt)
			BulletManager.Update(dt)
			ParticleManager.Update(dt)
			
			local controller	=	Pad.GetPad(1)
			if (state ~= STATE_GAMEOVER and Pad.WasJustPressed(controller,Constants.KEY_SELECT)) then

				if (Levels.AllLevelsCompleted()) then
					MenuBoard.ShowAllMissionsCompleted()
				else
					MenuBoard.ShowScore()
				end
				
				Game.ChangeState(STATE_MENU)
				EventManager.Init()
			end
			
			
		elseif (state == STATE_LEVELINTRO) then
			
			Game.MissionStatementControllerUpdate(1)
		
	--	elseif (state == STATE_GAMEOVER) then

	--		Camera.Update(camera,dt)
	--		player.x,player.y,player.z = Camera.GetPosition(camera)
	--		player.alive		=	false
	--		EnemyManager.DisallowFire()
	--		EnemyManager.Update(dt)

		elseif (state == STATE_MENU) then
			Game.LevelMenuUpdate(dt)

		elseif (state == STATE_TESTAUDIO) then
			SoundManager._Update(dt)
		elseif (state == STATE_LOADASSETS) then
			AssetLoader.Update(dt)
		else
			Game.GameUpdate(dt)
		end
		
		-- Generic update code
		-- Update eventmanager,in game message popups
		-- clock and sound
		
		EventManager.Update(dt)
		MessageManager.Update(dt)
		WorldClock.Update(dt)
        SoundPlayer.Update(dt)

		if (state == STATE_PLAY and not player:IsAlive()) then
			SoundManager.SoundHook("PlayerKilled","GameEvent")
			MessageManager.Add(Message.Create(DisplayableTextWithImage.Create(Locale.GetLocaleText("PLAYER KILLED")),
			SpringBox.Create(screenDim:X()/2,screenDim:Y()/2,-100,nil,nil,nil,3)),true)
			Game.ChangeState(STATE_ANNOUNCE,5,STATE_RESTART)
		end
		
		if (timeToComplete > 0) and (time > timeToComplete) then
			Game.ChangeState(nextState)
		end


	end
		
	function Game.LevelMenuUpdate(dt)
		Levels.Update(dt)
		if (Levels.TimedOut()) then
			Game.Play(Levels.GetLevelChoiceString(),screenDim:X(),screenDim:Y(),not lastMissionWasASuccess)
		else
			Game.LevelMenuControllerUpdate(1)
		end
		
	end
	

	function Game.GameUpdate(dt)	
		-- Logger.lprint(" Local Enemies = "..#EnemyManager.localenemies)

		-- Simulate Killing all in our current Objective
		if (time > 5) then
--			MissionManager.KillAll()
		end
		
		Hud.Update(dt)

		if (radar) then
			Radar.Update(radar,dt,player,enemies)
		end
		
		if (state	==	STATE_PLAY and player:IsAlive()) then
			Game.PlayerControllerUpdate(1) 
		end
		
		player:Update(dt)

		TileMap.CalcScreenNumber(tileMap,player)

		PickupManager.Update(dt)

		EnemyManager.Update(dt)

		MissileManager.Update(dt,enemies)
		BulletManager.Update(dt,enemies,player)

		ExplosionManager.Update(dt)
		ParticleManager.Update(dt)

		for idx,shape in pairs(shapes) do
			shape:Update(dt)
		end
		
		Camera.Update(camera,dt)
		MissionManager.Update(dt)
		
		TriggerManager.Update(dt,player)

		--local pixx,pixy,_	=	player:GetPosition()
		-- TileMap.TestCollideable(tileMap,pixx,pixy)
		
	end
	
	
	--	STATE_LEVELINTRO	=	2
	--	STATE_LEVELOUTRO	=	3
	--	STATE_PLAY			=	10
	--	STATE_ANNOUNCE		=	11
	--	STATE_RESTART		=	12
	--	STATE_PAUSED		=	98
	-- 	STATE_GAMEOVER		=	99
	
--	local function ValidPauseState()
--		return laststate == STATE_PLAY or 
--	end
	

	function Game.Render()
		if (state == STATE_TESTAUDIO) then
			SoundManager._Render(renderHelper)
		elseif (state == STATE_MENU) then
			MenuBoard.Render(renderHelper)
			Game.LevelMenuRender()
		elseif (state == STATE_LOADASSETS) then
			Game.ShowDeferredAssetsLoadingBar()
		elseif (state == STATE_LEVELINTRO) then
			Game.IntroRender()
		elseif (state == STATE_LEVELOUTRO) then
			Game.OutroRender()
		elseif (state == STATE_PLAY or state == STATE_GAMEOVER or state == STATE_ANNOUNCE or state == STATE_RESTART or
				(state == STATE_PAUSED and (laststate == STATE_PLAY or laststate == STATE_LEVELOUTRO or laststate == STATE_GAMEOVER))) then
			Game.GameRender()
			if (state == STATE_PAUSED) then
				MenuBoard.DisplayInstructions(renderHelper,true)
			end
		else
			Game.LevelMenuRender()
			MenuBoard.Render(renderHelper)
			RenderHelper.DrawText(renderHelper,"PAUSE = "..state.." laststate "..laststate,512,80)
		end
		
		if (state == STATE_LEVELOUTRO) then
			RenderHelper.DrawText(renderHelper,Locale.GetLocaleText("HIT [SELECT] FOR NEXT LEVEL"),512,600,1,{red=127,blue=127,green=127,alpha=40},"center")
		end
		
		if (state == STATE_PAUSED) then
			RenderHelper.DrawCircle(renderHelper,20,20,10,{red=0,blue=127,green=80,alpha=20})
		end

		
--		RenderHelper.SetFont(renderHelper,FONT_DEFAULT)
--		RenderHelper.DrawText(renderHelper,Locale.GetLocaleText("FONT TEST"),512,600,1,{red=127,blue=127,green=127,alpha=40},"center")
		
		
--		AssetLoader.RenderDebug(renderHelper)	
		
	end
	
	function Game.LevelMenuRender()
		Levels.Render(renderHelper)
	end
	
	
	function Game.RenderUvTest(x,y)
		local xpos		=	math.modf((x or 512) + 512*math.sin(6*time*0.125/4))
		local ypos		=	math.modf((y or 360) + 300*math.sin(6*time*0.125/4))
		local 	t 			=	time / 16
		local	f			=	(math.modf(t) % 17) / 16
		local	strfract	=	f
		local   hgtfract	=	f 
		
		local 	uvs	=	{
							0,0,
							0,hgtfract,
							strfract,hgtfract,
							strfract,0
						}
						
		RenderHelper.DrawTextureUvs(renderHelper,"factory2",xpos,ypos-32,uvs)
		RenderHelper.DrawText(renderHelper,string.format("F = %.2f",f),xpos,ypos)
	end
	
	
	-- Main In-Game Rendering Loop
	-- Called from Game.Render()
	
	function Game.GameRender()
		Environment.DebugProfileBegin(5)
		RenderHelper.SetOverlay(renderHelper,0)
		TileMap.RenderFromCamera(tileMap,renderHelper,camera)

		-- Render Using New Camera
		RenderHelper.SetOverlay(renderHelper,1)
		local x,y,z		=	camera:GetPosition()
		tmpCam:SetXyzw(x,-y)
		RenderHelper.SetCamera2dPosition(renderHelper,tmpCam)

		if (Game.debug) then
 			TileMap.RenderCollision(tileMap,renderHelper)
			for pidx,path in pairs(paths) do
				path:Render(renderHelper)
			end
		end

		
		-- Render Enemies
		EnemyManager.RenderGround(renderHelper)
		PickupManager.Render(renderHelper)
	
		-- Render Shapes
		for idx,shape in pairs(shapes) do
			shape:Render(renderHelper)
		end
		
		
		MissionManager.Render(renderHelper)
		TriggerManager.Render(renderHelper)

		-- Render Player
		player:Render(renderHelper)

		MissileManager.Render(renderHelper)
		BulletManager.Render(renderHelper)

		EnemyManager.RenderAir(renderHelper)

		EnemyManager.RenderLocked(renderHelper)
		

		ParticleManager.Render(renderHelper)

		ExplosionManager.Render(renderHelper)
	
		CameraOrbitor.Render(cameraorbitor,renderHelper)
		
		RenderHelper.SetOverlay(renderHelper,14)
		Camera.Render(camera,renderHelper)
		
		if (Game.debug) then
			RenderHelper.DrawLine(renderHelper,screenDim:X()/2,0,screenDim:X()/2,screenDim:Y())
			RenderHelper.DrawLine(renderHelper,0,screenDim:Y()/2,screenDim:X(),screenDim:Y()/2)
		end

		--Game.TestRender()

		Environment.DebugProfileEnd(5)

		RenderHelper.SetOverlay(renderHelper,3)

		MessageManager.Render(renderHelper)

		if (radar) then
			Radar.Render(radar,renderHelper)
		end
		
		Hud.Render(renderHelper)

	--	Game.RenderUvTest()
		
		if (false) then
			local mem, ters = gcinfo()
			local ln = string.format("MEMORY :%f TERS:%f",(mem and mem or 0),(ters and ters or 0))
			RenderHelper.DrawText(renderHelper,ln,512,80,1,{red=127,blue=0,green=0,alpha=127},"center")

			local eInfo,pInfo,bInfo = ExplosionManager.GetInfo(),ParticleManager.GetInfo(),BulletManager.GetInfo()		
			local infoLn = string.format("EXP %03d BULLETS %03d PARTICLES %03d LOCAL ENEMIES %03d", eInfo,bInfo,pInfo,EnemyManager.localsize)
			RenderHelper.DrawText(renderHelper,infoLn,512,700,1,{red=127,blue=127,green=127,alpha=127},"center")
		
			local uT,tilesetCount,tileStats	=	TileMap.AnalyseMap(tileMap)
			local lt = string.format("UniqueTiles :%d  out of %d in image tileset.",uT,tilesetCount)
			RenderHelper.DrawText(renderHelper,lt,512,120,1,{red=127,blue=0,green=0,alpha=127},"center")
		end
		

		if (Game.debug) then

			-- Debug stuff
			ExplosionManager.RenderDebug(renderHelper)
			ParticleManager.RenderDebug(renderHelper)
			Easter.Render(renderHelper)

			local xpos,ypos	=	player:GetPosition()
			local str	=	string.format("PLAYER %d,%d",xpos,ypos)
			RenderHelper.DrawText(renderHelper,str,80,600,4,{red=0,blue=0,green=127,alpha=127},"left")
		
			ScoreManager.RenderDebug(renderHelper)
		
			AssetLoader.RenderDebug(renderHelper)

			local ln = string.format("LEVEL :%s",Levels.GetCurrentLevelName() or '???')
			RenderHelper.DrawText(renderHelper,ln,512,80,1,{red=127,blue=0,green=0,alpha=127},"center")

		
		end
		
		
	end
	

	
	function Game.ShowDeferredAssetsLoadingBar()
	
		RenderHelper.DrawImage(renderHelper,"backgroundBKG" or "loadingBKG",512,360)
		local valign			=	"center"
    	local halign			=	"center"
   		RenderHelper.DrawText(renderHelper,"LOADING SCREEN",512,80,1,{red=127,green=127,blue=127,alpha=127},halign,valign)

		barT					=	math.min(MAXLOADASSETSDURATION,barT	 + GetDeltaTime())
			
		local 	barwidth		=	128
		local 	barheight		=	16
		local 	xpos,ypos		=	512-barwidth/2,360-barheight/2
		local	strfract		=	  AssetLoader.GetProgress()  or barT/MAXLOADASSETSDURATION
		local   hgtfract		=	1
		local 	uvs	=	{
								0,0,
								0,hgtfract,
								strfract,hgtfract,
								strfract,0
						}

		RenderHelper.DrawTextureUvs(renderHelper,"loadingbar",xpos+barwidth*strfract*0.5,ypos,uvs)
	end
	
	
	function Game.IntroRender()
		RenderHelper.SetOverlay(renderHelper,0)
		MissionManager.RenderDescription(renderHelper,MissionManager.DefaultWindowDim,1,{red=127,green=64,blue=127,alpha=127})
	end



	function Game.InitEnemyNames()
			--- All these indexes are shared with EnemyData table (see EnemyData.lua)
			
			lookupEnemyNames.smalljeep	=	Locale.GetLocaleText("SMALL JEEP")
			lookupEnemyNames.largejeep	=	Locale.GetLocaleText("LARGE JEEP")
			lookupEnemyNames.hut		=	Locale.GetLocaleText("AMMO HUT")
			lookupEnemyNames.house		=	Locale.GetLocaleText("CIVI HOUSE")
			lookupEnemyNames.radar		=	Locale.GetLocaleText("RADAR")
			lookupEnemyNames.deserthut	=	Locale.GetLocaleText("DESERT HUT")
			lookupEnemyNames.factory	=	Locale.GetLocaleText("FACTORY")
			lookupEnemyNames.barrocks	=	Locale.GetLocaleText("BARROCKS")
			lookupEnemyNames.train		=	Locale.GetLocaleText("TRAIN")
			lookupEnemyNames.artillery	=	Locale.GetLocaleText("ARTILLERY")
			lookupEnemyNames.tank		=	Locale.GetLocaleText("TANK")
			lookupEnemyNames.outhouse	=	Locale.GetLocaleText("OUT HOUSE")
			lookupEnemyNames.car		=	Locale.GetLocaleText("CAR")
			numEnemyNames				=	0
			
			for k,v in pairs(lookupEnemyNames) do
				numEnemyNames				=	numEnemyNames + 1
			end
			Game.CheckEnemyNames(enemies)
	end
	
	function Game.CheckEnemyNames()
		for k,enemy in pairs(enemies) do
			if (not lookupEnemyNames[enemy.name]) then
				lookupEnemyNames[enemy.name] = Locale.GetLocaleText(enemy.name.."?")
			end
		end
	end
	
	function Game.OutroRender()
		Game.GameRender()
		if (@REVEALSCORECARD@) then
			Game.ShowReportCard()
		end
	end
	
	function Game.ShowReportCard()
	
		RenderHelper.SetOverlay(renderHelper,14)

		local fullBlownReport	=	true

		local totalDestroyed	=	ScoreManager.GetTotalDestroyed()
		local index				=	0
		

		local textColour		=	{red=127,blue=127,green=127,alpha=40}
		local textScale			=	1

		RenderHelper.SetFont(renderHelper,FONT_DEFAULT)
		local fh				=	RenderHelper.GetFontHeight(renderHelper)
		local record 			=	ScoreManager.GetRecords()
		local lenCh				=	RenderHelper.GetFontWidth(renderHelper,"00")	
		
		local maxLen			=	1
		
		for key,name in pairs(lookupEnemyNames) do
			local locName		=	lookupEnemyNames[name] or "UNKNOWN "..name
			local len			=	RenderHelper.GetFontWidth(renderHelper,locName)
			if ( len > maxLen) then
				maxLen		=	len 
			end

		end
			
		maxLen		=	maxLen + lenCh
		totalLen	=	maxLen + lenCh

		local xposName			=	1024 - totalLen - lenCh
		local xposTally			=	xposName + maxLen
		
		local yposStart			=	10
		local pixHeight			=	fullBlownReport and fh*(numEnemyNames + 3) or fh*(#record + 3) 
		yposStart				=	(720 - pixHeight)/2


		RenderHelper.DrawText(renderHelper,Locale.GetLocaleText("MISSION REPORT"),xposName+totalLen/2,yposStart - 2*fh,1,{red=127,blue=127,green=127,alpha=40},"center")
		
		if (fullBlownReport) then
			
			--assert(false,yposStart)
			
			for key,name in pairs(lookupEnemyNames) do
				local locName		=	lookupEnemyNames[key] or "UNKNOWN "..name
				local totalStr		=	string.format("%02d",ScoreManager.GetRecord(key))
				local yPosition		=	yposStart + index * fh
					
				RenderHelper.DrawText(renderHelper,locName,xposName,yPosition,textScale,textColour,"left")
				RenderHelper.DrawText(renderHelper,totalStr,xposTally,yPosition,textScale,textColour,"left")

				index	=	index + 1
			end
		else
		
			yposStart	=	(720 - fh*(#record + 2))/2
		
			for name,total in pairs(record) do
			
				local yPosition		=	yposStart + index * fh
				local locName		=	lookupEnemyNames[name] or "UNKNOWN "..name
				local totalStr		=	string.format("%02d",total)

				RenderHelper.DrawText(renderHelper,locName,xposName,yPosition,textScale,textColour,"left")
				RenderHelper.DrawText(renderHelper,totalStr,xposTally,yPosition,textScale,textColour,"left")
				
				index	=	index + 1
			end
		end
		
		-- Grand Total Info
		local totupStr			=	string.format("%s",Locale.GetLocaleText("TOTAL DESTROYED"),totalDestroyed)
		local totalStr			=	string.format("%03d",totalDestroyed)
		local tallyYpos			=	yposStart+(index+1)*fh
		local tallyScale		=	1
		local tallyTextColour	=	{red=127,blue=127,green=127,alpha=40}
		local tallyDescXpos		=	xposName
		local tallyAmountXpos	=	xposTally
		
		RenderHelper.DrawText(renderHelper,totupStr,tallyDescXpos,tallyYpos,tallyScale,tallyTextColour,"left")
		RenderHelper.DrawText(renderHelper,totalStr,tallyAmountXpos,tallyYpos,tallyScale,tallyTextColour,"left")
		
--		RenderHelper.DrawText(renderHelper,"OUTRO -Game.OutroRender()",80,600,2,{red=0,blue=0,green=127,alpha=127},"left")

	end
	
	function Game.TestRender()
	
		RenderHelper.SetOverlay(renderHelper,0)
		spr:SetPosition(sprPos)
		renderHelper.renderer:DrawSprite(spr)
		RenderHelper.DrawLine(renderHelper,0,0,200,200)
		RenderHelper.DrawRect(renderHelper,200,200,100,60)
		RenderHelper.DrawCircle(renderHelper,300,260,10,{red=255,blue=0,green=0,alpha=255})
		RenderHelper.DrawText(renderHelper,"HELLO WORLD (Layer0)",10,10,1,{red=0,blue=0,green=255,alpha=255})
	
	
		-- Test out Plain (Home SDK) Renderer
		local renderer	=	renderHelper.renderer
		renderer:DrawText2d(Vector4.Create(100,100),"JOHN Y=100",Vector4.Create(1,1,0,1))
		renderer:DrawText2d(Vector4.Create(100,-100),"JOHN Y=-100",Vector4.Create(1,1,0,1))

		spr:SetPosition(Vector4.Create(100,100))
		renderHelper.renderer:DrawSprite(spr)

		RenderHelper.SetOverlay(renderHelper,1)
		spr:SetPosition(Vector4.Create(0,0))
		renderHelper.renderer:DrawSprite(spr)
		RenderHelper.DrawText(renderHelper,"HELLO WORLD (Layer1)",10,10,1,{red=0,blue=0,green=255,alpha=255})
		
	end
	
	function Game.ClearJoySticks()
		for padNumber=1,Constants.MAXJOYSTICKS do
			local pad = Pad.GetPad(padNumber)
			Pad.UnReserve(pad,Constants.KEY_UP)
			Pad.UnReserve(pad,Constants.KEY_DOWN)
			Pad.UnReserve(pad,Constants.KEY_LEFT)
			Pad.UnReserve(pad,Constants.KEY_RIGHT)		
			Pad.UnReserve(pad,Constants.KEY_SELECT)
			Pad.UnReserve(pad,Constants.KEY_START)
			Pad.UnReserve(pad,Constants.KEY_DEBUG)
			Pad.UnReserve(pad,Constants.KEY_SPEEDUP)
			Pad.UnReserve(pad,Constants.KEY_NORMAL)
			Pad.UnReserve(pad,Constants.KEY_CHAFF)
			Pad.UnReserve(pad,Constants.KEY_BACK)
			Pad.UnReserve(pad,Constants.KEY_INSTRUCTIONS)
			Pad.UnReserve(pad,Constants.AXISX)
			Pad.UnReserve(pad,Constants.AXISY)
			Pad.UnReserve(pad,Constants.AXISZ)
			Pad.UnReserve(pad,Constants.GYROY)
			Pad.UnReserve(pad,Constants.KEY_SELECTLEFT)
			Pad.UnReserve(pad,Constants.KEY_SELECTRIGHT)
			Pad.UnReserve(pad,Constants.KEY_SELECTUP)
			Pad.UnReserve(pad,Constants.KEY_SELECTDOWN)
			Pad.UnReserve(pad,Constants.XANALMOVE)
            Pad.UnReserve(pad,Constants.YANALMOVE)
			Pad.UnReserve(pad,Constants.XANALMOVE2)
            Pad.UnReserve(pad,Constants.YANALMOVE2)
            
		end
	end
	


	function Game.InitJoySticks()
		Pad.CreatePads(Constants.MAXJOYSTICKS)
		Game.ClearJoySticks() 

		for padNumber=1,Constants.MAXJOYSTICKS do
			local pad = Pad.GetPad(padNumber)
			Pad.Reserve(pad,PAD_DPAD_UP,Constants.KEY_UP)
			Pad.Reserve(pad,PAD_DPAD_DOWN,Constants.KEY_DOWN)
			Pad.Reserve(pad,PAD_DPAD_LEFT,Constants.KEY_LEFT)
			Pad.Reserve(pad,PAD_DPAD_RIGHT,Constants.KEY_RIGHT)
			Pad.Reserve(pad,PAD_CROSS,Constants.KEY_SELECT)
			Pad.Reserve(pad,PAD_TRIANGLE,Constants.KEY_CHAFF)
			Pad.Reserve(pad,PAD_CIRCLE,Constants.KEY_MISSILES2)
			Pad.Reserve(pad,PAD_SQUARE,Constants.KEY_START)

			Pad.Reserve(pad,PAD_L1_SHOULDER,Constants.KEY_FIRE)
			Pad.Reserve(pad,PAD_L2_SHOULDER,Constants.KEY_MISSILES)
			
			Pad.Reserve(pad,PAD_R1_SHOULDER,Constants.KEY_NORMAL)
			Pad.Reserve(pad,PAD_R2_SHOULDER,Constants.KEY_DEBUG)

			Pad.Reserve(pad,PAD_SENSOR_AXIS_X,Constants.AXISX)
			Pad.Reserve(pad,PAD_SENSOR_AXIS_Y,Constants.AXISY)
			Pad.Reserve(pad,PAD_SENSOR_AXIS_Z,Constants.AXISZ)
			Pad.Reserve(pad,PAD_SENSOR_GYRO_Y,Constants.GYROY)

			Pad.Reserve(pad,PAD_ACTUATOR_SMALL)
			Pad.Reserve(pad,PAD_ACTUATOR_BIG)

            Pad.Reserve(pad,PAD_JOY_LEFT_X,Constants.XANALMOVE)
            Pad.Reserve(pad,PAD_JOY_LEFT_Y,Constants.YANALMOVE)

            Pad.Reserve(pad,PAD_JOY_RIGHT_X,Constants.XANALMOVE2)
            Pad.Reserve(pad,PAD_JOY_RIGHT_Y,Constants.YANALMOVE2)

		end
	end
	


	-- Pad control for Level Selection Menu
	
	function Game.LevelMenuControllerUpdate(padNumber)
		
		local controller	=	Pad.GetPad(padNumber)
		local playerNumber	=	padNumber
		
--		Game.EasterCheck(padNumber)

		if (Pad.WasJustPressed(controller,Constants.KEY_UP)) then
			Levels.Up()
		elseif (Pad.WasJustPressed(controller,Constants.KEY_DOWN)) then
			Levels.Down()
		elseif (Pad.WasJustPressed(controller,Constants.KEY_SELECT)) then

			if (not lastMissionWasASuccess) then
				Levels.ResetAll()
			end
		
			Game.Play(@TESTMENU@ and Levels.GetLevelChoiceString() or Levels.GetCurrentLevelName(),screenDim:X(),screenDim:Y(),not lastMissionWasASuccess)
		end

	end

	-- Pad control for STATE_LEVELINTRO (Mission Statement)
	function Game.MissionStatementControllerUpdate(padNumber)

			local controller	=	Pad.GetPad(padNumber)
			local playerNumber	=	padNumber

			if (Pad.WasJustPressed(controller,Constants.KEY_SELECT)) then
				Game.ChangeState(STATE_PLAY)
			end
	end
	
	-- Pad control for STATE_PLAY (main game)
	
	function Game.PlayerControllerUpdate(padNumber)
		local controller	=	Pad.GetPad(padNumber)
		local playerNumber	=	padNumber
		local movement		=	false
		
		Game.EasterCheck(padNumber)

		if (Pad.WasJustPressed(controller,Constants.KEY_DEBUG)) then
			if (tileMap) then
				TileMap.ToggleDebug(tileMap)
				Game.debug	=	tileMap.debug
				Shape.debug	=	tileMap.debug
				EnemyPart.debug	=	Game.debug
				player.debug	=	tileMap.debug
				
			end
		end
		local xmov,ymov		=	nil,nil
		
		if (Pad.IsHeld(controller,Constants.KEY_UP)) then
			ymov			=	-1
			
		elseif (Pad.IsHeld(controller,Constants.KEY_DOWN)) then
			ymov			=	1
		end
		
		if (Pad.IsHeld(controller,Constants.KEY_LEFT)) then
			xmov			=	-1

		elseif (Pad.IsHeld(controller,Constants.KEY_RIGHT)) then
			xmov			=	1
		end
		
		
		
		
		xmov  =   not xmov and Pad.GetAnalogExtent(controller,Constants.XANALMOVE) or xmov
        ymov  =   not ymov and Pad.GetAnalogExtent(controller,Constants.YANALMOVE) or ymov

		
		player:AxisMove(xmov,ymov)
    	
        player:AngleMove(Pad.GetAnalogExtent(controller,Constants.XANALMOVE2),Pad.GetAnalogExtent(controller,Constants.YANALMOVE2))
			
		
		if (Pad.IsHeld(controller,Constants.KEY_SELECT) or Pad.IsHeld(controller,Constants.KEY_FIRE)) then
			player:BulletSelect()
		end

		if (Pad.IsHeld(controller,Constants.KEY_MISSILES) or Pad.IsHeld(controller,Constants.KEY_MISSILES2)) then
			player:MissileSelect()
		end
		
		if (Pad.WasJustPressed(controller,Constants.KEY_CHAFF)) then
			if (player.ChaffSelect) then
				player:ChaffSelect()
			end
		end


		-- Quick Dirty Way of Getting out of Game
		if (Pad.WasJustPressed(controller,Constants.KEY_NORMAL)) then
			quitKey 	=	quitKey + 1
			if (quitKey > 3) then
				Game.ChangeState(STATE_MENU)
				EventManager.AddSingleShotEvent(SoundManager.FadeToMenuMusic(),nil,2)
				quitKey	=	0
			end
			
		end
		
	end

	function Game.MuteSound()
		--SoundPlayer.FadeAllDown(0.1)
		EventManager.AddSingleShotEvent(function() SoundPlayer.FadeAllDown(0.1) end,nil,1 )
	end
		
	function Game.UnMuteSound()
		EventManager.AddSingleShotEvent(function() SoundPlayer.FadeAllUp() end,nil,1)
	end


	-- Pad Control for Easter Egg check
	
	function Game.EasterCheck(padNumber)
		
		local controller	=	Pad.GetPad(padNumber)
		local keys	=	{
			Constants.KEY_UP,
			Constants.KEY_DOWN,
			Constants.KEY_LEFT,
			Constants.KEY_RIGHT,
			Constants.KEY_SELECT,
			Constants.KEY_CLEAR,
			Constants.KEY_R2,
	 		Constants.KEY_L2,
			
		}

		for _,key in pairs(keys) do
			if (Pad.WasJustPressed(controller,key)) then
				Easter.Input(key)
				return key
			end
		end
		return nil
	end

	-- The Game Starts here!
	
	function Game.Init(dimx,dimy)
		Logger.lprint(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Game.Init")
		-- create and set up the render helper object
		screenDim					=	Vector4.Create(dimx or 1024,dimy or 720)
		renderHelper 				=	RenderHelper.Create(screenDim)

		gameObject					=	Object.GetMe()
		
		lastMissionWasASuccess		=	false
		
		Game.LoadFonts()
		
		-- Initialise a few Managers
		
		Game.InitJoySticks()		
		EventManager.Init()
		--MenuManager.Init()
		MessageManager.Init(Game.PopUpEvent)
		ScoreManager.Init(Game.ScoreEvent)
		MenuBoard.Init(renderHelper,ScoreManager,Game.MenuBoardEvent)			-- renderHelper is passed for text formatting
		Levels.Init()
		SoundManager.Init(true)
		-- Start and fade up some music

		if (state ~= STATE_TESTAUDIO) then
			EventManager.AddSingleShotEvent(SoundManager.FadeUpIntro,nil,5)
		end
		
	end
	
	function Game.LoadFonts()
	
		RenderHelper.CreateFont(renderHelper,"font_arcade",8,"arcade8")
		RenderHelper.CreateFont(renderHelper,"font_arcade",10,"arcade10")
		RenderHelper.CreateFont(renderHelper,"font_arcade",12,"arcade12")
		RenderHelper.CreateFont(renderHelper,"font_arcade",18,"arcade18")
		RenderHelper.CreateFont(renderHelper,"font_arcade",26,"arcade26")
		RenderHelper.CreateFont(renderHelper,"font_arcade",38,"arcade38")

	end
	
	function Game.FinishUpGame()
		-- Game has finished - do some cleaning up before 'Outro' Sequence
		PickupManager.Finish()
		-- and others?
	end
	
	
end
