-- @copyright Affinity Studios Ltd 2007-2011 John Wilson
if (not Matrix44) then

Matrix44 = {}
Matrix44.className	=	'Matrix44'
MATRIX_REPLACE		=	'MATRIX_REPLACE'
MATRIX_POSTMULTIPLY	=	'MATRIX_POSTMULTIPLY'
MATRIX_PREMULTIPLY	=	'MATRIX_PREMULTIPLY'

local defaultRow1	=	Vector4.Create(1,0,0,0)
local defaultRow2	=	Vector4.Create(0,1,0,0)
local defaultRow3	=	Vector4.Create(0,0,1,0)
local defaultRow4	=	Vector4.Create(0,0,0,1)

local 	function NOT_YET_IMPLEMENTED(fName)
			assert(false,string.format("Matrix44 - FUNCTION Matrix44.%s NOT YET IMPLEMENTED",(fName or '')))
	  	end

    function Matrix44.Create(...)
        local args = {...}
        local t = args[1]
		if (#args == 4) then
		 	return Matrix44.CreateVectors(args[1],args[2],args[3],args[4])
		else
			return  Matrix44.CreateDefault()
		end
    end
	
	function Matrix44.CreateDefault(scalex,scaley,scalez)
		local matrix = {
					
					m = {
							{1,0,0,0},
							{0,1,0,0},
							{0,0,1,0},
							{0,0,0,1},
							
						},
					scalex	=	scalex or 1,
					scaley	=	scaley or 1,
					scalez	=	scalez or 1,
					className	=	Matrix44.className,
				}
		setmetatable(matrix, { __index = Matrix44 })
		return matrix
	end
	
	
	function Matrix44.CreateVectors(vx,vy,vz,vw)
	
		local matrix = Matrix44.CreateDefault()
		Matrix44.SetRow(matrix,1,vx or defaultRow1)
		Matrix44.SetRow(matrix,2,vy or defaultRow2)
		Matrix44.SetRow(matrix,3,vz or defaultRow3)
		Matrix44.SetRow(matrix,4,vw or defaultRow4)
		return matrix
	end

	local function _FormColumnVector(rawmatrix,col,vect)
		
		local lvect = vect or Vector4.Create()
	
		lvect:SetXyzw(rawmatrix[1][col],
					  rawmatrix[2][col],
					  rawmatrix[3][col],
					  rawmatrix[4][col])
							
		return lvect
	end


	local function _FormRowVector(rawmatrix,row,vect)
		
		local lvect = vect or Vector4.Create()
	
		lvect:SetXyzw(rawmatrix[row][1],
					  rawmatrix[row][2],
					  rawmatrix[row][3],
					  rawmatrix[row][4])
		return lvect
	end
	
	local function _SetRowWithVector(rawmatrix,row,v)
		local rawrow = rawmatrix[row]
		rawrow[1]	=	Vector4.X(v)
		rawrow[2]	=	Vector4.Y(v)
		rawrow[3]	=	Vector4.Z(v)
		rawrow[4]	=	Vector4.W(v)
	end

	local function _SetColWithVector(rawmatrix,col,v)
		local cVector =	{Vector4.X(v),Vector4.Y(v),Vector4.Z(v),Vector4.W(v)}
		for row = 1,4 do
			rawmatrix[row][col] = cVector[row]
		end
	end
	
	
	function Matrix44._Debug(matrix,logger)
				local dprint = logger or print
				dprint("Matrix Debug ")
				local rawmatrix = matrix.m
				local scale		= matrix.scale
				dprint(string.format("SCALE %f",scale))
				for row = 1,4 do
					local rm = rawmatrix[row]
					dprint(string.format("ROW %d %f %f %f %f\n",row,rm[1],rm[2],rm[3],rm[4]))
				end
		  end
	
	function Matrix44.Copy(dstmatrix,srcmatrix)
		
		for row = 1,4 do
			local v = Matrix44.GetRow(srcmatrix,row)
			Matrix44.SetRow(dstmatrix,row,v)
		end
		
		dstmatrix.scalex	=	srcmatrix.scalex
		dstmatrix.scaley	=	srcmatrix.scaley
		dstmatrix.scalez	=	srcmatrix.scalez
		
	end
	
	function Matrix44.GetRotationXyz(matrix,outvector)
		NOT_YET_IMPLEMENTED('GetRotationXyz')
	end
	
	function Matrix44.GetRow(matrix,rownumber,outvector)
		local loutvector = outvector or Vector4.Create()
		local row 	= matrix.m[rownumber]
		loutvector:SetXyzw(row[1],row[2],row[3],row[4])
		return loutvector
	end
	
	
	function Matrix44._Det(matrix)
		local m = matrix.m

		local A1 = m[1]
		local A2 = m[2]
		local A3 = m[3]
		local A4 = m[4]

		local det = A1[1]*A2[2]*A3[3]*A4[4] + A1[1]*A2[3]*A3[4]*A4[2] + A1[1]*A2[4]*A3[2]*A4[3]  
			+ A1[2]*A2[1]*A3[4]*A4[3] + A1[2]*A2[3]*A3[1]*A4[4] + A1[2]*A2[4]*A3[3]*A4[1] 
			+ A1[3]*A2[1]*A3[2]*A4[4] + A1[3]*A2[2]*A3[4]*A4[1] + A1[3]*A2[4]*A3[1]*A4[2]
			+ A1[4]*A2[1]*A3[3]*A4[2] + A1[4]*A2[2]*A3[1]*A4[3] + A1[4]*A2[3]*A3[2]*A4[1]
			- A1[1]*A2[2]*A3[4]*A4[3] - A1[1]*A2[3]*A3[2]*A4[4] - A1[1]*A2[4]*A3[3]*A4[2]
			- A1[2]*A2[1]*A3[3]*A4[4] - A1[2]*A2[3]*A3[4]*A4[1] - A1[2]*A2[4]*A3[1]*A4[3]
			- A1[3]*A2[1]*A3[4]*A4[2] - A1[3]*A2[2]*A3[1]*A4[4] - A1[3]*A2[4]*A3[2]*A4[1]
			- A1[4]*A2[1]*A3[2]*A4[3] - A1[4]*A2[2]*A3[3]*A4[1] - A1[4]*A2[3]*A3[1]*A4[2]
		return det
		
	end
	
	
	
	function Matrix44.Invert(dstmatrix,srcmatrix)

		local det = srcmatrix:_Det()
		if (det ~= 0) then
			local m = srcmatrix.m
			local A1 = m[1]
			local A2 = m[2]
			local A3 = m[3]
			local A4 = m[4]
			
			local a11,a12,a13,a14 	= A1[1],A1[2],A1[3],A1[4]
			local a21,a22,a23,a24 	= A2[1],A2[2],A2[3],A2[4]
			local a31,a32,a33,a34 	= A3[1],A3[2],A3[3],A3[4]
			local a41,a42,a43,a44 	= A4[1],A4[2],A4[3],A4[4]
			
			-- a few repeated calculations here!
			
			local b11 = (a22*a33*a44 + a23*a34*a42 + a24*a32*a43 - a22*a34*a43 - a23*a32*a44 - a24*a33*a42)/det
			local b12 = (a12*a34*a43 + a13*a32*a44 + a14*a33*a42 - a12*a33*a44 - a13*a34*a42 - a14*a32*a43)/det
			local b13 = (a12*a23*a44 + a13*a24*a42 + a14*a22*a43 - a12*a24*a43 - a13*a22*a44 - a14*a23*a42)/det
			local b14 = (a12*a24*a33 + a13*a22*a34 + a14*a23*a32 - a12*a23*a34 - a13*a24*a32 - a14*a22*a33)/det

			local b21 = (a21*a34*a43 + a23*a31*a44 + a24*a33*a41 - a21*a33*a44 - a23*a34*a41 - a24*a31*a43)/det
			local b22 = (a11*a33*a44 + a13*a34*a41 + a14*a31*a43 - a11*a34*a43 - a13*a31*a44 - a14*a33*a41)/det
			local b23 = (a11*a24*a43 + a13*a21*a44 + a14*a23*a41 - a11*a23*a44 - a13*a24*a41 - a14*a21*a43)/det
			local b24 = (a11*a23*a34 + a13*a24*a31 + a14*a21*a33 - a11*a24*a33 - a13*a21*a34 - a14*a23*a31)/det

			local b31 = (a21*a32*a44 + a22*a34*a41 + a24*a31*a42 - a21*a34*a42 - a22*a31*a44 - a24*a32*a41)/det
			local b32 = (a11*a34*a42 + a12*a31*a44 + a14*a32*a41 - a11*a32*a44 - a12*a34*a41 - a14*a31*a42)/det
			local b33 = (a11*a22*a44 + a12*a24*a41 + a14*a21*a42 - a11*a24*a42 - a12*a21*a44 - a14*a22*a41)/det
			local b34 = (a11*a24*a32 + a12*a21*a34 + a14*a22*a31 - a11*a22*a34 - a12*a24*a31 - a14*a21*a32)/det

			local b41 =  (a21*a33*a42 + a22*a31*a43 + a23*a32*a41 - a21*a32*a43 - a22*a33*a41 - a23*a31*a42)/det
			local b42 =  (a11*a32*a43 + a12*a33*a41 + a13*a31*a42 - a11*a33*a42 - a12*a31*a43 - a13*a32*a41)/det
			local b43 =  (a11*a23*a42 + a12*a21*a43 + a13*a22*a41 - a11*a22*a43 - a12*a23*a41 - a13*a21*a42)/det
			local b44 =  (a11*a22*a33 + a12*a23*a31 + a13*a21*a32 - a11*a23*a32 - a12*a21*a33 - a13*a22*a31)/det
		
			dstmatrix:SetRow(1,Vector4.Create(b11,b12,b13,b14))
			dstmatrix:SetRow(2,Vector4.Create(b21,b22,b23,b24))
			dstmatrix:SetRow(3,Vector4.Create(b31,b32,b33,b34))
			dstmatrix:SetRow(4, Vector4.Create(b41,b42,b43,b44))
			

		end
	end
	
	
	function Matrix44._IsEqual(v1,v2,tol)
		return (math.abs(v1 - v2) <= tol)
	end
	
	function Matrix44.IsEqual(matrix1,matrix2,tolp)
		
		local tol	=	 tolp or 0
		local A =	srcmatrix1.m
		local B = 	srcmatrix2.m
		
		for row = 1, 4 do
			for col = 1,4 do
				local eq  = Matrix44._IsEqual(A[row][col],B[row][col],tol)
				if (not eq) then
					return false
				end
			end
		end
		return true
	end

	
	function Matrix44.IsIdentity(matrix,tolp)
		local tol	=	 tolp or 0
		local A 	= 	matrix.m
		
		for row =1,4 do
			for col = 1,4 do
				local checkvalue = (row == col) and 1 or 0
				if (not Matrix._IsEqual(A[row][col],checkvalue,tol)) then
					return false
				end
			end
		end
		return true
	end
	
	function Matrix44.Multiply(dstmatrix,srcmatrix1,srcmatrix2)
		
		local A =	srcmatrix1.m
		local B = 	srcmatrix2.m
		
		local A1 = A[1]
		local A2 = A[2]
		local A3 = A[3]
		local A4 = A[4]
		
		local B1 = B[1]
		local B2 = B[2]
		local B3 = B[3]
		local B4 = B[4]
		
		local	A11	=	A1[1]
		local	A12	=	A1[2]
		local	A13	=	A1[3]
		local	A14	=	A1[4]

		local	A21	=	A2[1]
		local	A22	=	A2[2]
		local	A23	=	A2[3]
		local	A24	=	A2[4]
		
		local	A31	=	A3[1]
		local	A32	=	A3[2]
		local	A33	=	A3[3]
		local	A34	=	A3[4]

		local	A41	=	A4[1]
		local	A42	=	A4[2]
		local	A43	=	A4[3]
		local	A44	=	A4[4]


		local	B11	=	B1[1]
		local	B12	=	B1[2]
		local	B13	=	B1[3]
		local	B14	=	B1[4]

		local	B21	=	B2[1]
		local	B22	=	B2[2]
		local	B23	=	B2[3]
		local	B24	=	B2[4]
		
		local	B31	=	B3[1]
		local	B32	=	B3[2]
		local	B33	=	B3[3]
		local	B34	=	B3[4]

		local	B41	=	B4[1]
		local	B42	=	B4[2]
		local	B43	=	B4[3]
		local	B44	=	B4[4]

		
		local dstm 	= dstmatrix.m
		
		dstm[1][1] = A11*B11 + A12*B21 + A13*B31 + A14*B41
		dstm[1][2] = A11*B12 + A12*B22 + A13*B32 + A14*B42
		dstm[1][3] = A11*B13 + A12*B23 + A13*B33 + A14*B43
		dstm[1][4] = A11*B14 + A12*B24 + A13*B34 + A14*B44
		

		dstm[2][1] = A21*B11 + A22*B21 + A23*B31 + A24*B41
		dstm[2][2] = A21*B12 + A22*B22 + A23*B32 + A24*B42
		dstm[2][3] = A21*B13 + A22*B23 + A23*B33 + A24*B43
		dstm[2][4] = A21*B14 + A22*B24 + A23*B34 + A24*B44

		dstm[3][1] = A31*B11 + A32*B21 + A33*B31 + A34*B41
		dstm[3][2] = A31*B12 + A32*B22 + A33*B32 + A34*B42
		dstm[3][3] = A31*B13 + A32*B23 + A33*B33 + A34*B43
		dstm[3][4] = A31*B14 + A32*B24 + A33*B34 + A34*B44


		dstm[4][1] = A41*B11 + A42*B21 + A43*B31 + A44*B41
		dstm[4][2] = A41*B12 + A42*B22 + A43*B32 + A44*B42
		dstm[4][3] = A41*B13 + A42*B23 + A43*B33 + A44*B43
		dstm[4][4] = A41*B14 + A42*B24 + A43*B34 + A44*B44
		
	end
	
	function Matrix44.SetAxisRotation(matrix)
		NOT_YET_IMPLEMENTED('SetAxisRotation')
	end
	
	function Matrix44.SetIdentity(matrix)
		matrix:SetRow(1,1,0,0,0)
		matrix:SetRow(2,0,1,0,0)
		matrix:SetRow(3,0,0,1,0)
		matrix:SetRow(4,0,0,0,1)
	end
	
	
	function Matrix44.SetRotationXyz(matrix,rxang,ryang,rzang,rtype)
		local mtype = rtype or MATRIX_REPLACE
		local rotMatrix	=	Matrix44.Create()

		local rmx	=	Matrix44._BuildRotation(1,0,0,rxang)
		local rmy	=	Matrix44._BuildRotation(0,1,0,ryang)
		local rmz	=	Matrix44._BuildRotation(0,0,1,rzang)

		Matrix44.Multiply(rotMatrix,rotMatrix,rmx)
		Matrix44.Multiply(rotMatrix,rotMatrix,rmy)
		Matrix44.Multiply(rotMatrix,rotMatrix,rmz)
		
		if (mtype == MATRIX_REPLACE) then
			Matrix44.Copy(matrix,rotMatrix)
		elseif (mtype == MATRIX_PREMULTIPLY) then
			Matrix44.Multiply(matrix,rotMatrix,matrix)
		elseif (mtype == MATRIX_POSTMULTIPLY) then
			Matrix44.Multiply(matrix,matrix,rotMatrix)
		end
		
	end


	function Matrix44.SetRow(matrix,row,...)
		local args = {...}
		local t = args[1]
		if (type(t) == 'number') then
			Matrix44._SetRow(matrix,row,...)
		else
			Matrix44._SetRowVector(matrix,row,...)
		end
	end
	
	function Matrix44._SetRowVector(matrix,row,vect)
		local xv,yv,zv,wv = Vector4.X(vect),Vector4.Y(vect),Vector4.Z(vect),Vector4.W(vect)
		Matrix44._SetRow(matrix,row,xv,yv,zv,wv)
	end

	function Matrix44._SetRow(matrix,row,xv,yv,zv,wv)
		local rrow 	= 	matrix.m[row]
		rrow[1]		=	xv 
		rrow[2]		=	yv
		rrow[3]		=	zv
		rrow[4]		=	wv
	end
	
	function Matrix44.SetScale(matrix,scalex,scaley,scalez)
		matrix.scalex	=	scalex
		matrix.scaley	=	scaley
		matrix.scalez	=	scalez
		
	end



	-- SetTranslation(matrix,vector,multtype)
	-- or SetTranslation(matrix,x,y,z,multtype)
	
	function Matrix44.SetTranslation(...)
		local args = {...}
		if (#args > 3) then
			Matrix44._SetTranslationXYZ(...)
		else
			local mt	   = args[1]
			local vt	   = args[2]
			local ptype	   = args[3]
			local tx,ty,tz = Vector4.X(vt),Vector4.Y(vt),Vector4.Z(vt)
			Matrix44._SetTranslationXYZ(mt,tx,ty,tz,ptype)
		end
	end
	
	function Matrix44._SetTranslationXYZ(matrix,tx,ty,tz,ptype)

		local ttype = ptype or MATRIX_REPLACE
		local tVector = Vector4.Create(tx,ty,tz,1)
		local tmatrix = Matrix44.Create()

		Matrix44.SetRow(tmatrix,4,tVector)

		if (ttype == MATRIX_REPLACE) then
			-- Rotation Order is RX RY RZ
			Matrix44.SetRow(matrix,4,tVector)
		elseif (ttype == MATRIX_PREMULTIPLY) then
			Matrix44.Multiply(matrix,tmatrix,matrix)
		elseif (ttype == MATRIX_POSTMULTIPLY) then
			Matrix44.Multiply(matrix,matrix,tmatrix)
		end
		
	end
	
	
	function Matrix44.Transpose(dstmatrix,srcmatrix)
		local A 		=	(scrmatrix and scrmatrix.m) or dstmatrix.m
		
		local A1 		= 	A[1]
		local A2 		= 	A[2]
		local A3 		= 	A[3]
		local A4 		= 	A[4]
		
		local	A11		=	A1[1]
		local	A12		=	A1[2]
		local	A13		=	A1[3]
		local	A14		=	A1[4]

		local	A21		=	A2[1]
		local	A22		=	A2[2]
		local	A23		=	A2[3]
		local	A24		=	A2[4]
		
		local	A31		=	A3[1]
		local	A32		=	A3[2]
		local	A33		=	A3[3]
		local	A34		=	A3[4]

		local	A41		=	A4[1]
		local	A42		=	A4[2]
		local	A43		=	A4[3]
		local	A44		=	A4[4]

		local dstm 	= dstmatrix.m
		
		dstm[1][1] =	A11 
		dstm[2][1] = 	A12
		dstm[3][1] = 	A13
		dstm[4][1] = 	A14
		
		dstm[1][2] =	A21 
		dstm[2][2] = 	A22
		dstm[3][2] = 	A23
		dstm[4][2] = 	A24
		
		dstm[1][3] =	A31 
		dstm[2][3] = 	A32
		dstm[3][3] = 	A33
		dstm[4][3] = 	A34
		
		dstm[1][4] =	A41 
		dstm[2][4] = 	A42
		dstm[3][4] = 	A43
		dstm[4][4] = 	A44


	end
	
	-- This is not part of Sony's API

	function Matrix44._MultiplyVector(matrix,v,dstv)
	
		local ldstv	=	dstv or Vector4.Create()
		assert(v and v.className == Vector4.className and ldstv and ldstv.className == Vector4.className," Matrix44._MultiplyVector:Some wrong with params")
		local rm = matrix.m
		local m1 = rm[1]
		local m2 = rm[2]
		local m3 = rm[3]
		local m4 = rm[4]
		
		local x	=	Vector4.X(v)
		local y =   Vector4.Y(v)
		local z = 	Vector4.Z(v)
		local w = 	Vector4.W(v)
		
		ldstv:SetXyzw(
			m1[1]*x + m1[2]*y + m1[3]*z + m1[4]*w,
			m2[1]*x + m2[2]*y + m2[3]*z + m2[4]*w,
			m3[1]*x + m3[2]*y + m3[3]*z + m3[4]*w,
			m4[1]*x + m4[2]*y + m4[3]*z + m4[4]*w)
		return ldstv	
	end
	
	
	function Matrix44._BuildRotation(x,y,z,angle)
	
		local c	   = math.cos(math.rad(angle))
		local s    = math.sin(-math.rad(angle))
		local t	   = 1 - c
		
		local row1 = Vector4.Create(
						t*x*x + c,
						t*x*y - s*z,
						t*x*z + s*y,
						0)

		local row2 = Vector4.Create(
						t*x*y + s*z,
						t*y*y + c,
						t*y*z - s*x,
						0)
						
		local row3 = Vector4.Create(
						t*x*z - s*y,
						t*y*z + s*x,
						t*z*z + c,
						0)
						
		local row4 = Vector4.Create(0,0,0,1)
		
		local matrix = Matrix44.Create()
		
		matrix:SetRow(1,row1)
		matrix:SetRow(2,row2)
		matrix:SetRow(3,row3)
		matrix:SetRow(4,row4)

		return matrix
	end
	
	function Matrix44._Test()
		TestMatrix()
	end
	
	function Matrix44._Test2()
		local dbm = Matrix44.Create()
		local tmp = Vector4.Create()
		for row = 1,4  do
			for col = 1,4 do
				dbm.m[row][col] = row*10+col
			end
		end
		
		for row = 1, 4 do
			dbm:GetRow(row,tmp)
			Logger.lprint(string.format("OK ROW %d %f %f %f %f\n",row,tmp:X(),tmp:Y(),tmp:Z(),tmp:W()))
		end
		
		
		dbm:_Debug(Logger.lprint)

		Logger.lprint("Test - _FormColVector")
		
		for col = 1,4 do
		 	_FormColumnVector(dbm.m,col,tmp)
			Logger.lprint(string.format("COL %d %f %f %f %f\n",col,tmp:X(),tmp:Y(),tmp:Z(),tmp:W()))
		end
		
	end
	

	function DebugMatrix(matrix,msg)
		Logger.lprint(msg or "")
		Logger.lprint("\n")
		Logger.lprint(matrix:toString())
	end

	function Matrix44._toString(matrix)
		return Matrix44.toString(matrix)
	end
	
	function Matrix44.toString(matrix)
	
		local str = {}
		local tmp	=	Vector4.Create()
		table.insert(str,"Matrix\n")
		for row = 1, 4 do
			matrix:GetRow(row,tmp)
			table.insert(str,string.format("ROW %d %f %f %f %f\n",row,tmp:X(),tmp:Y(),tmp:Z(),tmp:W()))
		end
		return table.concat(str)
	end
	
	
	function TestMatrix2()

		local matrix = Matrix44.Create()
		DebugMatrix(matrix,'identity')
		Matrix44.SetRotationXyz(matrix,45,90,60,MATRIX_REPLACE)
		DebugMatrix(matrix,'rot=0,0,60')

		matrix = Matrix44.Create(Vector4.Create(8,-9,-2,-5),
								Vector4.Create(9,6,-6,9),
								Vector4.Create(-3,-9,4,-2),
								Vector4.Create(0,-7,8,8))

		DebugMatrix(matrix,'CREATE VECTORS')
		--Matrix44.SetTranslation(matrix,100,200,300,MATRIX_PREMULTIPLY)
		--DebugMatrix(matrix,'TRANSLATION')
		Logger.lprint(string.format("DET = %f",Matrix44._Det(matrix)))
		-- local imatrix = Matrix44.Create()
		 Matrix44.Invert(matrix,matrix)
		DebugMatrix(matrix,'INVERTED')
		 Matrix44.Invert(matrix,matrix)
		DebugMatrix(matrix,'INVERTED -2 ')
		
	end
	

	function TestMatrix()
		local matrix = Matrix44.Create()
		DebugMatrix(matrix,'identity')
		Matrix44.SetRotationXyz(matrix,0,0,-45,MATRIX_REPLACE)
		DebugMatrix(matrix,'rot=0,0,60')
		Matrix44.SetTranslation(matrix,100,100,0,MATRIX_PREMULTIPLY)
		DebugMatrix(matrix,'TRANSLATE')
	end
	

	
	
	
	
end
