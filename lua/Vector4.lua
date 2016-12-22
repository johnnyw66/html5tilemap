-- @copyright Affinity Studios Ltd 2007-2011 John Wilson
if (not Vector4) then

Vector4 = {}
Vector4.className = 'Vector4'

	function Vector4.CreateBroadcast(number)
		local v = Vector4.Create()
		v:SetBroadcast(number)
		return v
	end
	
    function Vector4.Create(...)
        local args = {...}
        local t = args[1]
        if (not t or type(t) == 'number') then
            return Vector4._CreateScalar(...)
        else
            return Vector4._CreateVector(...)
        end
    end

	function Vector4._CreateVector(v)
        assert(v and v.className == 'Vector4','Vector4._CreateVector: THIS IS NOT A VECTOR')

		local vector4 = {
			_x = (v and v:X()) or 0,
			_y = (v and v:Y()) or 0,
			_z = (v and v:Z()) or 0,
			_w = (v and v:W()) or 0,
            className = Vector4.className,
		}
		setmetatable(vector4, { __index = Vector4 })

 --       local dbg = string.format("_cv vector = %f %f %f %f",vector4._x,vector4._y,vector4._z,vector4._w)
        --local dbg = string.format("_cv vector(arg) = %f %f %f %f",v._x,v._y,v._z,v._w)

--        assert(false,dbg)

		return vector4
	end

	function Vector4._CreateScalar(x,y,z,w)
		local vector4 = {
			_x = x or 0,
			_y = y or 0,
			_z = z or 0,
			_w = w or 0,
            className = 'Vector4',
		}
		setmetatable(vector4, { __index = Vector4 })
		return vector4
	end
	
	function Vector4.SetBroadcast(vector4,val)
		vector4:SetXyzw(val,val,val,val)
	end
	
	function Vector4.X(vector4)
		return vector4._x
	end
	
	function Vector4.Y(vector4)
		return vector4._y
	end
	
	function Vector4.Z(vector4)
		return vector4._z
	end
	
	function Vector4.W(vector4)
		return vector4._w
	end

	function Vector4.SetX(vector4,val)
		vector4._x = val
	end
	
	function Vector4.SetY(vector4,val)
		vector4._y = val
	end
	
	function Vector4.SetZ(vector4,val)
		vector4._z = val
	end

	function Vector4.SetW(vector4,val)
		vector4._w = val
	end
	
	function Vector4.SetXyzw(vector4,x,y,z,w)
		Vector4.SetX(vector4,x or 0)
		Vector4.SetY(vector4,y or 0)
		Vector4.SetZ(vector4,z or 0)
		Vector4.SetW(vector4,w or 0)
	end
	
	function Vector4.Copy(dest,source)
		dest._x	= 	source._x 
		dest._y	= 	source._y
		dest._z	=	source._z
		dest._w	=	source._w
	end

	function Vector4.Subtract(newv,v1,v2)
		newv._x 	=	v1._x - v2._x
		newv._y	=	v1._y - v2._y
		newv._z	=	v1._z - v2._z
		newv._w	=	v1._w - v2._w
	end

	function Vector4.Add(newv,v1,v2)
		newv._x 	=	v1._x + v2._x
		newv._y	=	v1._y + v2._y
		newv._z	=	v1._z + v2._z
		newv._w	=	v1._w + v2._w
	end

	function Vector4.Divide(dst,src1,src2)
		assert(false,"Vector4.Divide: NOT YET IMPLEMENTED")
	end
	
	function Vector4.Cross(dst,src1,src2)
		dst._x = ( src1._y * src2._z ) - ( src1._z * src2._y ) 
		dst._y = ( src1._z * src2._x ) - ( src1._x * src2._z ) 
		dst._z = ( src1._x * src2._y ) - ( src1._y * src2._x )
	end
	
	function Vector4.Multiply(dst,src,scale)
		-- TODO VARIATIONS
		dst._x	=	src._x * scale
		dst._y	=	src._y * scale
		dst._z	=	src._z * scale
	end

	function Vector4.ScaleXXX(vector4,scale)
		vector4._x	=	vector4._x * scale
		vector4._y	=	vector4._y * scale
		vector4._z	=	vector4._z * scale
	end
	
	function Vector4.Length4(vector4)
		return math.sqrt(vector4._x * vector4._x + vector4._y * vector4._y + vector4._z * vector4._z + vector4._w * vector4._w)
	end

	function Vector4.Length3(vector4)
		return math.sqrt(vector4._x * vector4._x + vector4._y * vector4._y + vector4._z * vector4._z)
	end
	
	function Vector4.Length2(vector4)
		return math.sqrt(vector4._x * vector4._x + vector4._y * vector4._y)
	end
	
	function Vector4.mag(vector4)
		return math.sqrt(vector4._x * vector4._x + vector4._y * vector4._y + vector4._z * vector4._z + vector4._w * vector4._w)
	end
	
	function Vector4.Normal2(vector4)
		local v = Vector4.Create(vector4)
		v._z = 0
		v._w = 0
		v:Normalise2()
		return v
	end
	
	function Vector4.Normal3(vector4)
		local v = Vector4.Create(vector4)
		v._w	 = 0
		v:Normalise3()
		return v
	end
	
	function Vector4.Normal4(vector4)
		local v = Vector4.Create(vector4)
		v:Normalise4()
		return v
	end
	
	function Vector4.Normalise2(vector4)
		local len  = vector4:Length2()
		assert(len ~= 0,'Normalise2 - Attemp to Normalise with Zero Length Vector:'..Vector4._toString(vector4))
		Vector4.SetXyzw(vector4,vector4._x / len, vector4._y / len, vector4._z,vector4._w)
	end
	
	function Vector4.Normalize3(vector4)
		return Vector4.Normalise3(vector4)
	end
	
	function Vector4.Normalise3(vector4)
		local len  = vector4:Length3()
		assert(len ~= 0,'Normalise3 - Attemp to Normalise with Zero Length Vector:'..Vector4._toString(vector4))
		Vector4.SetXyzw(vector4,vector4._x / len, vector4._y / len, vector4._z / len,vector4._w)
	end

	function Vector4.Normalise4(vector4)
		local len  = vector4:Length4()
		assert(len ~= 0,'Normalise4 - Attemp to Normalise with Zero Length Vector:'..Vector4._toString(vector4))
		Vector4.SetXyzw(vector4,vector4._x / len, vector4._y / len, vector4._z / len,vector4._w / len)
	end


	function Vector4.Dot2(v1,v2)
		return (v1._x*v2._x + v1._y*v2._y)
	end

	function Vector4.Dot3(v1,v2)
		return (v1._x*v2._x + v1._y*v2._y + v1._z*v2._z)
	end

	function Vector4.Dot4(v1,v2)
		return (v1._x*v2._x + v1._y*v2._y + v1._z*v2._z + v1._w*v2._w)
	end
	

	function Vector4.Transform(dest,matrix,source)
		Vector4._Transform(dest,matrix,source)
	end

	function Vector4.TransformVector(dest,matrix,source)
		Vector4._Transform(dest,matrix,source,0)
	end

	function Vector4.TransformPoint(dest,matrix,source)
		Vector4._Transform(dest,matrix,source,1)
	end

	local tmpV = Vector4.Create()
	
	function Vector4._Transform(dest,matrix,source,defaultW)
		assert(matrix and matrix.className == Matrix44.className,'Vector4.TransformPoint - invalid matrix')	
		
		if (source and source.className and source.className == Vector4.className) then
			assert(dest and source,'Vector4.TransformPoint - invalid source/dest')
			tmpV:Copy(source)
			if (defaultW) then
				tmpV:SetW(defaultW)
			end

			Matrix44._MultiplyVector(matrix,tmpV,dest)
			
		else
			assert(dest and source and type(dest) == 'table' and type(source)=='table' and (#dest >= #source),'Vector4.TransformPoint - source/dest Invalid Tables')
			
			for idx,sourceV in pairs(source) do
				local destV = dest[idx]
				tmpV:Copy(sourceV)
				if (defaultW) then
					tmpV:SetW(defaultW)
				end
				Matrix44._MultiplyVector(matrix,tmpV,destV)
			end
		end
		
	end
	
	-- Gen Equation of 3D Line going through points P0 and P1
	-- P0 + u(P1 - P0) (u is some constant)
	-- Likewise for second line intersecting points Q0 and Q1
	-- Q0 + z(Q1 - Q0) z is some constant
	-- @ common intersect  P0+u(P1-P0) = Q0 + z(Q1-Q0)
	-- u(P1-P0) - z(Q1-Q0) = Q0 - P0
	-- In matrix form
	-- Solve (u,v,1,1) =
	-- |px  -qx 0  0|^-1		| qpx |		
  	-- |py  -qy 0  0|		* 	| qpy |	
    -- |pz  -qz 1 -1|			| qpz |		
    -- |0    0  0  1|			| 1   |	
	-- px,py,pz = Vector(P1-P0)
	-- qx,qy,qz = Vector(Q1-Q0)
	-- qpx,qpy,qpz = Vector(Q0-P0)

	-- Ok, Ok!.. above eqn I formulated is slightly bollocked - seems to work in 2D only
	
	function Vector4.Calculate2dLineIntersection( intersectionPoint,  p0,  p1,  q0,  q1,  infiniteLine )
		assert(intersectionPoint and intersectionPoint.className == Vector4.className,'Vector4.Calculate2dLineIntersection: Invalid Parameter intersectionPoint')

		assert(p0 and p0.className == Vector4.className,'Vector4.Calculate2dLineIntersection: Invalid Parameter p0')
		assert(p1 and p1.className == Vector4.className,'Vector4.Calculate2dLineIntersection: Invalid Parameter p1')
		assert(q0 and q0.className == Vector4.className,'Vector4.Calculate2dLineIntersection: Invalid Parameter q0')
		assert(q1 and q1.className == Vector4.className,'Vector4.Calculate2dLineIntersection: Invalid Parameter q1')
		
		local dirP = Vector4.Create(p1)
		dirP:Subtract(dirP,p0)
		local lenP = dirP:Length3()
		local ndirP = Vector4.Create(dirP)
		ndirP:Normalise3()
	
		local dirQ = Vector4.Create(q1)
		dirQ:Subtract(dirQ,q0)
		local ndirQ = Vector4.Create(dirQ)
		ndirQ:Normalise3()

		dirQ:Multiply(dirQ,-1)
		local lenQ = dirQ:Length3()
		

		-- TODO Quick Check for Parallel lines - Cheaper than Det()

		local pDp = Vector4.Dot3(ndirQ,ndirP)

			
		local PQ	=	Vector4.Create(q0)
		PQ:Subtract(PQ,p0)
		
		local matrix = Matrix44.Create(dirP,dirQ,Vector4.Create(0,0,1,0),Vector4.Create(0,0,-1,1))

		matrix:Transpose(matrix)

		local det = matrix:_Det()

		if (det == 0) then
			-- No Inverse matrix - no solution - ie. Par lines
			return false,-1,-1,-1,-1
		end
		
		matrix:Invert(matrix)


		local u = Vector4.Dot3(matrix:GetRow(1),PQ)
		local v = Vector4.Dot3(matrix:GetRow(2),PQ)
		local z = Vector4.Dot3(matrix:GetRow(3),PQ)
		local w = Vector4.Dot3(matrix:GetRow(3),PQ)
		
		if (z ~= 0) or (w ~= 0) then return false,u,v,z,w end
		

		
		intersectionPoint:Copy(dirP)
		intersectionPoint:Normalise3()
		intersectionPoint:Multiply(intersectionPoint,u*lenP)
		intersectionPoint:Add(intersectionPoint,p0)
		
		if (not infiniteLine) then
			return (u >=0 and u <=1 and v >= 0 and v <= 1),u,v,z,w
		else
			return true,u,v,z,w
		end
		
	end
	
    function Vector4.toString(vector4)
        return string.format("Vector4: %f,%f,%f,%f",vector4._x,vector4._y,vector4._z,vector4._w)
    end

    function Vector4._toString(vector4)
		return Vector4.toString(vector4)
    end


	function Vector4.Test()
	
		local res = Vector4.Create()
		-- Y = 2X + 5
		local p0 = Vector4.Create(0,5,-200)
		local p1 = Vector4.Create(20,45,-200)

		-- Y = -4X + 20
		local q0 = Vector4.Create(0,20,-200)
		local q1 = Vector4.Create(20,-60,-200)

--		local q0 = Vector4.Create(100,-380,-100)
--		local q1 = Vector4.Create(150,-580,-100)

		-- Y = 2X + 20
--		local q0 = Vector4.Create(0,20,0)
--		local q1 = Vector4.Create(20,60,0)

		-- Intercept @ X = 15/6, Y = 2* 15/6 + 30/6 = 10
		
		local intersectionPoint = Vector4.Create()
		local isintersect,u,v,z,w = Vector4.Calculate2dLineIntersection( intersectionPoint,  p0,  p1,  q0,  q1,  true )
		
		if (not isintersect) then
			assert(false,string.format(" NO INTERSECTION U %f V %f Z %f W %f",u,v,z,w))	
		else
			assert(false,Vector4._toString(intersectionPoint)..string.format(" U %f V %f Z %f W %f",u,v,z,w))	
		end
		
	end
	
	function Vector4.Test2()
		local matrix = Matrix44.Create()
		local source = Vector4.Create(1,0,0)
		local dest = Vector4.Create()
		matrix:SetRotationXyz(0,0,45)
		Vector4.TransformVector(dest,matrix,source)

		local sourceVs = {}
		local destVs = {}
		local radius = 100*math.random() + 1
		for i=1,100 do
			table.insert(destVs,Vector4.Create())
			table.insert(sourceVs,Vector4.Create(radius,radius,math.random(22)))
		end
		Vector4.TransformVector(destVs,matrix,sourceVs)
	end
	
--_Vector4Test = true

	if (_Vector4Test) then
		
		if (not Matrix44) then
			LoadLibrary("Matrix44")
		end

		Vector4.Test()
		--Vector4.Test2()
	end
	
	
end
