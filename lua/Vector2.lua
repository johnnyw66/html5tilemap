-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not Vector2 then

Vector2								=	{ }
Vector2.className					=	"Vector2" 

	function Vector2.Create(...)
		local args = {...}
		if (args[1] and type(args[1]) == 'number') then
			return Vector2.CreateNumber(...)
		else
			return Vector2.CreateVector(...)
		end
	end
	
	function Vector2.CreateNumber(x,y)
		--Logger.lprint("Vector2 - Create Number ")
		local vector2 = {
				x				=	x or 0,
				y				=	y or 0,
				className		=	Vector2.className,

		}
		setmetatable(vector2, {__index = Vector2 })
		return vector2 
	end


	function Vector2.CreateVector(v)
		--Logger.lprint("Vector2 - Create Vector ")
		local vector2 = {
				x				=	v:X(),
				y				=	v:Y(),
				className		=	Vector2.className,

		}
		setmetatable(vector2, {__index = Vector2 })
		return vector2 
	end

	function Vector2.X(vector2)
		return vector2.x
	end

	function Vector2.Y(vector2)
		return vector2.y
	end

	function Vector2.CreateVector4(vector2)
		--Logger.lprint("Create Vector4")
		assert(vector2,'Vector Passed is nil')
		assert(vector2.x and type(vector2.x) == 'number','Vector Passed has no valid X para')
		assert(vector2.y and type(vector2.y) == 'number','Vector Passed has no valid X para')
		return Vector4.Create(vector2.x,vector2.y,0,0)
	end
	
	function Vector2.Render(vector2,renderHelper)
		Vector2.RenderDebug(vector2,renderHelper)
	end

	function Vector2.RenderDebug(vector2,renderHelper)
		
	end

	function Vector2.toString(vector2)
		local str =	{}
		return table.concat(str)
	end
	

end
