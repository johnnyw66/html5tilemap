-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not SoundPlayer) then
local MAXSOUNDVOLUME		=	1

SoundPlayer = {}
-- Master Volume control 
SoundPlayer.masterVolumeSfx 		= 	1.0
SoundPlayer.masterVolumeMusic 		= 	0.35
-- Current Volume settings for streamed music
-- Indexed by SoundStream object
SoundPlayer.streamedMusicVolume		=	{}
SoundPlayer.sfx_volume              =   1
SoundPlayer.soundojects             =   {}

	function SoundPlayer.Init(soundbank,sfxvolume)  
		Logger.lprint("SoundPlayer.Init")
		
        SoundPlayer.masterVolumeSfx 		        = 	1.0
        SoundPlayer.masterVolumeMusic 		        = 	0.35
    	SoundPlayer.soundBank 						=	soundbank
        SoundPlayer.sfx_volume                      =   sfxvolume  or 1.0
		SoundPlayer.soundOn							= 	true

        SoundPlayer.soundobjects                    =   {}
        SoundPlayer.streamedMusicVolume		        =	{}

	end

	function SoundPlayer.IsSoundOn()
		return SoundPlayer.soundOn
	end
	
	-- Simple Sound Wrapper

	function SoundPlayer.Play2d(sfxid)
		--Logger.lprint("SoundPlayer.Play2d:"..sfxid)
       if (SoundPlayer.soundOn) then
           local obj = SoundBank.Play2d(SoundPlayer.soundBank,sfxid,SoundPlayer.CalcVolumeSfx(SoundPlayer.sfx_volume))
           SoundPlayer.soundobjects[sfxid] = obj
           return obj
       end
        return nil
	end
 
    function SoundPlayer.Terminate()
        SoundPlayer.StopAllSoundFX()
        SoundPlayer.StopAllMusic()
    end

    function SoundPlayer.StopAllMusic()
		for sound,volume in pairs(SoundPlayer.streamedMusicVolume) do
			sound:SetVolume(0)
            sound:Stop()
		end
    end

	function SoundPlayer.Stop(sfxid)
        local obj = SoundPlayer.soundobjects[sfxid]
        if (obj) then
            Logger.lprint("SoundPlayer.Stop "..sfxid)
            Sound.Stop(obj)
        end

	end

    function SoundPlayer.Update(dt)
        for idx,soundObject in pairs(SoundPlayer.soundobjects) do
            if (not soundObject:IsPlaying()) then
               SoundPlayer.soundobjects[idx] = nil
            end
        end
   end

   function SoundPlayer.StopAllSoundFX()
        for idx,soundObject in pairs(SoundPlayer.soundobjects) do
            soundObject:Stop()
            SoundPlayer.soundobjects[idx] = nil
        end

   end

	-- Calculate Actual Volume based on Master volume and
	-- required Volume - used to fade up/ fade down sound and
	-- music

	function SoundPlayer.CalcVolumeSfx(requiredVolume)
  		return math.min(SoundPlayer.masterVolumeSfx,requiredVolume)
	end

	function SoundPlayer.CalcVolumeMusic(requiredVolume)
		return math.min(SoundPlayer.masterVolumeMusic,requiredVolume)
	end

	-- Function used to set the volume of streamed music
	-- keep a note of the last volume set in a 'hash' table
	-- so we can use it to reset when we switch on sound fx and music.
	
	function SoundPlayer.SetSoundStreamVolume(soundObject,volume)
		if (soundObject) then
			-- keep a record of current sound stream volume
			SoundPlayer.streamedMusicVolume[soundObject] = volume
			soundObject:SetVolume(SoundPlayer.CalcVolumeMusic(volume))
		end
	end

	-- Turn Sound On - set Master levels to full volume
	-- and go through streamed music to reset to their
	-- last used value.
	
	function SoundPlayer.SoundOn()
		-- set volume to original settings for streamed music.
		for sound,volume in pairs(SoundPlayer.streamedMusicVolume) do
			sound:SetVolume(SoundPlayer.CalcVolumeMusic(volume))
		end
		SoundPlayer.soundOn 			=	true
	end

	-- Turn Sound Off - set Master levels to zero volume
	-- and go through streamed music to reset to either
	-- the given value or 0.
	
	function SoundPlayer.SoundOff(pvol)
		for sound,volume in pairs(SoundPlayer.streamedMusicVolume) do
            local vol =  SoundPlayer.CalcVolumeMusic((pvol or 0)*volume)
			sound:SetVolume(vol)
		end
		SoundPlayer.soundOn 			=	false
	end

   function SoundPlayer.DebugMusic()
		for sound,volume in pairs(SoundPlayer.streamedMusicVolume) do
	       print("Sound On Settting Volume",sound,volume)
		end
    end



	-- Sound Fading Support functions for Streaming Music Only
	
	function SoundPlayer.FadeSounds(oldsound,newsound,fadeTime,fadeFraction,fadeType)
		local fFraction = fadeFraction or 0.5
		local fType = fadeType or SoundPlayer.fadeType
		SoundStream.Play2d(newsound,true,0)
		local time = EventManager.AddImmediateEvent(SoundFadeEvent.Create(1,0,oldsound,fType),fadeTime) 
 		EventManager.AddEventAfterTime(SoundFadeEvent.Create(0,MAXSOUNDVOLUME,newsound,fType),time-fadeTime*fFraction,fadeTime) 
	end

	function SoundPlayer.FadeSound(sound,startVol,endVol,fadeTime)
		local time = EventManager.AddImmediateEvent(SoundFadeEvent.Create(startVol,endVol,sound,SoundPlayer.fadeType),fadeTime) 
	end

	
	function SoundPlayer.FadeUp(sound,fadeTime,looping)
		SoundStream.Play2d(sound,looping,0)
	   	SoundPlayer.FadeSound(sound,0,MAXSOUNDVOLUME,fadeTime) 
	end

	function SoundPlayer.FadeDown(sound,fadeTime)
	   	SoundPlayer.FadeSound(sound,MAXSOUNDVOLUME,0,fadeTime)
	end

	function SoundPlayer.FadeDownAll(fadeTime)
		for sound,volume in pairs(SoundPlayer.streamedMusicVolume) do
        	local vol =  SoundPlayer.CalcVolumeMusic(volume)
		   	SoundPlayer.FadeSound(sound,vol,0,fadeTime)
		end
	end
	
	function SoundPlayer.FadeAllDown(fVal)
        SoundPlayer.SoundOff(fVal or 0.0)
    end

    function SoundPlayer.FadeAllUp()
        SoundPlayer.SoundOn()
    end

    
end

	
