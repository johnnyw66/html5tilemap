-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not ObserverEvent) then

ObserverEvent	=	{}

local 	function _debugPrint(s)
				Logger.lprint(s)
		end

	-- An ObserverEvent object is responsible for deciding if an event is triggered
	-- tiPoint is duration in seconds the moveable object has to be in the hotspot for.
	-- eventCh is the % (0-100) chance of the event actually being triggered
	-- tFunction is the callback function in the event that the event is triggered.
	-- optCond is optional boolean callback function which needs to return true if event attempts to trigger.
	-- limit [optional] is the number of times the event can happen
	-- backoff is the duration in seconds that a next possible event will be held back for
	-- before testing again.
	-- rGen is an optional random number generator.
	-- Johnny - June 2012
	
	
	function ObserverEvent.Create(tiPoint,eventCh,tFunction,optCond,limit,backoff,rGen)
	 	local observer	=	{

			triggerPoint	=	tiPoint,
			eventChance		=	eventCh,
			makeitso		=	tFunction,
			triggered		=	false,
			count			=	0,
			limit			=	limit,
			backoff			=	backoff,
			rGen			=	rGen or math.random,
			optCondition	=	optCond,
			ObjectOutside	=	function(observer)
									_debugPrint("RESET STATE "..observer.className)
									observer.triggered	=	false
								end,
								
			Inform			=	function(observer,obj,isinside,ctime,timein,timeout)
									if (timein > observer.triggerPoint and not observer.triggered and (not observer.optCondition or observer.optCondition()) 
											and (not observer.limit or observer.count < observer.limit) 
											and (not observer.backoff or (not observer.lasttime or ctime - observer.lasttime > observer.backoff))) then
											observer.triggered	=	true
											_debugPrint("Throwing Dice")
											if (observer.rGen(0,100) < observer.eventChance) then

												if (observer.makeitso) then
													observer:makeitso(obj)
													observer.count =	observer.count + 1
													observer.lasttime	=	ctime
												end

											else
												_debugPrint("Dice - says no!")
											end
									end
								end,
			className		=	'observer',

		}

		return observer
	end
	
end
