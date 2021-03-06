-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not SoundFadeEvent)  then

SoundFadeEvent = { }
SoundFadeEvent.className="SoundFadeEvent" 
SoundFadeEvent.TYPE_COSINE 	= 0 
SoundFadeEvent.TYPE_EXP2 	= 1 
SoundFadeEvent.TYPE_EXP10 	= 2 
SoundFadeEvent.TYPE_EXP16 	= 3 
SoundFadeEvent.TYPE_LINEAR	= 4 



	function SoundFadeEvent.Create(startValue,endValue,soundObject,type)
		Logger.print("SoundFadeEvent.Create()") 

		local soundfadeevent = {
				  startValue	=	startValue,
				  endValue		=	endValue,
				  type			=	type or SoundFadeEvent.TYPE_COSINE,
				  soundObject	= 	soundObject,
				  className		=	SoundFadeEvent.className,
		}
		setmetatable(soundfadeevent, { __index = SoundFadeEvent })
		return soundfadeevent 
	end

	function SoundFadeEvent.StartEvent(soundfadeevent)
		Logger.print("SoundFadeEvent:StartEvent")
		SoundFadeEvent.Running(soundfadeevent,0.0) 
	end

	function SoundFadeEvent.EndEvent(soundfadeevent)
		Logger.print("SoundFadeEvent:EndEvent")
		SoundFadeEvent.Running(soundfadeevent,1.0) 
	end

	function SoundFadeEvent.Running(soundfadeevent,nTime)

		Logger.print("Sound Fade Event")
		local attenValue  
		local type = soundfadeevent.type 

		if (type == SoundFadeEvent.TYPE_COSINE) then
			attenValue = Interpolate.Cosine(soundfadeevent.startValue,soundfadeevent.endValue,nTime) 
		elseif (type == SoundFadeEvent.TYPE_EXP2) then
			attenValue = Interpolate.Exponential(soundfadeevent.startValue,soundfadeevent.endValue,nTime,2) 
		elseif (type == SoundFadeEvent.TYPE_EXP10) then
			attenValue = Interpolate.Exponential(soundfadeevent.startValue,soundfadeevent.endValue,nTime,10) 
		elseif (type == SoundFadeEvent.TYPE_EXP16) then
			attenValue = Interpolate.Exponential(soundfadeevent.startValue,soundfadeevent.endValue,nTime,16) 
		elseif (type == SoundFadeEvent.TYPE_LINEAR) then
			attenValue = Interpolate.Linear(soundfadeevent.startValue,soundfadeevent.endValue,nTime) 
		else
			attenValue = 1.0 
			Logger.warning("SoundFadeEvent:Running - Invalid Fade Type SEE A CODE DOCTOR QUICK!")
		end

		if (soundfadeevent.soundObject) then
			Logger.print("Set Attenuation on Sound Object to ",soundfadeevent.soundObject,attenValue)
			--soundfadeevent.soundObject:SetVolume(attenValue) 
			SoundPlayer.SetSoundStreamVolume(soundfadeevent.soundObject,attenValue)
        end
		Logger.print("Set Attenuation on Sound Object to "..attenValue)
	end

	Logger.print("Included SoundFadeEvent")


end

