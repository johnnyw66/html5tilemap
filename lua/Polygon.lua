-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Polygon) then
Polygon						=	{}
Polygon.className			=	"Polygon"
Polygon.DEFAULTCOLOUR		=	{red = 127,green=0,blue = 0,alpha=127}
Polygon.RADIUSCOLOUR		=	{red = 31,green=31,blue = 31,alpha=127}

Polygon.COLLIDECOLOUR		=	{red = 127,green=0,blue = 127,alpha=127}
Polygon.NORMALCOLOUR		=	{red = 127,green=127,blue = 0,alpha=127}
Polygon.NORMALRENDERLENGTH	=	2

Polygon.DEFAULTCOLLISIONRADIUS		=	20
	
local TWOPI				=	3.1415926535897932386462643383279*2 

	function Polygon.Create(arrayOf2DPoints,radius,colour)

		local polygon = {
				x				=	0,
				y				=	0,
				z				=	z or 0,
				scale			=	1,
				radius			=	radius or 0,
				points			=	arrayOf2DPoints,
				colour			=	(colour and {red=colour.red,green=colour.green,blue=colour.blue,alpha=colour.alpha}) or 
									{red=Polygon.DEFAULTCOLOUR.red,green=Polygon.DEFAULTCOLOUR.green,blue=Polygon.DEFAULTCOLOUR.blue,alpha=Polygon.DEFAULTCOLOUR.alpha},
				dx				=	0,
				dy				=	0,
				debug			=	true,
				title			=	nil,
				className		=	Polygon.className,
		}
		
		setmetatable(polygon, { __index = Polygon })
		Polygon.Init(polygon)
		return polygon
	end


	
	function Polygon.Init(polygon)
		polygon.defaultcolour = Polygon.GetColour(polygon)
		Polygon.CalcEdgeNormals(polygon)
	end
	
	
	
	function Polygon.SetTitle(polygon,title)
		polygon.title = title 
	end
	
	function Polygon.SetScale(polygon,scale)
		polygon.scale	=	scale or 1
	end
	
	
	-- Create new table - Don't do this with release code!
	function Polygon.GetColour(polygon)
		local colour = polygon.colour 
		return {red=colour.red,green=colour.green,blue=colour.blue,alpha=colour.alpha}
	end
	
	function Polygon.SetColour(polygon,colour)
		-- Don't share 'em - Create a new colour table
		polygon.colour = {red=colour.red,green=colour.green,blue=colour.blue,alpha=colour.alpha}
	end
	
	-- We want to use this for testing - (rotating polygon around a fixed point)
	function Polygon.Clone(polygon)
		local pts = {}
		-- clone points table

		for i,pt in pairs(polygon.points) do
			table.insert(pts,{x = pt.x,y = pt.y})
		end

		local poly = Polygon.Create(pts,polygon.radius,polygon.colour)
		poly.x	=	polygon.x 
		poly.y	=	polygon.y
		poly.z	=	polygon.z
		return poly
	end
	
	function Polygon.SetPosition(polygon,x,y,z)
		polygon.x	=	x 
		polygon.y	=	y
		polygon.z	=	z or 0
	end
	
	
	function Polygon._RotateXYAround(x,y,cx,cy,angle)
		local rangle	=	math.rad(angle)
		local xt = x - cx
		local yt = y - cy
		
		-- -rangle (cos(-x) == cos(x), sin(-x) == -sin(x))
		
		local cos = math.cos(rangle) 
		local sin = -math.sin(rangle)
		
		local nx = xt*cos - yt*sin + cx
		local ny = xt*sin + yt*cos + cy
		
		return nx,ny
	end


	--		Rotate a polygon around 
	--		a point on the polygon (give index)
	--		or world coordinates.
	-- 		Angle is given in degrees
	-- 		Example:-  
	--		aPoly:Rotate(90,{type='point',index= 2})
	--		aPoly:Rotate(90,{type='coord',x=iPoly.x,y=iPoly.y})
	
	function Polygon.Rotate(polygon,angled,coords)
		
		-- Assume rotation around centre point
		local lpointx,lpointy = 0,0 
		
		if (coords and type(coords)=='table' and coords.type) then
			if (coords.type == 'point') then
				local pts 		 =  polygon.points 
				local pointOffset = coords.index
				lpointx = pts[pointOffset].x 
				lpointy = pts[pointOffset].y
			elseif (coords.type == 'position') then
				lpointx =  coords.x - polygon.x 
				lpointy =  coords.y - polygon.y
			end
		end
		Polygon.RotateLocal(polygon,angled,lpointx,lpointy)
	end
	
	function Polygon.RotateLocal(polygon,angled,lpointx,lpointy)	
		local angle = math.rad(angled)

		-- new local centre point
		local newcx,newcy =  Polygon._RotateXYAround(0,0,lpointx,lpointy,angle)

		-- New centre point 

		polygon.x = polygon.x + newcx 
		polygon.y = polygon.y + newcy
		
		for i,pt in pairs(polygon.points) do
				
			local xn,yn = Polygon._RotateXYAround(pt.x ,pt.y,lpointx,lpointy,angle)
			pt.x = xn - newcx 
			pt.y = yn - newcy
		end
		-- Recalc Normals
 		Polygon.CalcEdgeNormals(polygon)
	end
	
	function Polygon._Rot(pt,angle)
		local nx,ny = Polygon._RotateXYAround(pt.x,pt.y,0,0,angle)
		local newpt = {x = nx, y = ny}
		return newpt
	end
	
	function Polygon.Render(polygon,renderHelper,angle)
		
		local numPoints = #polygon.points
		local scale	=	polygon.scale
		local langle	=	angle or 0
		local xcen	=	polygon.x 
		local ycen 	=	polygon.y 
		local col	=	polygon.colour
		for i = 1, numPoints  do
			local startPt = Polygon._Rot(polygon.points[i],langle)
			local endPt = Polygon._Rot(polygon.points[i+1] or polygon.points[1],langle)
			RenderHelper.DrawLine(renderHelper,startPt.x*scale+xcen,startPt.y*scale+ycen,endPt.x*scale+xcen,endPt.y*scale+ycen,col)
		end
		
		 --Polygon._RenderEdgesCollision(polygon,renderHelper)
		
		
		if (polygon.debug) then
			RenderHelper.DrawCircle(renderHelper,xcen,ycen,polygon.radius*scale,Polygon.RADIUSCOLOUR,'line')
			RenderHelper.DrawCircle(renderHelper,xcen,ycen,2,Polygon.DEFAULTCOLOUR,'fill')
		end
		
		if (polygon.title) then
			RenderHelper.DrawText(renderHelper,polygon.title,xcen+polygon.radius*scale,ycen)
		end
		
		-- Draw Normals
--		Polygon.DrawEdgeNormals(polygon,renderHelper)
--		Polygon.DrawInclineInfo(polygon,renderHelper)
	end

	function Polygon.DrawInclineInfo(polygon,renderHelper)

		local scale 	=	polygon.scale
		local col		=	Polygon.NORMALCOLOUR
		local normLen	=	Polygon.NORMALRENDERLENGTH*scale
		
		
		for _,edge in pairs(polygon.edgeNormals) do
			local stx = edge.xmid*scale + polygon.x
			local sty = edge.ymid*scale + polygon.y
			local dstx= stx + normLen*edge.nx 
			local dsty= sty + normLen*edge.ny 
			--RenderHelper.DrawText(renderHelper,string.format("(%f,%f,%f)",edge.sin,edge.cos,edge.len),stx,sty)
			RenderHelper.DrawText(renderHelper,string.format("%d",edge.angle),stx,sty)
		end
	end
	
	
	function Polygon.DrawEdgeNormals(polygon,renderHelper)

		local scale 	=	polygon.scale
		local col		=	Polygon.NORMALCOLOUR
		local normLen	=	Polygon.NORMALRENDERLENGTH*scale
		
		
		for _,edge in pairs(polygon.edgeNormals) do
			local stx = edge.xmid*scale + polygon.x
			local sty = edge.ymid*scale + polygon.y
			local dstx= stx + normLen*edge.nx 
			local dsty= sty + normLen*edge.ny 
			RenderHelper.DrawLine(renderHelper,stx,sty,dstx,dsty,col)
		end
	end
	
	function Polygon.BuildRectPoly(width,height,angle)
		
					-- rotate by pole angle
		local wd2		= width/2
		local hd2		= height/2	
		local radius	= math.sqrt(wd2*wd2 + hd2*hd2)

		local poly =Polygon.Create(
					{
						{x 	=	-wd2, y = -hd2},
						{x 	=	 wd2, y = -hd2},
						{x 	=	 wd2, y = hd2},
						{x 	=	-wd2, y = hd2},
					}, radius)

		poly:Rotate(angle or 0)
		return poly			
	end
	
	
	-- Build Regular Polygon 
	function Polygon.BuildPoly(numPoints,radius,phase,colour)
		
		local polypoints = {}
		local points = numPoints
		local angle  = TWOPI/points
		local qrtpi	 = TWOPI/4 
		
		
		for i=1,points do
			local x = radius*math.cos(angle*(i-1)-qrtpi+(phase or 0))
			local y = radius*math.sin(angle*(i-1)-qrtpi+(phase or 0))
			table.insert(polypoints,{x = x,y = y})
		end

		local poly = Polygon.Create(polypoints,radius)
		poly.radius = radius 
		poly.colour	= colour or Polygon.DEFAULTCOLOUR
		return poly
	end
	
	function Polygon.BuildPolyFromUVPoints(points,width,height,colour)
		
		local polypoints = {}
		
		for idx,point in pairs(points) do
			local u = (point.px)*width
			local v = (point.py)*height
			table.insert(polypoints,{x = u,y = v})
		end
		local radius	=	width/math.sqrt(2)
		local poly = Polygon.Create(polypoints,radius)
		poly.radius = radius 
		poly.colour	= colour or Polygon.DEFAULTCOLOUR
		return poly
	end
	
	local function _getValue(tbl,string)
		return tbl[string]
	end
	

	function Polygon.BuildPolyFromUVProperties(properties,width,height,colour)
		
		local polypoints	= 	{}
		local MAXPOINTS		=	100
		
		for idx=1,MAXPOINTS do
			-- points define in tile (DAME) properties as
			-- p1x = 0.5, p1y = 0,
			
			-- values are between -0.5 to +0.5
			
			local px = properties["p"..idx.."x"]
			local py = properties["p"..idx.."y"]

			if ((not px) or (not py)) then
				assert( not (px or py),'tileInfo:COORDINATES MUST BE PAIRED: Index = '..idx)
				break
			end

			assert(type(px) == 'number' and (px >= -0.5) and (px <= 0.5),'tileInfo:Invalid X coordinate:'..px)
			assert(type(py) == 'number' and (py >= -0.5) and (py <= 0.5),'tileInfo:Invalid Y coordinate:'..py)

			local u = px*width
			local v = py*height
			table.insert(polypoints,{x = u,y = v})
		end
		
		local radius	=	width/math.sqrt(2)
		local poly = Polygon.Create(polypoints,radius)
		poly.radius = radius 
		poly.colour	= colour or Polygon.DEFAULTCOLOUR
		return poly
	end
	
	
	function Polygon.BuildPolyIreg(radius,angles,colour)

		local polypoints = {}
		local points = #angles 
		local rad	=	math.rad
		for i=1,points do
			local angle = rad(angles[i]-90)
			local x = radius*math.cos(angle)
			local y = radius*math.sin(angle)
			table.insert(polypoints,{x = x,y = y})
		end

		local poly = Polygon.Create(polypoints,radius)
		poly.radius = radius 
		poly.colour	= colour or Polygon.DEFAULTCOLOUR
		return poly
	end
	
	
	
	function Polygon.RenderTest(renderHelper)
	
		for _,poly in pairs(Polygon.testpolys) do
			Polygon.Render(poly,renderHelper)
		end
	end

	function Polygon.AddTestPoly(poly)
		table.insert(Polygon.testpolys,poly)
	end
	

	
	function Polygon.CalcEdgeNormals(polygon)
		--local ballradius	=	Polygon.DEFAULTCOLLISIONRADIUS		--	used to precalculate collision stuff for some default moving object of a given radius
		
		local points = polygon.points
		local numPoints = #points
		local edgeNormals = {}

		for i = 1,numPoints do
			local ept = points[i]
			local xpt = points[i+1] or points[1]
			local dx = xpt.x - ept.x
			local dy = xpt.y - ept.y

			local a	  = dx * dx + dy * dy
			local len = math.sqrt(a)
			table.insert(edgeNormals,{angle=math.deg(math.asin(-dy/len)),dx=dx,dy=dy,id = i,xc=ept.x,yc=ept.y,len=len,nex=dx/len,ney=dy/len,sin=-(dy/len),cos=(dx/len),nx=dy/len,ny=-dx/len,xmid=dx/2+ept.x,ymid=dy/2+ept.y,a = a,dx = dx, dy = dy,xe=xpt.x,ye=xpt.y})
		end
		polygon.edgeNormals = edgeNormals 
	end
	


	function Polygon.isXXXCollingPointEdge(x,y,edge,w,wey)
		
	
	end

	function Polygon.IsPointInside(polygon,xpos,ypos)
		local edgeNormals= polygon.edgeNormals
		local numEdges = #edgeNormals 

		local cx,cy = polygon.x,polygon.y 
		local othercx,othercy = xpos - cx,ypos - cy

		local points = polygon.points 
		
		for edgeidx,edge in pairs(edgeNormals) do
				local lx = othercx - edge.xc
				local ly = othercy - edge.yc
				local nx = edge.nx 
				local ny = edge.ny
				local dp = lx*nx+ly*ny
				if (dp >= 0) then
					return false
				end
		end
		return true
	end


	-- xpos,ypos is world pos of Poly
	-- px,py is world pos of test point
	-- angle is angle of poly
	-- scale is scale of poly
	
	function Polygon.IsPointInside2(polygon,xpos,ypos,px,py,angle,scale)
	
		-- We only need to test against local coord poly
	
		-- 1st make polygon centre of coord system
		local othercx,othercy = (px - xpos)/scale,(py - ypos)/scale
		
		-- Now rotate this point to compensate for tilt of Poly
		local rangle	=	math.rad(-angle)
		local xt 		=	othercx 
		local yt 		= 	othercy
	
		local cos 		= 	math.cos(rangle) 
		local sin 		=	-math.sin(rangle)
	 	othercx			=	xt*cos - yt*sin 
		othercy 		=	xt*sin + yt*cos 

		

		local edgeNormals= polygon.edgeNormals
		local numEdges = #edgeNormals 

	

		local points = polygon.points 
		
		for edgeidx,edge in pairs(edgeNormals) do
				local lx = othercx - edge.xc
				local ly = othercy - edge.yc
				local nx = edge.nx 
				local ny = edge.ny
				local dp = lx*nx+ly*ny
				if (dp >= 0) then
					return false
				end
		end
		return true
	end
	
	
	function Polygon.isCollidingSides(polygon,otherpoly)
		local edgeNormals= otherpoly.edgeNormals
		local numEdges = #edgeNormals 
		
		local othercx,othercy = otherpoly.x,otherpoly.y
		local points = polygon.points 
		local cx,cy = polygon.x,polygon.y 
		local largestradius = polygon.radius + otherpoly.radius
		
		for idx,pt in pairs(points) do
			local px = cx + pt.x
			local py = cy + pt.y
			local ptincount = 0
			local smallestdpedge = {dp = -largestradius,edgeid=-1,pointidx=idx,poly=otherpoly }
			for edgeidx,edge in pairs(edgeNormals) do
				local lx = px - (edge.xc + othercx)
				local ly = py - (edge.yc + othercy) 
				local nx = edge.nx 
				local ny = edge.ny
				local dp = lx*nx+ly*ny
				if (dp < 0) then
					ptincount = ptincount + 1
					-- I can see a problem here - if we travel too far through the object
					-- we will get inconsistent results in the edge we 1st pass through.
					if ((dp > smallestdpedge.dp)) then
						smallestdpedge.dp = dp
						smallestdpedge.edgeid = edgeidx
						smallestdpedge.edge = edge
					end
				end
			end
			if (ptincount == numEdges) then
				Logger.lprint("Point inside - Pt idx = "..idx.." Smallest DP on edge idx="..smallestdpedge.edgeid)
				return smallestdpedge
			end
		end
		
		return false
	end
	
	function Polygon.isCollidingCircle(polygon,otherpoly)
		local dx = polygon.x - otherpoly.x
		local dy = polygon.y - otherpoly.y
		local dist = math.sqrt(dx*dx + dy*dy)
		return dist < (polygon.radius + otherpoly.radius)
	end



	-- General equation of line go through points p1(x1,y2) and p2(x2,y2)
	-- P = p1 + u*(p2 - p1)
	-- In cartesian form	
	-- x = x1 + u*(x2 - x1)	  -- EQN1a
	-- y = y1 + u*(y2 - y1)   -- EQN1b 
	
	-- For points between p1 and p2  0 <= u <= 1
	-- general equation of line y = mx + c
	-- For 2nd line
	-- m = (y4-y3)/(x4-x3)
	-- c = y3 - m*x3 

	-- Subt y = mx + c in EQN1b  
	-- mx + c = y1 + u*(y2 - y1) -- EQN1c
	-- subt EQN1a for x in above equation 
	-- and solve for u
	
	function Polygon._LineSegmentIntercept(x1,y1,x2,y2,x3,y3,x4,y4)
	
		local l1DX	=	x2 - x1
		local l2DX	=	x4 - x3
		
		local l1DY	=	y2 - y1
		local l2DY	=	y4 - y3	
		
		local m = (l2DX ~= 0) and (l2DY/l2DX) or 100000000000
		local c = y3 - m*x3
		
		
		local uq = l1DY  - m * l1DX
		local t	 = (m*x1 + c - y1)
		local u = t / uq

		local xi = x1 + u*l1DX
		local yi = y1 + u*l1DY
		
		return {x = xi, y = yi, u = u, segmenttest = (u >= 0 and u <= 1)}
		
	end



	-- returns nil if no collision
	-- otherwise returns {px,py,dt,normalx,normaly}
	-- point of impact,normal of face and time used to get to this point
	 
	function Polygon.XXXwillCollide(polygon,otherpoly,sx,sy,vx,vy,dt)
		-- 1st check linesegment, colliding with circle
		
		-- work out end points we want to get to.
		
		local ex = sx + vx*dt
		local ey = sy + vy*dt

		
	end
	
	
	


	function Polygon._RenderEdgesCollision(polygon,renderHelper)
		local edgeNormals= polygon.edgeNormals
		local numEdges = #edgeNormals 
		local xcen		=	polygon.x
		local ycen		=	polygon.y
		for edgeidx,edge in pairs(edgeNormals) do
			local collide	=	edge.projectcollide
			local xs 	=	edge.xc + xcen
			local ys	=	edge.yc + ycen
			
			local xe	=	edge.xe + xcen
			local ye 	=	edge.ye + ycen
			local pcol	=	(collide  and Polygon.COLLIDECOLOUR or Polygon.DEFAULTCOLOUR)
			RenderHelper.DrawLine(renderHelper,xs,ys,xe,ye,pcol)
			
			local midx	=	edge.xmid*scale + xcen
			local midy	=	edge.xmid*scale	+ ycen
			
			if (collide) then
				local xm 	=	edge.xmid + xcen
				local ym	=	edge.ymid + ycen
				RenderHelper.DrawText(renderHelper,string.format("U1 %f U2 %f ROOT %f",collide.u1,collide.u2,collide.root),xm,ym) ;
			end
		end
	end
	
	function Polygon._CheckEdgesCollideAgainstCircle(polygon,xc,yc,radius)
		local edgeNormals= polygon.edgeNormals
		local numEdges = #edgeNormals 

		-- Translate sphere we are checking against to local polygon coords
		local xcT	=	xc - polygon.x	
		local ycT	=	yc - polygon.y

		for edgeidx,edge in pairs(edgeNormals) do
			Polygon._EdgeCheckAgainstCircle(xcT,ycT,radius,edge)
		end
	end
	
	function Polygon._EdgeCheckAgainstCircle(xc,yc,radius,edge)
	
		local dx 	= 	edge.dx 
		local dy 	= 	edge.dy
		local a  	= 	edge.a
		local len 	= 	edge.len
		local fact 	= 	radius/len
		
		local xs 	=	edge.xc
		local ys	=	edge.yc
		

		local dp 				=	((xc - xs)*dx + (yc - ys)*dy)/a 
		local linecollision 	=	(dp >= -fact and dp <=(1+fact)) 
		edge.projectcollide 	= 	nil

		if (linecollision) then
			local nx	=	dy/len
			local ny	=	-dx/len
			local xe	=	edge.xe
			local ye	=	edge.ye
			dp 	= 	(xe - xc)*nx + (ye-yc)*ny
			linecollision = (math.abs(dp) < radius)
			if (linecollision) then
				local dcx	=	xs - xc
				local dcy	=	ys - yc
				local b = 2*(dx*dcx + dy*dcy)
				local c = xc*xc + yc*yc  + xs*xs + ys*ys - 2*(xc*xs + yc*ys) - radius*radius

				local rt = b*b - 4*a*c
				local srt = (rt > 0 and math.sqrt(rt) or -1)
				local recp = 1/(2*a)
				local u1 = (-b + srt)*recp
				local u2 = (-b - srt)*recp
				edge.projectcollide = ((u1 >= 0 and u1 <= 1) or (u2 >=0 and u2 <= 1)) and {root = srt, u1 = u1, u2 = u2, distance = dp}
			end
		end

	end
	
	
	-- Circle/Line Segment Check
	
	
	function Polygon._CircleVLineSegmentCollisionCheck(xc,yc,radius,xs,ys,xe,ye)
		local dx	=	xe - xs 
		local dy	=	ye - ys
		local a 	= 	dx*dx + dy*dy
		local len	=	math.sqrt(a)
		local fact 	=   radius/len 
		
		local dp 				=	((xc - xs)*dx + (yc - ys)*dy)/a 
		local linecollision 	=	(dp >= -fact and dp <=(1+fact)) 
		
		-- return if false here
		if (not linecollision) then
			return false,dp,nil,'part1'
		end
		
		
		local nx	=	dy/len
		local ny	=	-dx/len
		
		dp 	= 	(xe - xc)*nx + (ye-yc)*ny
		linecollision = (math.abs(dp) < radius)
		
		-- alternatively 
		
		local intersect = nil
		
		if (linecollision) then

			local dcx	=	xs - xc
			local dcy	=	ys - yc
			local b = 2*(dx*dcx + dy*dcy)
			local c = xc*xc + yc*yc  + xs*xs + ys*ys - 2*(xc*xs + yc*ys) - radius*radius
		
			local rt = b*b - 4*a*c
			local srt = (rt > 0 and math.sqrt(rt) or -1)
			local recp = 1/(2*a)
			local u1 = (-b + srt)*recp
			local u2 = (-b - srt)*recp
			intersect = {root = srt, u1 = u1, u2 = u2}
		end
		return linecollision,dp,intersect,'part2'
	end

	function Polygon.CollisionDebug(polygon,collide)
		if (collide) then
			polygon:SetColour(Polygon.COLLIDECOLOUR)
		else
			polygon:SetColour(polygon.defaultcolour)
		end
	end
	
	
	function Polygon.isColliding(polygon,otherpoly)

		if (Polygon.isCollidingCircle(polygon,otherpoly)) then
			local edge = Polygon.isCollidingSides(polygon,otherpoly)
			if (edge) then
				otherpoly:SetColour(Polygon.COLLIDECOLOUR)
			end
			return edge
		else
			otherpoly:SetColour(otherpoly.defaultcolour)
			return false
		end
		
	end

	
	function Polygon.CollisionTest(polygon,others)
		for _,poly in pairs(others) do
			if (polygon:isColliding(poly)) then
			end
		end
	end
	
	
	
	function Polygon.InitTest(numPolys,numpts,radius,phase,posFunc)
		Polygon.testpolys = {}
		local rnd = math.random 
		for i = 1, numPolys do
			local poly = Polygon.BuildPoly(numpts or rnd(3,5),radius or (30+rnd(20)),phase or rnd()*TWOPI)

			local xpos,ypos = rnd(1024),rnd(720)
			if (posFunc) then
				xpos,ypos = posFunc()
			end
			poly:SetPosition(xpos,ypos)
			table.insert(Polygon.testpolys,poly)
		end
		return Polygon.testpolys 
	end
	

	function Polygon.unitTest()
	
	 	-- test y = 4x + 1 , y = -2x + 5 intercept @ (2/3,11/3) u = 5/18
	 	res = Polygon._LineSegmentIntercept(-1,-3,5,21,0,5,4,-3)

	 	res = Polygon._LineSegmentIntercept(5,0,5,4,0,5,4,-3)
	 	res = Polygon._LineSegmentIntercept(5,0,5,4,6,0,6,20)
	
	 	assert(false,string.format("U = %f x = %f y = %f",res.u,res.x,res.y))
	
	end
	
	
	
end
