-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not TriggerManager) then

TriggerManager					=	{}
TriggerManager.className		=	"TriggerManager"
TriggerManager.triggers        	=	{}
TriggerManager.time			 	=   0
TriggerManager.debug			=  	true
TriggerManager.count			=	0

	function stop(msg)
		assert(false,msg)
	end
	
    function TriggerManager.Init(shapes)
		TriggerManager.count			=	0
        TriggerManager.triggers        	=   {}
		for _,shape in pairs(shapes) do
			if (not shape.properties.type or (shape.properties.type and shape.properties.type ~= 'mission')) then
				TriggerManager.Add(Trigger.Create(shape))
			end
		end
    end

	function TriggerManager.Clear()
		TriggerManager.Init()
	end

    function TriggerManager.Update(dt,player)
		TriggerManager.time	=	TriggerManager.time + dt

		for index,trigger in pairs(TriggerManager.triggers) do
      		trigger:Update(dt,player)
    	end
		
    end

    function TriggerManager.Add(trigger)
		table.insert(TriggerManager.triggers,trigger)
		TriggerManager.count = TriggerManager.count + 1
    end

	function TriggerManager.Render(rHelper)
		if (TriggerManager.debug) then
    		for index,trigger in pairs(TriggerManager.triggers) do
          		trigger:Render(rHelper)
        	end
		end
		
    end


end
