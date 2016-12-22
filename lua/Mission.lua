-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Mission) then

Mission					=	{}
Mission.className		=	"Mission"
local tmpV				=	Vector4.Create()
local LOWWARNINGP		=	0.75

local defaultDescription	=	"Sed quam leo, consequat sed rhoncus a, aliquet nec risus. Sed molestie urna id metus viverra fermentum. Nam diam sem, facilisis vitae cursus in, vulputate eu mi. Praesent et diam ipsum. Donec sagittis ligula id urna ornare ac fermentum sapien condimentum. Integer sit amet commodo nunc. Nam adipiscing ornare sapien ut luctus. Aliquam risus dolor, facilisis ac condimentum non, volutpat vel tortor. Sed condimentum posuere nibh sed dignissim. Phasellus at velit ac velit iaculis sagittis. Mauris leo mi, ultrices sed mattis quis, iaculis in sem. Donec suscipit justo at ipsum ultrices sollicitudin. Integer cursus sollicitudin lectus non vestibulum. Donec euismod tortor in orci facilisis dapibus. Donec sagittis erat tempor odio ornare tincidunt."


    function Mission.Create(shape)
		local mission = {
			missionText		=	"MISSION TEXT",
			completedText	=	"COMPLETED TEXT",
			submissions		=	{},
			survive			=	false,
			started			=	false,
			className       =   Mission.className,
		}
		setmetatable(mission,{__index = Mission } )
		Mission._Init(mission,shape)
		return mission
    end
	
	function Mission._Init(mission,shape)
		mission.submissions	=	{}
		local properties = shape.properties
		
		mission.missionText			=	properties.missiontext 	or	"MISSING MISSION (missiontext) TEXT."
		mission.completedText		=	properties.completedtext or	"MISSING COMPLETED (completedtext) TEXT."
		mission.failedText			=	properties.failedtext or	"MISSING FAILED (failedtext) TEXT."
		mission.defaultpickups		=	properties.defaultpickups
		
		mission.timetocomplete		=	properties.timetocomplete	or -1
		mission.pointspersubmission	=	properties.pointspersubmission or 1
		mission.completedbonus		=	properties.completedbonus	or 0
		mission.description			=	properties.description or	defaultDescription
		mission.image				=	properties.image or "genericmissionimage"
	
		
		-- resolve links 
		if (shape.attachedlist) then
			for idx,attached in pairs(shape.attachedlist) do
			--	assert(attached.className == 'Enemy','We can only attach enemies.')
				if (attached.MarkForMission) then
					attached:MarkForMission()
				end
				table.insert(mission.submissions,attached)
			end
		end
		mission.numsubmissions	=	#mission.submissions

		if (mission.numsubmissions > 0) then
			mission.current			=	mission.submissions[1]
		else
			mission.survive			=	true
		end
		
		mission.lowtime				=	LOWWARNINGP*mission.timetocomplete
		mission.lowwarningdone		=	false
		
		mission.pos				=	shape:GetVectorPosition()	-- Only really needed for debug rendering
		mission.time			=	0
		mission.missionText		=	Mission._ModifyText(mission.missionText)
		mission.completedText	= 	Mission._ModifyText(mission.completedText)
		mission.failedText		= 	Mission._ModifyText(mission.failedText)
		
		mission.markeranim,mission.markerspr	=	RenderHelper.CreateTextureAnimation(4,2,"missionmarker",1)
		assert(mission.markeranim,'ANIMATION IS FALSE')
		assert(mission.markerspr,'MARKER SPRITE IS FALSE')
		
		mission.scale		=	1
		
		TextureAnim.Play(mission.markeranim,true)
	
	end
	
	function Mission.ExtraTime(mission,time)
		local tm	=	(time or 30)*(mission.survive and -1 or 1)
		mission.timetocomplete		= math.max(10,mission.timetocomplete + tm)
		mission.lowtime				=	LOWWARNINGP*mission.timetocomplete
		mission.lowwarningdone		=	false

	end
	
	function Mission._ModifyText(text)
		return	Locale and Locale.ModifyText(text) or text
	end

--	function Locale.ModifyText(text)
--		local modtext 	=	text
--		string.gsub(text,"_LOCALE%W*[(]([^)]+)[)]",
--			function(txt) 
--				modtext = Locale and Locale.GetLocaleText and Locale.GetLocaleText(txt) or txt 
--			end)
--			
--		return modtext
--	end

	function Mission.IsType(mission,typ)
		return Mission.GetMissionType(mission) == typ
	end

	function Mission.GetMissionType(mission)
		return mission.survive and 'survive' or 'destroy'
	end
	
	function Mission.HasStarted(mission)
		return mission.started
	end
	
	function Mission.StartMission(mission)
		mission.started	=	true
	end
	
	function Mission.IsMissionTimeLow(mission)
		return (not mission.survive and mission.time > mission.lowtime) 
	end

	function Mission.TimeLowWarning(mission)
		if (not mission.lowwarningdone and mission:IsMissionTimeLow()) then
			mission.lowwarningdone	=	true
			return true
		end
		return false
	end

	
	function Mission.IsMissionComplete(mission)
		if (mission.survive) then
			return mission.time >= mission.timetocomplete
		else
			return ((mission.current == nil) and (mission.time <  mission.timetocomplete))
		end
	end
	
	function Mission.HasMissionFailed(mission)
		if (mission.survive) then
			return false
		else
			return (mission.timetocomplete > 0 and mission.time > mission.timetocomplete and mission.current ~= nil)
		end
	end

	function Mission.GetDefaultPickups(mission)
		return 	mission.defaultpickups
	end
	
	function Mission.GetFailedText(mission)
		return 	mission.failedText	 or "MISSION FAILED"
	end

	function Mission.GetCompletedText(mission)
		return  mission.completedText or "WELL DONE - YOU HAVE COMPLETED YOUR MISSION!"
	end
	
	function Mission.GetTimeRemaining(mission)
		return (mission.timetocomplete > 0 and (mission.timetocomplete - mission.time) or 0)
	end
	
	function Mission.GetMissionText(mission)
		return 	mission.missionText	 or "YOUR MISSION IS..."
	end

	function Mission.GetMissionDescription(mission)
		return 	mission.description,mission.image
	end

	function Mission.GetCurrentMission(mission)
		return mission.current
	end

	function Mission.GetCurrentMissionVector(mission,cPoint)
		local x,y = mission.current:GetPosition()
		tmpV:SetXyzw(x,y,0,0)
		Vector4.Subtract(tmpV,tmpV,cPoint)
		tmpV:Normalise2()
		return tmpV
	end
	
	function Mission.GetMissionCompletedBonus(mission)
		return 	mission.completedbonus	or 0
	end
	
	function Mission.GetMissionObjectivePosition(mission)
		return nil
	end

	
	function Mission.Update(mission,dt)
		mission.time		=	mission.time	+	dt
		mission.scale		=	math.sin(6*0.125*mission.time)
		mission.dy		=		8*math.sin(6*0.125*mission.time)
		

		mission.markeranim:Update(dt)

		local removeList	=	{}
		local aliveList		=	{}

		for idx,submission in pairs(mission.submissions) do
			assert(submission.IsKilled,submission.className)
			if (submission:IsKilled()) then
				table.insert(removeList,idx)
			else
				table.insert(aliveList,submission)
			end

		end
		
		for k,idx in pairs(removeList) do
			if (mission.submissions[idx]  == mission.current) then
				mission.current		=	nil
			end
			mission.submissions[idx] = nil
			mission.numsubmissions	=	mission.numsubmissions - 1
		end

		mission.submissions	=	aliveList

		if (not mission.current and #aliveList > 0) then
			mission.current		=	mission.submissions[1]
		end
		
	end
	
	function Mission.GetSubmissionsRemaining(mission)
		return mission.numsubmissions 
	end
	
	-- Debug function
	function Mission.KillAll(mission)
		for idx,submission in pairs(mission.submissions) do
			if (submission.Kill) then
				submission:Kill()
			end
		end
	end
	
    function Mission.Render(mission,rHelper)
		
		if (mission.current) then
			local 	xpos,ypos	=	mission.current:GetPosition()
			ypos		=	ypos + (mission.dy or 0) - 16
		
			local texture = mission.markeranim:GetRenderTexture()
			local uvs =	texture.uvs
			Sprite.SetUvs(mission.markerspr,
				uvs.tlu,uvs.tlv,
				uvs.blu,uvs.blv,
				uvs.bru,uvs.brv,
				uvs.tru,uvs.trv
			)
			RenderHelper.DrawSprite(rHelper,mission.markerspr,xpos,ypos,1,0)
		end
    end

	function Mission.RenderDebug(mission,rHelper)
		local xpos,ypos	=	mission.pos:X(),mission.pos:Y()
		RenderHelper.DrawText(rHelper,mission:toString(),xpos,ypos-20,1,{red=128,green=0,blue=0,alpha=128},"left","bottom")
	end
	
	function Mission.toString(mission)
		return string.format("Mission (num of submissions = %d) TIME REMAINING %d COMPLETE (%s): FAILED(%s) pickups(%s)",mission.numsubmissions,
		Mission.GetTimeRemaining(mission),
		Mission.IsMissionComplete(mission) and 'true' or 'false',
		Mission.HasMissionFailed(mission) and 'true' or 'false',
		mission.defaultpickups or 'NO DEFAULT PICKUPS DEFINED'	
		)
	end
end
