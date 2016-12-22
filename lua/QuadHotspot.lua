-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
-- Johnny - June 2012

if (not QuadHotspot) then
-- Needs Vector4
QuadHotspot 				=	{}
QuadHotspot.className		=	"QuadHotspot"
QuadHotspot.DEFAULTDEPTH	=	0.125
	
	function QuadHotspot.Create(quads,depth,name)
		local quadhotspot = {
			quads		=	quads,
			name		=	name or "NONAME",
			depth		=	depth or QuadHotspot.DEFAULTDEPTH,
			className	=	QuadHotspot.className,	
		}
	  	setmetatable(quadhotspot,{ __index = QuadHotspot }) 
		QuadHotspot._Init(quadhotspot)
		return quadhotspot 
	end
	
	local function _subtractv(v1,v2)
		local answ = Vector4.Create()
		answ:Subtract(v1,v2)
		return answ
	end
	
	function QuadHotspot._Init(quadhotspot)
		-- Find Equation of plane - Normal

		-- Make sure we have our own copies of vectors.
		local	quads		=	quadhotspot.quads
		local	nquads		=	{Vector4.Create(quads[1]), Vector4.Create(quads[2]), Vector4.Create(quads[3]), Vector4.Create(quads[4])}
		quadhotspot.quads	=	nquads	
		-- Work out normal to plane
		quadhotspot.normal		=	Vector4.Create()
		quadhotspot.Enormal1	=	Vector4.Create()
		quadhotspot.Enormal2	=	Vector4.Create()
		quadhotspot.Enormal3	=	Vector4.Create()
		quadhotspot.Enormal4	=	Vector4.Create()

--		quadhotspot.normal2	=	Vector4.Create()
--		quadhotspot.normal3	=	Vector4.Create()
--		quadhotspot.normal4	=	Vector4.Create()

		Vector4.Cross(quadhotspot.normal,_subtractv(nquads[3], nquads[1]),_subtractv(nquads[2] , nquads[1]))
		Vector4.Normalize3(quadhotspot.normal)
		
		quadhotspot.D		=	-Vector4.Dot3(quadhotspot.normal,nquads[1])	
	
		-- Now recalculate Y coord of 4th point
		-- Make all our points are on the same plane!

		local		rY		=	-(quadhotspot.D + quadhotspot.normal:X()*nquads[4]:X() + quadhotspot.normal:Z()*nquads[4]:Z())/quadhotspot.normal:Y()
		nquads[4]:SetY(rY)	
		local eps	=	0.001
		
		assert(math.abs(Vector4.Dot3(quadhotspot.normal,nquads[1]) + quadhotspot.D) <= eps,"SHOULD BE 0")
		assert(math.abs(Vector4.Dot3(quadhotspot.normal,nquads[2]) + quadhotspot.D) <= eps,"SHOULD BE 0")
		assert(math.abs(Vector4.Dot3(quadhotspot.normal,nquads[3]) + quadhotspot.D) <= eps,"SHOULD BE 0")
		assert(math.abs(Vector4.Dot3(quadhotspot.normal,nquads[4]) + quadhotspot.D) <= eps,"SHOULD BE 0")

		-- Calculate Edge Normals
		
		Vector4.Cross(quadhotspot.Enormal1,quadhotspot.normal,_subtractv(nquads[2] , nquads[1]))
		Vector4.Cross(quadhotspot.Enormal2,quadhotspot.normal,_subtractv(nquads[3] , nquads[2]))
		Vector4.Cross(quadhotspot.Enormal3,quadhotspot.normal,_subtractv(nquads[4] , nquads[3]))
		Vector4.Cross(quadhotspot.Enormal4,quadhotspot.normal,_subtractv(nquads[1] , nquads[4]))

		Vector4.Normalize3(quadhotspot.Enormal1)
		Vector4.Normalize3(quadhotspot.Enormal2)
		Vector4.Normalize3(quadhotspot.Enormal3)
		Vector4.Normalize3(quadhotspot.Enormal4)


		
			
		
--		Vector4.Cross(quadhotspot.normal2,(nquads[1] - nquads[2]),(nquads[3] - nquads[2]))
--		Vector4.Cross(quadhotspot.normal3,(nquads[2] - nquads[3]),(nquads[4] - nquads[3]))
--		Vector4.Cross(quadhotspot.normal4,(nquads[3] - nquads[4]),(nquads[1] - nquads[4]))
--		
--		Vector4.Normalize3(quadhotspot.normal2)
--		Vector4.Normalize3(quadhotspot.normal3)
--		Vector4.Normalize3(quadhotspot.normal4)
		
--		quadhotspot.D2		=	-Vector4.Dot3(quadhotspot.normal,nquads[2])		
--		quadhotspot.D3		=	-Vector4.Dot3(quadhotspot.normal,nquads[3])		
--		quadhotspot.D4		=	-Vector4.Dot3(quadhotspot.normal,nquads[4])		
--		print("QuadSpot._Init (D)",quadhotspot.D,quadhotspot.D2,quadhotspot.D3,quadhotspot.D4)
--		print("QuadSpot._Init N1",quadhotspot.normal)
--		print("QuadSpot._Init N2",quadhotspot.normal2)
--		print("QuadSpot._Init N3",quadhotspot.normal3)
--		print("QuadSpot._Init N4",quadhotspot.normal4)
		
			
	end
	


	-- Build Regular QHS 

	function QuadHotspot.Build2DPoly(tx,tz,radius,phase,colour)
		
		local polypoints = {}
		local points = 4
		local angle  = 2*math.pi/points
		local qrtpi	 = 2*math.pi/4 
		
		for i=1,points do
			local x = radius*math.cos(angle*(i-1)-qrtpi+(phase or 0))
			local z = radius*math.sin(angle*(i-1)-qrtpi+(phase or 0))
			table.insert(polypoints,Vector4.Create(tx+x,0,tz+z))
		end
		local qhs = QuadHotspot.Create(polypoints,0.5)
--		qhs.cenx,qhs.cenz	=	tx,tz
		return qhs
	end
	
	function QuadHotspot._GetCentre(quadhotspot)
		local	quads		=	quadhotspot.quads
		local x,y,z			=	0,0,0
		for k,v in pairs(quads) do
			
			x 	=	x + v:X()
			y 	=	y + v:Y()
			z 	=	z + v:Z()
			
		end
		return x/4,y/4,z/4
	end
	
--	function Polygon.BuildPolyIreg(radius,angles,colour)
--
--		local polypoints = {}
--		local points = #angles 
--		local rad	=	math.rad
--		for i=1,points do
--			local angle = rad(angles[i]-90)
--			local x = radius*math.cos(angle)
--			local y = radius*math.sin(angle)
--			table.insert(polypoints,{x = x,y = y})
--		end
--
--		local poly = Polygon.Create(polypoints,radius)
--		poly.radius = radius 
--		poly.colour	= colour or Polygon.DEFAULTCOLOUR
--		return poly
--	end
	
	
	function QuadHotspot.SetName(quadhotspot,name)
		quadhotspot.name	=	name
	end

	function QuadHotspot.GetRawQuads(quadhotspot)
		return quadhotspot.quads
	end

	function QuadHotspot.GetName(quadhotspot,name)
		return quadhotspot.name
	end
	
	
	local function _Dot2(v1,v2)
		-- Dot2 takes x and z components of 2 Vector4's to produce 2D dot product
		return v1:X()*v2:X() + v1:Z()*v2:Z()
		--return Vector4.Dot3(v1,v2)
		
	end
	
	
	function QuadHotspot.IsPointInside(quadhotspot,point,somedepth)
--		Logger.lprint("QuadHotspot.IsPointInside"..point:X()..","..point:Y()..","..point:Z())
		local dpth	=	somedepth or quadhotspot.depth
		local quads	=	quadhotspot.quads
		-- Ignore Y! - becareful now - watch GC!!
		local v1	=	_Dot2(quadhotspot.Enormal1,_subtractv(point,quads[1]))
		local v2	=	_Dot2(quadhotspot.Enormal2,_subtractv(point,quads[2]))
		local v3	=	_Dot2(quadhotspot.Enormal3,_subtractv(point,quads[3]))
		local v4	=	_Dot2(quadhotspot.Enormal4,_subtractv(point,quads[4]))

		quadhotspot.debug	=	{v1	= v1, v2 = v2, v3 = v3, v4 = v4, pdist = QuadHotspot.DistanceFromPlane(quadhotspot,point)}
		return (v1 < 0) and (v2 < 0) and (v3 < 0) and (v4 < 0) and QuadHotspot.DistanceFromPlane(quadhotspot,point) <= dpth
	end
		
	function QuadHotspot.DistanceFromPlane(quadhotspot,point) 
		return math.abs(Vector4.Dot3(point,quadhotspot.normal) + quadhotspot.D)
	end

	function QuadHotspot.RenderDebug(quadhotspot,renderHelper,point,x,y)
		local	defaultCol		=	{255,255,0,64}
		local	insideCol		=	{255,0,0,255}	

		if (point) then
			local inside = QuadHotspot.IsPointInside(quadhotspot,point)
			if (quadhotspot.debug) then

				local dbg 	=	quadhotspot.debug
				local col	=	inside and insideCol or defaultCol
				renderHelper:DrawText(
					string.format("NAME:%s v1 = %.2f, v2 = %.2f, v3 = %.2f, v4 = %.2f pdist = %.2f",
							quadhotspot:GetName(),
							dbg.v1,
							dbg.v2,
							dbg.v3,
							dbg.v4,
							dbg.pdist),x,y,1,col,"left","top")
			end
		else
			renderHelper:DrawText(string.format("NAME:%s ",quadhotspot:GetName()),x,y,1,col,"left","top")
		end
		
		
	end
	
	function QuadHotspot.Render(quadhotspot,renderHelper,col)
		if (love) then
			QuadHotspot.Render2D(quadhotspot,renderHelper,col)
		else
			QuadHotspot.Render3D(quadhotspot,renderHelper,col)
		end
	end
	
	function QuadHotspot.Render3D(quadhotspot,renderHelper,col)
		assert(quadhotspot.className and quadhotspot.className == QuadHotspot.className,'NOT A QUADHOTSPOT!')
		local dcol	=	col or Vector4.Create( 1, 0, 1, 1 )
		local qquad	=	QuadHotspot.GetRawQuads(quadhotspot)
		Debug.DrawQuad3d(qquad[1],qquad[2],qquad[3],qquad[4],dcol,true)
	end


	function QuadHotspot.Render2D(quadhotspot,renderHelper,col)
		local dcol	=	col or {255,255,0,255}
		local qquad	=	QuadHotspot.GetRawQuads(quadhotspot)
		local x1,y1	=	qquad[1]:X(),qquad[1]:Z()
		local x2,y2	=	qquad[2]:X(),qquad[2]:Z()
		local x3,y3	=	qquad[3]:X(),qquad[3]:Z()
		local x4,y4	=	qquad[4]:X(),qquad[4]:Z()

		RenderHelper.DrawLine(renderHelper,x1,y1,x2,y2,dcol)
		RenderHelper.DrawLine(renderHelper,x2,y2,x3,y3,dcol)
		RenderHelper.DrawLine(renderHelper,x3,y3,x4,y4,dcol)
		RenderHelper.DrawLine(renderHelper,x4,y4,x1,y1,dcol)

	end
	
end
