-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Spring) then

Spring					=	{}
Spring.className	    =	"Spring"
Spring.ZEROVEL_EPS		=	0.01

    function Spring.Create(startpos,endpos,m,r,k,time,pause)

        local spring = {
            osc             =   KDampedOscillator.Create( m or 1,  r or 12,  k or 100,0,0),
            osctimer        =	Ktimer.Create(1,pause),
			time			= 	0,
			startpos		=	startpos,
			endpos			=	endpos,
			finishby		=	time or 5,
            className       =   Spring.className,
        }
        setmetatable(spring,{__index = Spring } )
		spring.osc:reset( startpos,  0,  endpos)
        return spring
    end

	function Spring.Resume(spring)
		Ktimer.resume(spring.osctimer)
	end

    function Spring.IsFinished(spring)
        return (spring.finishby and spring.time > spring.finishby)
    end

	function Spring.IsStationary(spring)
		 return KDampedOscillator.equilibrium(spring.osc,Ktimer.elapsed(spring.osctimer),Spring.ZEROVEL_EPS)
	end

    function Spring.Update(spring,dt)
		spring.time	=	spring.time + dt
--		if (Spring.IsFinished(spring)) then
--            spring.osc:reset(spring.endpos, 0, spring.endpos)
--        end
    end

    function Spring.GetPosition(spring)
		if (Spring.IsFinished(spring)) then
			return spring.endpos
		else
			return KDampedOscillator.evaluate(spring.osc, Ktimer.elapsed(spring.osctimer))
		end
    end

end
