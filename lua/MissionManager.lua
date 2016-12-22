-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not MissionManager) then

MissionManager					=	{}
MissionManager.className		=	"MissionManager"
MissionManager.missions        	=	{}
MissionManager.time			 	=   0
MissionManager.DefaultWindowDim	=	Vector4.Create(1024/2,600)
MissionManager.debug			=  	true
local tmpV						=	Vector4.Create()
local descriptionColour			=	{red=0,green=0,blue=0,alpha=128}
local formattedpages 			=	{{"line 1 of page1","line 2 of page1"},{"line 1 of page2","line2 of page2"}}


    function MissionManager.Init(shapes,cb)
        MissionManager.missions        	=   {}
		MissionManager.currentmission	=	nil
		MissionManager.currentdescription	=	nil
		MissionManager.completed		=	{}
		MissionManager.failed			=	{}
		MissionManager.callBack			=	cb or MissionManager.DefaultCallBack
--		MissionManager.eventCB			=	cb or MissionManager.DefaultCallBack

		for _,shape in pairs(shapes) do
			if (shape.properties.type and shape.properties.type == 'mission') then
				MissionManager.Add(Mission.Create(shape))
			end
		end

		formattedpages 			=		nil	--{{"line 1 of page1","line 2 of page1"},{"line 1 of page2","line2 of page2"}}
	
		MissionManager.currentmission =  MissionManager.missions[1]
	
	
		
    end
	
	function MissionManager.Clear()
		MissionManager.Init()
	end


	function MissionManager.DefaultCallBack(mission,reason)
		Logger.lprint(reason)
	end
	
    function MissionManager.Update(dt)
		MissionManager.time	=	MissionManager.time + dt
		
		
		for index,mission in pairs(MissionManager.missions) do
  			mission:Update(dt)

			if (not MissionManager.currentmission:HasStarted()) then
				mission:StartMission()
				MissionManager.currentmission = mission
				if (MissionManager.callBack) then
					MissionManager.callBack(mission,'MISSIONSTART')
				end	
			elseif (mission:IsMissionComplete()) then
				table.insert(MissionManager.completed,mission)
				if (MissionManager.callBack) then
					MissionManager.callBack(mission,'MISSIONCOMPLETE')
				end	
				MissionManager.missions[index] = nil
				MissionManager.currentmission = nil
		
			elseif (mission:TimeLowWarning()) then
				if (MissionManager.callBack) then
					MissionManager.callBack(mission,'MISSIONTIMELOW')
				end	
			elseif (mission:HasMissionFailed()) then
				table.insert(MissionManager.failed,mission)
				if (MissionManager.callBack) then
					MissionManager.callBack(mission,'MISSIONFAILED')
				end	
				MissionManager.missions[index] = nil
				MissionManager.currentmission = nil
			end
			break		-- only one at a time
    	end
		
    end

    function MissionManager.ExtraTime(time)
		if (MissionManager.currentmission) then
			 MissionManager.currentmission:ExtraTime(time)
		end
    end

    function MissionManager.Add(mission)
		table.insert(MissionManager.missions,mission)
    end

	function MissionManager.GetTimeRemaining()
		return MissionManager.currentmission and MissionManager.currentmission:GetTimeRemaining()
	end

	function MissionManager.GetSubmissionsRemaining()
		return MissionManager.currentmission and MissionManager.currentmission:GetSubmissionsRemaining() or 0
	end
	
	function MissionManager.GetMissionText()
		return MissionManager.currentmission and MissionManager.currentmission:GetMissionText()
	end


	-- returns text and image
	function MissionManager.GetMissionDesciption()
		local txt,img = nil,nil
		if ( MissionManager.currentmission) then
			 txt,img = MissionManager.currentmission:GetMissionDescription()
		end
		return txt,img
	end


	function MissionManager.GetDefaultPickups()
		return MissionManager.currentmission and MissionManager.currentmission:GetDefaultPickups()
	end

	function MissionManager.GetCompletedText()
		return MissionManager.currentmission and MissionManager.currentmission:GetCompletedText()
	end
	
	function MissionManager.IsMissionComplete()
		return MissionManager.currentmission and MissionManager.currentmission:IsMissionComplete()
	end

	function MissionManager.IsMissionTimeLow()
		return MissionManager.currentmission and MissionManager.currentmission:IsMissionTimeLow()
	end
	
	function MissionManager.HasMissionFailed()
		return MissionManager.currentmission and MissionManager.currentmission:HasMissionFailed()
	end
	

    function MissionManager.KillAll()
		for index,mission in pairs(MissionManager.missions) do
  			mission:KillAll()
		end
	end
	
	function MissionManager.NextMission()
		formattedpages 			=		nil	
	end


	function MissionManager.GetDirection(player)
		local x,y = player:GetPosition()
		tmpV:SetXyzw(x,y,0,0)
		return MissionManager.currentmission and MissionManager.currentmission:IsType('destroy') and MissionManager.currentmission:GetCurrentMissionVector(tmpV) or nil
	end
	
	function MissionManager.Render(rHelper)
		if (MissionManager.debug and MissionManager.missions) then
			--local str = string.format("NUM MISSIONS %d  SUBMISSIONS %d",#MissionManager.missions,MissionManager.GetSubmissionsRemaining())
			--RenderHelper.DrawText(rHelper,str,100,100,4,{red=128,green=0,blue=0,alpha=128},"left","bottom")
    		for index,mission in pairs(MissionManager.missions) do
          		mission:Render(rHelper)
        	end
		end
	--	MissionManager.RenderDescription(rHelper,MissionManager.DefaultWindowDim,1)
    end


	function MissionManager.RenderDescription(rHelper,windowDim,pageindex,colour)
		assert(MissionManager.currentmission,'NO MISSION!')
		RenderHelper.DrawImage(rHelper,"backgroundBKG" or "missionBKG",512,360)
		
		local dim			=	windowDim or MissionManager.DefaultWindowDim
		local imHgt			=	0
		
		local windowWidth,windowHeight = dim:X(),dim:Y()
		local xpos,ypos		=	512-windowWidth/2,40
		
		if (not MissionManager.currentdescription) then
				MissionManager.currentdescription,MissionManager.currentmissionimage	=	MissionManager.GetMissionDesciption()
				MissionManager.currentdescription=Locale.ModifyText(MissionManager.currentdescription)
		end

		if (MissionManager.currentmissionimage) then
			local tex = RenderHelper.TextureFind(MissionManager.currentmissionimage)
			imgHgt = tex:GetHeight() 
			RenderHelper.DrawTexture(rHelper,MissionManager.currentmissionimage,xpos+windowWidth/2,ypos+imgHgt/2)
			RenderHelper.SetFont(rHelper,FONT_MISSIONMANAGER_DEBUG)
			RenderHelper.DrawText(rHelper,MissionManager.currentmissionimage,xpos+windowWidth/2+64,ypos+40,1,colour or descriptionColour,"left","bottom")
		end
		
		if (MissionManager.currentdescription) then
		
			RenderHelper.SetFont(rHelper,FONT_MISSIONMANAGER_DESCRIPTION)
        	RenderHelper.SetFontScale(rHelper,1,1)

			if (not formattedpages) then
				formattedpages = FormatText.FormatToScreen(rHelper,MissionManager.currentdescription,windowWidth,windowHeight)
			end
			
		
			local fh	=	RenderHelper.GetFontHeight(rHelper)
			
			local page	=	formattedpages[pageindex or 1] or {} 
			for linenum,line in pairs(page) do
				RenderHelper.DrawText(rHelper,line,xpos,ypos+imgHgt*1.125+fh*linenum,1,colour or descriptionColour,"left","bottom")
			end
		end
		
		
	end
	

end
