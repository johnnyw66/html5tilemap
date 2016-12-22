-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Trigger) then

Trigger					=	{}
Trigger.className		=	"Trigger"
Trigger.STATE_NONE		=	0
Trigger.STATE_INSIDE	=	1
Trigger.STATE_OUTSIDE	=	2
Trigger.debug			=	false

    function Trigger.Create(shape,observerlist)
		local trigger = {
			state			=	Trigger.STATE_NONE,
			className       =   Trigger.className,
		}
		setmetatable(trigger,{__index = Trigger } )
		Trigger._Init(trigger,shape,observerlist)
		return trigger
    end
	
	function Trigger._Init(trigger,shape,observerlist)
		trigger.observers	=	observerlist or {}
		assert(type(trigger.observers)=='table','OPTIONAL OBSERVERLIST MUST BE A TABLE')

		local properties = shape.properties
		-- resolve links 
		if (shape.attachedlist) then
			for idx,attached in pairs(shape.attachedlist) do
			--	assert(attached.className == 'Enemy','We can only attach enemies.')
				table.insert(trigger.observers,attached)
			end
		end
		trigger.shape			=	shape
		trigger.pos				=	shape:GetVectorPosition()	-- Only really needed for debug rendering
		trigger.time			=	0
		
	end
	
	function Trigger.ChangeState(trigger,newstate,object)
--		assert(object.className == Player.className,'THIS SHOULD BE A PLAYER')
	
		if (newstate ~= trigger.state) then
			for idx,observer in pairs(trigger.observers) do
				
				--assert(observer.className ~= '_MessageGenerator','WE HAVE IT '..observer)
				
				if ((observer.IsAlive and observer:IsAlive()) or observer.className == 'Shape') then
					-- Inform Observer
					if (newstate == Trigger.STATE_INSIDE) then
						if (observer.ObjectInside) then
							observer:ObjectInside(object,trigger.shape)
						end
					else
						if (observer.ObjectOutside) then
							observer:ObjectOutside(object,trigger.shape)
						end
					end
					
				end
			end
		end
		trigger.state	=	newstate
	end
	
	
	function Trigger.Update(trigger,dt,object)
		trigger.time	=	trigger.time	+	dt

		if (trigger.shape:IsPointInside(object:GetVectorPosition())) then
			Trigger.ChangeState(trigger,Trigger.STATE_INSIDE,object)
			Shape.EntityEntered(trigger.shape,object)
		else
			Trigger.ChangeState(trigger,Trigger.STATE_OUTSIDE,object)
			Shape.EntityLeft(trigger.shape,object)
		end
		
	end
	
    function Trigger.Render(trigger,rHelper)
		if (Trigger.debug) then
			local xpos,ypos	=	trigger.pos:X(),trigger.pos:Y()
			RenderHelper.DrawText(rHelper,trigger:toString(),xpos,ypos-20,1,{red=128,green=0,blue=0,alpha=128},"left","bottom")
		end
    end

	function Trigger.toString(trigger)
		return string.format("Trigger")
	end

end
