-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not Ktimer then

Ktimer = {}

-- 	Ben's ktimer class -- converted by Johnny
-- 
-- 	static time()	-	class method to return the absolute time (depends on module WorldTime.lua)
-- 
-- 	The absolute time is the real time measured in seconds as returned by CFAbsoluteTimeGetCurrent().
-- 
-- 	Returns:
-- 
-- 		the absolute time in seconds
-- 

--	private double	scale_ 
--	private boolean	paused_ 
--	private double	start_time_ 
--	private double	elapsed_time_ 
--	private float	p1_, p2_ 


	function Ktimer.time()
		local t = WorldClock.GetClock() 
		return t 
	end

-- 
-- 	ctime()		-	--  constructor initialised with a pause state
-- 
-- 	The time object is initialised with the curret time.
-- 
-- 	Parameters:
-- 
-- 		scale	-	a time scaling factor
-- 		paused	-	true if the time object starts out paused
-- 
	function Ktimer.Create(  scale,  paused )
		local ktimer = {
				scale_ 		=	scale or 1.0, 
				paused_ 	=	paused, 
				p1_			=	0,
				p2_			=	1, 
				className	=	'Ktimer',
			}
		
		--  Use the common reset() method to set the start and elapsed times.
		-- 
		setmetatable(ktimer,{__index = Ktimer})
		Ktimer.reset(ktimer,scale) 
		return ktimer
	end

-- 
-- 	reset()	-	reset the time object to now
-- 
-- 	The current time is used as the start time and the elapsed time is set to 0.
-- 
-- 	Parameters:
-- 
-- 		scale	-	a time scaling factor, eg 4 will slow the timer by a factor of 4
-- 
	function  Ktimer.reset(ktimer,scale)

		if (scale) then
			ktimer.scale_ = 1.0 / scale 
		end
		ktimer.elapsed_time_ = 0.0 
		ktimer.start_time_ = Ktimer.time() 
	end

-- 
-- 	adjust()	-	adds a time adjustment
-- 
-- 	The adjustemnt is made to the start time.
-- 
-- 	Parameters:
-- 
-- 		dt	-	the time interval to add to the timer's start tiem
-- 

	function  Ktimer.adjust(ktimer, dt )
		-- 
		--  Not sure what to do about the scale!!!
		-- 
		ktimer.start_time_ = ktimer.start_time_  + dt 
	end

-- 
-- 	finished()	-	return whether the timer has finished
-- 
-- 	A timer is finished when the scaled elapsed time is >= 1.0.
-- 
-- 	Returns:
-- 
-- 		true if the timer has finished
-- 
	function  Ktimer.finished(ktimer) 
		return Ktimer.elapsed(ktimer) >= 1.0 
	end

-- 
-- 	range()	-	set the range for the parameterised animation value
-- 
-- 	The returned value is linearly interpolated and clipped to [ p1, p2 ] parametereised by
-- 	the elapsed time.
-- 
-- 	Parameters:
-- 
-- 		p1, p2	-	the start and end values of the animation
-- 
	function  Ktimer.range(ktimer,  p1,  p2 )	
		ktimer.p1_ = p1 
		ktimer.p2_ = p2 
	end

-- 
-- 	p()	-	return a parameterised animation value
-- 
-- 	The returned value is linearly interpolated and clipped to [ p1, p2 ] parametereised by
-- 	the elapsed time.
-- 
-- 	Parameters:
-- 
-- 		p1, p2	-	the start and end values of the animation
--  
-- 	Returns:
-- 
-- 		the parameterised value
-- 
	function  Ktimer.p(ktimer) 
		return Ktimer.p2(ktimer,ktimer.p1_,ktimer.p2_) 
	end

	function  Ktimer.p2(ktimer,  p1,  p2 ) --  const

		local elapsed_time = Ktimer.elapsed(ktimer) 
		local t = 0
		if (elapsed_time > 1.0) then
			t = 1.0
		else
			t = elapsed_time
		end
		return p1 - ( p1 - p2 ) * t 
	end

-- 
-- 	elapsed()	-	return the elapsed time
-- 
-- 	The elapsed time is the time that has passed since this time object was initialised or reset.
-- 	Elapsed time does not include periods when the timer is paused. The elapsed time is multiplied up
-- 	by the supplied scaling factor.
-- 
	function  Ktimer.elapsed(ktimer) --  const
		-- 
		--  If paused then return the last know elapsed time.
		-- 
		local elapsed_time = 0 
		
		if (ktimer.paused_) then
		 	elapsed_time = ktimer.elapsed_time_ 
		else
		 	elapsed_time = Ktimer.time() - ktimer.start_time_ 
		end
		
		return elapsed_time * ktimer.scale_ 
	end

-- 
-- 	paused()	-	accessor to the paused state of the time object
-- 
-- 	Returns:
-- 
-- 		true if the time object is paused
-- 
 	function  Ktimer.paused(ktimer) 
		return ktimer.paused_ 
	end

-- 
-- 	pause()		-	pause the time object
-- 
	function  Ktimer.pause(ktimer)

	-- 
	--  No need to do anything if already paused.
	-- 
		if ( not ktimer.paused_ ) then
			ktimer.elapsed_time_ = Ktimer.time() - ktimer.start_time_ 

			ktimer.paused_ = true 
		end
	end

-- 
-- 	resume()	-	continue a paused object
-- 
-- 	The start time is recalculated to take into account the time
-- 	at which the time object was paused.
-- 
	function  Ktimer.resume(ktimer)
		-- 
		--  No need to do anything if not paused.
		-- 
		if ( ktimer.paused_ ) then
			ktimer.start_time_ = Ktimer.time() - ktimer.elapsed_time_ 
			ktimer.paused_ = false 
		end

	end
	


end

