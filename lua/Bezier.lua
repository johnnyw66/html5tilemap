-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not Bezier then

Bezier				=	{}
Bezier.className	=	"Bezier"

	
	function Bezier.Create( cp0,  cp1, cp2, cp3)

		local bezier = {
					p1	=	cp0,
					p2	=	cp1,
					p3	=	cp3,
					p4	=	cp0,
					vCP,cx,bx,ax,cy,by,ay,
					className=Bezier.className,	
				}

		bezier.vCP	=	Vector2.Create(cp0) 
	    bezier.cx	=	3.0 * (cp1.x - cp0.x) 
	    bezier.bx	=	3.0 * (cp2.x - cp1.x) - bezier.cx 
	    bezier.ax	=	cp3.x - cp0.x - bezier.cx - bezier.bx
	    bezier.cy	=	3.0 * (cp1.y - cp0.y)
	    bezier.by	=	3.0 * (cp2.y - cp1.y) - bezier.cy
	    bezier.ay	=	cp3.y - cp0.y - bezier.cy - bezier.by

		setmetatable(bezier,{ __index = Bezier })
		bezier.length	= Bezier._CalcLength(bezier)	 
		return bezier 
		
	end
	
	function Bezier.GetLength(bezier)
		return bezier.length
	end
	
	
	function Bezier.GetPosition( bezier,t)
		local x,y =  Bezier.GetPositionXY(bezier,t)
	    return Vector2.Create(x,y)
	end
	
	function Bezier.GetPositionXY(bezier,t)

	 	local   tSquared, tCubed
	    tSquared = t * t
	    tCubed = tSquared * t
	        
	    local resultx = (bezier.ax * tCubed) + (bezier.bx * tSquared) + (bezier.cx * t) + bezier.vCP.x
	    local resulty = (bezier.ay * tCubed) + (bezier.by * tSquared) + (bezier.cy * t) + bezier.vCP.y
	        
	    return resultx,resulty
	end


	function Bezier.GetPrimeT(bezier,tv)
		local	t	=	tv or 1
	 	local   tSquared
	    tSquared = t * t
	    -- work out dx/dt and dy/dt    
	    local resultx = (3*bezier.ax * tSquared) + (2*bezier.bx * t) + (bezier.cx) 
	    local resulty = (3*bezier.ay * tSquared) + (2*bezier.by * t) + (bezier.cy)
	    return math.sqrt(resultx*resultx + resulty*resulty)	
	end
	
	function Bezier.Cleanup(bezier)
		bezier.vCP = nil
	end
	
	function Bezier._CalcLength(bezier,fft)
	
		local ft	=	fft	or 1

		-- Integrate using Trapezium rule
		local N	 = 	100
		local n	 =	math.floor(ft*N)
		local dt =	1/N -- 0.01 == one hundred bits
		
		local sum1 	=	(Bezier.GetPrimeT(bezier,0) + Bezier.GetPrimeT(bezier,ft))/(2*n)
		local sum	=	0
		for t = dt,ft - dt, dt do
			sum	=	sum	+	 Bezier.GetPrimeT(bezier,t)
		end
		return sum/n + sum1
		
	end
	
-- end of class
end

