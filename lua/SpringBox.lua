-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not SpringBox) then

SpringBox				=	{}
SpringBox.className	    =	"SpringBox"
SpringBox.ZEROVEL_EPS	=	0.01

    function SpringBox.Create(startx,y,endx,m,r,k,time)

        local springbox = {
            osc             =   KDampedOscillator.Create( m or 1,  r or 12,  k or 100,0,0),
            osctimer        =	Ktimer.Create(1,true),
            y               =   y,
			time			= 	0,
			finishby		=	time or 5,
            className       =   SpringBox.className,
        }
        setmetatable(springbox,{__index = SpringBox } )
		springbox.osc:reset( endx,  0,  startx)
        return springbox
    end
	
	function SpringBox.Start(springbox)
		Ktimer.resume(springbox.osctimer)
	end
	

    function SpringBox.IsFinished(springbox)
        return (springbox.finishby and springbox.time > springbox.finishby)  
    end

	function SpringBox.IsStationary(springbox)
		 return KDampedOscillator.equilibrium(springbox.osc,Ktimer.elapsed(springbox.osctimer),SpringBox.ZEROVEL_EPS)
	end

    function SpringBox.Update(springbox,dt)
		springbox.time	=	springbox.time + dt
    end

    function SpringBox.GetPosition(springbox)
        local elapsed = Ktimer.elapsed(springbox.osctimer)
        local cx = KDampedOscillator.evaluate(springbox.osc, elapsed)
        return { x = cx, y =  springbox.y }
    end

end
