-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not Line2D then

Line2D								=	{ }
Line2D.className					=	"Line2D" 
local	tempV						=	Vector4.Create()
local	zeroVector					=	Vector4.Create(0.7,0.7,0,0)


	function Line2D.Create( startpoint,  endpoint)

		local line2d = {
				startpoint		=	startpoint,
				endpoint		=	endpoint,
				direction		=	Vector4.Create(),
				unit			=	Vector4.Create(),
				className		=	Line2D.className,

		}
		setmetatable(line2d, {__index = Line2D })
		Line2D.CalculateCentreAndRadius(line2d)
		return line2d 
	end

	function Line2D.SetPoints(line2d,startpoint,endpoint)
		line2d.startpoint:SetXyzw(startpoint:X(),startpoint:Y(),0,0)
		line2d.endpoint:SetXyzw(endpoint:X(),endpoint:Y(),0,0)
		Line2D.CalculateCentreAndRadius(line2d)
	end
	

	---- Method CalculateCentreAndRadius () 
	
	function Line2D.CalculateCentreAndRadius(line2d)
	
		Vector4.Subtract(line2d.direction,line2d.endpoint,line2d.startpoint)
		line2d.length 	=	Vector4.Length2(line2d.direction)
		line2d.radius	=	line2d.length / 2
		line2d.unit		=	line2d.length == 0 and zeroVector or Vector4.Normal2(line2d.direction)
		line2d.midpoint	=	Vector4.Create()
		Vector4.Multiply(line2d.midpoint,line2d.unit,line2d.radius)
		Vector4.Add(line2d.midpoint,line2d.midpoint,line2d.startpoint)
		
	end
	
	function Line2D.Intersects(line1,line2)
		local intersectionPoint = Vector4.Create()
		local doesintersect,u,v,z,w = Vector4.Calculate2dLineIntersection(intersectionPoint,  line1.startpoint,  line1.endpoint,  line2.startpoint,  line2.endpoint,  false )
		return (doesintersect and intersectionPoint)
	end
	
	function Line2D.Render(line2d,renderHelper)
		Line2D.RenderDebug(line2d,renderHelper)
	end

	function Line2D.RenderDebug(line2d,renderHelper)

 		RenderHelper.SetColour(renderHelper, {255, 255, 255, 128} )
		RenderHelper.DrawCircle(renderHelper,line2d.startpoint:X(),line2d.startpoint:Y(),4)
	--	Logger.lprint(string.format("Line2D %d,%d",line2d.startpoint:X(),line2d.startpoint:Y()))

		RenderHelper.DrawLine(renderHelper,
		line2d.startpoint:X(),line2d.startpoint:Y(),
		line2d.endpoint:X(),line2d.endpoint:Y())

 		RenderHelper.SetColour(renderHelper, {255, 0, 0, 128} )
		RenderHelper.DrawCircle(renderHelper,line2d.midpoint:X(),line2d.midpoint:Y(),4)
		
	end

	function Line2D.toString(line2d)
		local str =	{}
		return table.concat(str)
	end
	

end
