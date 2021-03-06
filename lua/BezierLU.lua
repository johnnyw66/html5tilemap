-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not BezierLU then

BezierLU				=	{}
BezierLU.className		=	"BezierLU"
local floor				=	math.floor
local min				=	math.min

	
	function BezierLU.Create( cp0,  cp1, cp2, cp3, steps)

		local bezier = {
					lookup		=	{},
					steps		=	steps or 1024,
					className	=	BezierLU.className,	
				}

		setmetatable(bezier,{ __index = BezierLU })

		BezierLU._Init(bezier, cp0, cp1, cp2, cp3)
		return bezier 
		
	end
	
	function BezierLU._Init(bezier, cp0,  cp1, cp2, cp3)
		local bzcurve	= 	Bezier.Create(cp0, cp1, cp2, cp3)
		bezier.length	= 	Bezier._CalcLength(bzcurve)	 

		bezier.lookup	=	{}
		local lookup	=	bezier.lookup
		
		local	steps	=	bezier.steps
		
		for ti = 0, steps	do
			local t			=	ti/steps
			local x,y		=	Bezier.GetPositionXY(bzcurve,t)
			local length	=	Bezier._CalcLength(bzcurve,t)	-- TO DO function to calculate length
									-- at time t
			lookup[ti]		=	{ x = x, y = y,length = length }
		end
		
	end
	
	function BezierLU.GetLength(bezier)
		return  bezier.length
	end
	
	
	function BezierLU.GetPosition( bezier,t)
		local x,y	=	 BezierLU.GetPositionXY(bezier,t)
	    return Vector2.Create(x,y)
	end
	
	function BezierLU.GetPositionXY(bezier,t)
		local pos	=	bezier.lookup[floor(min(t,1)*bezier.steps)]
	    return pos.x,pos.y
	end

	-- end of class
	
end

