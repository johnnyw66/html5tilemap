-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not SoundManager then

SoundManager = {}
SoundManager.className                	=	"SoundManager"
local	SOUNDBANKNAME					=	"renegadeops"

local MAXMUSICVOLUME					=	0.5

-- These are actual BANK ids define in the BNK resource.

SoundManager.BANKIDS		=	
{
"JEEP",
"HELICOPTER",
"CHAFF",
"BULLETHIT",
"MISSILERELEASE1",
"MISSILERELEASE2",
"MISSILETEASED",
"EXPLODELONG",
"EXPLODE1",
"EXPLODE2",
"PICKMEUP",
"PICKEDUP",
"TARGETLOCK",
"POPUPMESSAGE",
"SHIELDON",
"SHIELDOFF",
"RAPIDON",
"RAPIDOFF",
"STARTROUND",
"GAMEOVER",
"BESTSCORE",
"MISSIONSTART",
"MISSIONCOMPLETE",
"ALLMISSIONSCOMP",
"MISSIONFAILED",
"MISSIONTIMELOW",
"EXTRATIME",
"WARNING"

}



local function PickSfx(sounds)
	SoundManager.PlaySoundBankID(sounds[math.random(1,#sounds)])
end

local function StopSfx(bankid)
	if (bankid) then
		Logger.lprint("SoundManager.StopSfx:"..bankid)
		SoundPlayer.Stop(bankid)
	end
end

local function TrapSfx(message)
	assert(false,message)
end


-- Maps SoundHooks (left) to Sound Events (SoundBankIDs in BNK file or Sound Functions(in a table))

SoundManager.SOUNDHOOKS	=
{
	["AlivePlayerLandVehicle"]		=	"JEEP",
	["KillPlayerLandVehicle"]		=	{func=StopSfx,sound = "JEEP"},
	["FinishPlayerLandVehicle"]		=	{func=StopSfx,sound = "JEEP"},
	["PlayerCreated"]				=	{func=function() end},
	["PlayerKilled"]				=	"PLAYERKILLED",


	["AlivePlayerHelicopter"]		=	"HELICOPTER",
	["KillPlayerHelicopter"]		=	{func=StopSfx,sound="HELICOPTER"},
	["FinishPlayerHelicopter"]		=	{func=StopSfx,sound="HELICOPTER"},


	["BulletDestroyed"]			=	"BULLETHIT",
	["BulletFired"]				=	"BULLETHIT",

	["MissileFired"]			=	{func=PickSfx,sound={"MISSILERELEASE1","MISSILERELEASE2"}},
	["MissileDestroyed"]		=	"EXPLODELONG",


	["ExplosionStartExplosion"]	=	{func=PickSfx,sound={"EXPLODE1","EXPLODE2"}},
	["ExplosionEndExplosion"]	=	"ENDEXPLOSION",

	["PickupGenerated"]			=	"PICKMEUP",
	["PickupCollected"]			=	"PICKEDUP",


	["Target_True"]				=	"TARGETLOCK",
	["XTarget_False"]			=	"DUMMY",

	["Shield_True"]				=	"SHIELDON",
	["Shield_False"]			=	"SHIELDOFF",

	["RapidFire_True"]			=	"RAPIDON",
	["RapidFire_False"]			=	"RAPIDOFF",

	
	["GameOver"]				=	"GAMEOVER",
	["BestScore"]				=	"BESTSCORE",

	["PopupMessage"]			=	"POPUPMESSAGE",

	["StartNextRound"]			=	"STARTROUND",
	
	["LowOnTime"]				=	"TIMELOW",

	["MissileTeased"]			=	"MISSILETEASED",
	
	["MissionStart"]			=	"MISSIONSTART",
	["MissionCompleted"]		=	"MISSIONCOMPLETE",
	["MissionFailed"]			=	"MISSIONFAILED",
	["MissionTimeLow"]			=	"MISSIONTIMELOW",
	
	["AllMissionsCompleted"]	=	"ALLMISSIONSCOMP",
	
	["TimeShift"]				=	"EXTRATIME",
	
	
}



	function SoundManager.Init()
		if (not SoundPlayer.loaded) then
			SoundManager.LoadSounds()
			SoundPlayer.loaded	=	true
		end
	end
	
  	-- Sound Fading Support functions for Streaming Music Only
	function SoundManager.LoadSounds()
		-- Only Load Sounds Once!
        SoundPlayer.Init(SoundBank.Find(SOUNDBANKNAME))
		SoundManager.Music_MenuBackGround	=	SoundStream.Find("menubackgrounddemo")
		SoundManager.Music_InGame			=	SoundStream.Find("ingamemusicdemo")

	end

    function SoundManager.StopAllSFX()

    end

    function SoundManager.Terminate()
		local fadeDur = 1
		SoundPlayer.FadeDownAll(fadeDur)
		EventManager.AddSingleShotEvent(SoundPlayer.Terminate,nil,fadeDur + 0.5)
		--SoundPlayer.Terminate()
    end


   function SoundManager.SoundDown()

    end

   function SoundManager.SoundUp()
	
    end

   function SoundManager.FadeUpIntro()
        SoundPlayer.FadeUp(SoundManager.Music_MenuBackGround ,MAXMUSICVOLUME,true)
    end

    function SoundManager.FadeUpMain()
    	SoundPlayer.FadeUp(SoundManager.Music_InGame ,MAXMUSICVOLUME,true)
    end

    function SoundManager.FadeToGameMusic()
         SoundPlayer.FadeSounds(SoundManager.Music_MenuBackGround ,SoundManager.Music_InGame ,2)
    end

    function SoundManager.FadeToMenuMusic()
        SoundPlayer.FadeSounds(SoundManager.Music_InGame ,SoundManager.Music_MenuBackGround ,2)
    end


    function SoundManager.FadeAllDown(fVal)
       -- SoundPlayer.FadeSound(SoundManager.Music_InGame,MAXMUSICVOLUME,0.5*MAXMUSICVOLUME)
        SoundPlayer.SoundOff(fVal or 0.0)
    end

    function SoundManager.FadeAllUp()
      --  SoundPlayer.FadeSound(SoundManager.Music_InGame,0.5*MAXMUSICVOLUME,MAXMUSICVOLUME)
        SoundPlayer.SoundOn()
    end

	function SoundManager.FadeDown(sound,fadeTime)
	   	SoundPlayer.FadeSound(sound,MAXMUSICVOLUME,0,fadeTime)
	end
	
	
	function SoundManager.SoundEaster(idx)
		local sounds = {
		  	SoundManager.Sfx_MenuSelect,
			SoundManager.Sfx_PlayerShoot,
		} 

   	 	SoundPlayer.Play2d(sounds[idx] or SoundManager.Sfx_MenuSelect )
    end




	-- Map SoundHooks to SOUND BANK ID
	function SoundManager.PlaySoundBankID(bankid)
		if (bankid) then
			Logger.lprint("SoundManager.PlaySoundBankID:"..bankid)
			SoundPlayer.Play2d(bankid)
		end
	end

	function SoundManager.PlaySoundHook(hookname)

		local hook = SoundManager.SOUNDHOOKS[hookname]

		if (hook) then

			if (type(hook)=='table') then

				if (hook.func) then
					hook.func(hook.sound)
				else
					assert(false,'NO HOOK FUNCTION FOR HOOK '..hookname)
				end
			else
				SoundManager.PlaySoundBankID(hook)
			end

		else
			-- attempt the Hook Name as a BANK id.
			SoundManager.PlaySoundBankID(hookname)

		end

	end


	local function checkEventGroup(event,traps,exclude)	 
		local include = not exclude
		
		for k,v in pairs(traps) do
			if (event == v) then
				return include
			end
		end
		return not include
	end



	function SoundManager.SoundHook(sounddesc,event)
		local	exclude	=	false
		local	traps	=	{
						"PlayerEvent"
					}
					
		if (true or checkEventGroup(event,traps,exclude)) then
			--Logger.lprint(">>>>>>>>>>>>>>>>>>>SoundManager.SoundHook - "..(sounddesc or 'NIL sounddesc')..":"..(event or 'NIL event'))
			SoundManager.PlaySoundHook(sounddesc)
		end
			
	end

	
	function SoundManager.SoundHook(sounddesc,event)
		--Logger.lprint(">>>>>>>>>>>>>>>>>>>SoundManager.SoundHook - "..(sounddesc or 'NIL sounddesc')..":"..(event or 'NIL event'))
		SoundManager.PlaySoundHook(sounddesc)
	end


	


	-- Functions Below are used to generate a test menu with a list of in-game SFX
	-- see Game.lua [state = STATE_TESTAUDIO]

    SoundManager._currentSound = 1
	
    function SoundManager._XXXXGenerateSFXHandles()
        local sounds = {}
        for name,handle in pairs(SoundManager) do
           if (type(handle) == 'string' and string.find(name,"Sfx_") ) then
                table.insert(sounds,handle)
           end
        end
        return sounds
    end

	
    function SoundManager._GenerateSFXHandles()
        local sounds = {}
        for idx,handle in pairs(SoundManager.BANKIDS) do
            	table.insert(sounds,handle)
        end
        return sounds
    end


    function SoundManager._Render(rHelper)
        local sounds =  SoundManager._GenerateSFXHandles()
		local	fh		=	20
		local  	ypos	=	(720 - fh*#sounds)/2
		
        for i,handle in pairs(sounds) do
            if (SoundManager._currentSound == i) then
                RenderHelper.DrawText(rHelper,">",190,ypos+i*fh,nil,nil,"left")
            end
            RenderHelper.DrawText(rHelper,handle,200,ypos+i*fh,nil,nil,"left")
        end
        RenderHelper.DrawText(rHelper,sounds[SoundManager._currentSound] or '?',800,80,nil,nil,"left")

    end

    function SoundManager._CursorDown()
        local sounds =  SoundManager._GenerateSFXHandles()

        if (SoundManager._currentSound <  #sounds ) then
            SoundManager._currentSound =   SoundManager._currentSound +  1
        else
            SoundManager._currentSound = 1
        end

    end

    function SoundManager._CursorUp()
        local sounds =  SoundManager._GenerateSFXHandles()

        if (SoundManager._currentSound >  1 ) then
            SoundManager._currentSound =   SoundManager._currentSound -  1
        else
            SoundManager._currentSound =  #sounds
        end

    end

    function SoundManager._Select()
       local sounds =  SoundManager._GenerateSFXHandles()

       local name =  sounds[SoundManager._currentSound]
        SoundPlayer.Play2d(name)
    end


    function SoundManager._Update(dt)
     		local controller	=	Pad.GetPad(1)

            if (Pad.WasJustPressed(controller,Constants.KEY_UP)) then
                SoundManager._CursorUp()
            elseif (Pad.WasJustPressed(controller,Constants.KEY_DOWN)) then
                SoundManager._CursorDown()
            elseif (Pad.WasJustPressed(controller,Constants.KEY_SELECT)) then
                SoundManager._Select()
            end

    end



end
