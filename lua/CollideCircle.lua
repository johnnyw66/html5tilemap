-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not CollideCircle then

CollideCircle				=	{ }
CollideCircle.className		=	"CollideCircle" 
local	tempV				=	Vector4.Create()

	function CollideCircle.Create( radius,debug)

		local collidecircle = {
				radius			=	radius,
				radsq			=	radius*radius,
				className		=	CollideCircle.className,

		}
		setmetatable(collidecircle, {__index = CollideCircle })
		CollideCircle._Init(collidecircle)
		return collidecircle 
	end

	function CollideCircle._Init(collidecircle)
	
	end
	
	function CollideCircle.Render(collidecircle,renderHelper,position)
		CollideCircle.RenderDebug(collidecircle,renderHelper,position)
	end

	function CollideCircle.RenderDebug(collidecircle,renderHelper,position)
		RenderHelper.DrawCircle(renderHelper,position:X(),position:Y(),collidecircle.radius,{255, 0, 0, 255},'line')
	end

	function CollideCircle.IsPointInside(collidecircle,position,point)
		local x,y = point:GetXY()
		local px,py	=	position:GetXY()
		local dx	=	(px - x)
		local dy	=	(py - y)
		return dx*dx + dy*dy < collidecircle.radsq
	end

	function CollideCircle.toString(collidecircle)
		local str =	{}
		return table.concat(str)
	end
	

end
