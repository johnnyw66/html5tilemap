--  Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not WorldClock) then

WorldClock = {}
WorldClock.time = 0
WorldClock.observers = {}	
WorldClock.pause	= false

	-- Shared GameClock - for debouncing 
	
	-- Allow Watchers 
	function WorldClock.AddObserver(func)
		if (type(func)=="function") then
			table.insert(WorldClock.observers,func)	
		end
	end
	
	function WorldClock.Restart()
		WorldClock.Resume()
		WorldClock.Reset()
	end
	
	function WorldClock.Reset()
		WorldClock.time = 0
		WorldClock.InformObservers()
	end
	
	function WorldClock.Pause()
		WorldClock.pause = true 
	end
	
	function WorldClock.Resume()
		WorldClock.pause = false
	end
	
	-- Inform Watchers of 'major' changes in time
	function WorldClock.InformObservers()
		for k,f in pairs(WorldClock.observers) do
			if (f and type(f) == "function") then
				f(WorldClock.time)
			end
		end
	end
	
	function WorldClock.GetClock()
		return WorldClock.time 
	end

	function WorldClock.Update(dtime)
		if (not WorldClock.pause) then
			WorldClock.time = WorldClock.time + dtime
		end
	end

	Logger.print("Included WorldClock")

end

