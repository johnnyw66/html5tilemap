-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not Shape then

_MessageGenerator	=	{}
_MessageGenerator.className	=	'_MessageGenerator'

local function _ModifyLocaleText(text)
	
	local modtext =	text
	
	string.gsub(text,"_LOCALE%W*[(]([^)]+)[)]",
		function(txt) 
			modtext = Locale and Locale.GetLocaleText and Locale.GetLocaleText(txt) or txt 
		end)
		
	return modtext
end


	function _MessageGenerator._Create(shape)
		local msgG	=	{
			shape		=	shape,
			pos			=	shape:GetVectorPosition(),
			text		=	_ModifyLocaleText(shape.text or 'NIL'),	
			debounce	=	shape.debounce	or 10,
			count		=	shape.count  or -1,
			alive		=	true,
			lasttime	=	nil,
			className	=	_MessageGenerator.className,
		}
		setmetatable(msgG,{ __index = _MessageGenerator })
		--	_MessageGenerator._Init(msgG)
		return msgG
	end

	function _MessageGenerator.GetVectorPosition(msgG)
		return msgG.pos
	end

	function _MessageGenerator.IsAlive(msgG)
		return msgG.alive
	end
	
	function _MessageGenerator.AllowTrigger(msgG)
		return (not msgG.lasttime) or (msgG.shape.time-msgG.lasttime > msgG.debounce) 
	end
	
	function _MessageGenerator.ObjectInside(msgG,object,shape)

		if _MessageGenerator.AllowTrigger(msgG) then
			msgG.count	=	msgG.count - 1
			msgG.alive	=	(msgG.count ~= 0)
			MessageManager.Add(Message.Create(DisplayableTextWithImage.Create(msgG.text),
			SpringBox.Create(1024/2,720/2,-100,nil,nil,nil,3)),true)
			msgG.lasttime	=	msgG.shape.time
		end
		
		
	end

	function _MessageGenerator.ObjectOutside(msgG,object,shape)

	end

	function _MessageGenerator.GetCount(msgG)
		return msgG.count
	end

Shape 			=	{}
Shape.className	=	"Shape"
local tmpV		=	Vector4.Create()
Shape.debug		=	false
Shape.ID		=	1

	function Shape._CreatePos(posx,posy)

		local shape = {
			pos			=	Vector4.Create(posx,posy),
			radius		=	40,	
			className	=	Shape.className,
		}

		setmetatable(shape,{ __index = Shape })
		Shape._Init(shape)
		return shape
	end

	function Shape._CreateRaw(rawData)

		local shape = {
			data		=	rawData,
			pos			=	Vector4.Create(100,0),	
			radius		=	42,
			className	=	Shape.className,
		}

		setmetatable(shape,{ __index = Shape })
		Shape._Init(shape)
		return shape
	end


	function Shape.Create(...)
		local args = {...}
    	local t = args[1]
    	if (not t or type(t) == 'number') then
			return Shape._CreatePos(...)
		else
			return Shape._CreateRaw(...)
		end
		
	end

	local function getValue(v)

		return (type(v) == 'string' or type(v) == 'number') and v or (type(v) == 'boolean' and ((v) and 'true' or 'false')  or 'table')

	end
	
	function Shape._Init(shape)
		local data	=	shape.data
		shape.id	=	Shape.ID
		Shape.ID	=	Shape.ID	+  1
		
		if (data) then
			local properties		=	data.properties
			shape.type				=	data.type
			shape.properties		=	data.properties
			shape.radius			=	(data.type == 'circle') and data.radius	or 0
			shape.angle				=	data.angle
			shape.width				=	(data.type == 'box' or data.type == 'text') and data.width or shape.radius
			shape.height			=	(data.type == 'box'or data.type == 'text') and data.height or shape.radius
			shape.pos				=	(data.type == 'circle') and  Vector4.Create(data.x+shape.radius,data.y+shape.radius)
																	or Vector4.Create(data.x-shape.width*0.5,data.y-shape.height*0.5) 
			shape.text				=	data.text
			
			shape.killwhenin		=	properties and properties.killwhenin or false	
			
			if (shape.text) then
				shape.count				=	properties and properties.count
				shape.debounce			=	properties and properties.debounce
				shape.attachedlist	=	{}
				table.insert(shape.attachedlist,_MessageGenerator._Create(shape))
			end
			
			-- Only accept attachments to Sprites at this moment. 
			-- If we want Shape to Shape links then we will need
			-- to implement a two pass process in our MapReader
				
			if (data.link and data.link.primitiveType == 'sprite') then
				shape.attached	=	data.link.realobject
				data.link.realobject.attached = shape
			end
			
		end				-- if (data)
		
		shape.bradius		=	shape.radius
		shape.bwidth		=	shape.width
		shape.bheight		=	shape.height
		shape.time			=	0
		shape.alive			=	true
		shape.wasinside		=	{}
		
	end
	
	function	Shape.IsAlive(shape)
		return shape.alive
	end

	function	Shape.IsKilled(shape)
		return not shape.alive
	end
	

	function Shape.ResolveLinks(shape)
		local data	=	shape.data
		shape.attachedlist	=	shape.attachedlist or {}
		
		if (data.links) then
			for i,lnk in pairs(data.links) do
				local primType	=	lnk.primitiveType
				if (lnk.realobject) then
					table.insert(shape.attachedlist,lnk.realobject)
				end
			end
		end
	end
	

	function Shape.Debug(shape)

	end



	function Shape.GetPosition(shape)
		local v = shape.pos
		return v:X(),v:Y(),v:Z()
	end

	function Shape.GetVectorPosition(shape)
		return shape.pos
	end


	function Shape.Update(shape,dt)
		shape.time	=	shape.time + dt
		
		if (shape.type == 'circle' and shape.attached) then
			local freq =	1
			shape.radius	=	shape.bradius + shape.bradius*0.05*math.sin(shape.time*freq*6.284)
			
		end
		local freq		=	1
		shape.width		=	shape.bwidth + shape.bwidth*0.05*math.sin(shape.time*freq*6.284)
		shape.height	=	shape.bheight + shape.bheight*0.05*math.sin(shape.time*freq*6.284)
		
	end

	function Shape.UpdateOld(shape,dt,entity)

		local informList	=	{}
		
		-- 1st Build up a unique list of those entities that
		-- need to be informed of any movement
		
		for i,attached in pairs(shape.attachedlist) do
			table.insert(informList,attached.GetTarget and attached:GetTarget())
		end
		
		for k,target in pairs(informList) do
			Shape.EntityCheck(shape,target)
		end
		
	end
	

	function Shape.toString(shape)
		return string.format( "%s: x %d y %d radius %d type %s\n%s",	
								shape.className,
								shape.pos:X(),
								shape.pos:Y(),
								shape.radius,
								(shape.type or 'unknown'),
								Shape.GetPropertiesString(shape))
	end
	
	
	function Shape._RenderShapeProperties(shape,rHelper,x,y)
		local str = {}
		table.insert(str,"Class: "..shape.className)
		table.insert(str,string.format( "x %d y %d",shape.pos:X(),shape.pos:Y()))
		table.insert(str,string.format( "radius %d ",shape.radius))
		table.insert(str,string.format( "type %s ",(shape.type or 'unknown')))
	
		local propTable = Shape._GetPropertiesTable(shape.properties)

		for _,prop in pairs(propTable) do
			table.insert(str,prop)
		end

		local fh = 16
		for index,propstr in pairs(str) do
			local ypos 	=	y + fh * (index -1)
			local xpos	=	x
			RenderHelper.DrawText(rHelper,propstr,xpos,ypos,1,{red=128,green=128,blue=128,alpha=128},"left","bottom")
		end
		
	end
	
	

	function Shape.Render(shape,rHelper)
		if (Shape.debug) then
			Shape.RenderDebug(shape,rHelper)
		end
	end

	function Shape.RenderDebug(shape,rHelper)
		local epos = shape:GetVectorPosition()
	
	 	RenderHelper.SetColour(rHelper, shape.colour or {255, 255, 255, 80} )
		if (shape.type == 'circle') then
			RenderHelper.DrawCircle(rHelper,epos:X(), epos:Y(), shape.radius or 100)
		else
			RenderHelper.DrawBox(rHelper,epos:X(), epos:Y(), shape.width,shape.height)
		end
		
		if (shape.text and shape.attachedlist[1]) then
			local attached = shape.attachedlist[1]
			local str = string.format("%s: active='%s' count = %d debounce = %d allow = '%s'",
								shape.text,(attached:IsAlive() and 'true' or 'false'),
								attached.count,
								attached.debounce,
								(attached:AllowTrigger() and 'true' or 'false'))

			RenderHelper.DrawText(rHelper,str,epos:X(), epos:Y(),1,nil,"left")
		end
		
		RenderHelper.SetColour(rHelper,{255, 0, 255, 255} )

		if (shape.properties and shape.properties.type and shape.properties.type =='mission') then
			Shape._RenderShapeProperties(shape,rHelper,epos:X()+shape.radius,epos:Y())
		end
		
		for i,attached in pairs(shape.attachedlist) do
			Shape._RenderAttachedLine(shape,rHelper,attached)
		end
			

	end
	
	function Shape._RenderAttachedLine(shape,rHelper,attached)
		local epos = shape:GetVectorPosition()
		
		if (attached) then
			local aPos = attached:GetVectorPosition()
			if (shape.type == 'circle') then
				RenderHelper.DrawLine(rHelper,epos:X(), epos:Y(),aPos:X(),aPos:Y())
			else
				RenderHelper.DrawLine(rHelper,epos:X()+shape.width/2, epos:Y()+shape.height/2,aPos:X(),aPos:Y())
			end

		end
		
	end

	function Shape.GetPropertiesString(shape)
		local properties 	=	shape.properties
		return Shape._GetProperties(properties)
	end


	function Shape.IsPointInside(shape,point)
		assert(shape.className == Shape.className,'THIS IS NOT A SHAPE')
	
		local ex,ey		=	point:X(),point:Y()
		local x,y,z 	=	shape:GetPosition()
		if (shape.type == 'circle') then
			local dx = ex - x
			local dy = ey - y
			--local isinside	=	(math.sqrt(dx*dx + dy*dy) < shape.radius) and 'true' or 'false'
			--Logger.lprint("Point "..ex..","..ey.." v "..x..","..y.." type "..shape.type.." isinside "..isinside)
			return math.sqrt(dx*dx + dy*dy) < shape.radius
		else
			local w2	=	shape.width/2
			local h2	=	shape.height/2
			return (ex > x ) and (ex < x + shape.width) and (ey > y  and ey < y + shape.height)
		end

	end
	
	-- Point check to see if entity is inside a 
	-- shape.
	function Shape._IsInside(shape,entity)
		assert(shape.className == Shape.className,'THIS IS NOT A SHAPE')
		local ex,ey,ez	=	entity:GetPosition()
		local x,y,z 	=	shape:GetPosition()
		
		if (shape.type == 'circle') then
			local dx = ex - x
			local dy = ey - y
			return math.sqrt(dx*dx + dy*dy) < shape.radius
		else
			local w2	=	shape.width/2
			local h2	=	shape.height/2
			-- TODO Change DAME file to centre shapes
			return (ex > x ) and (ex < x + shape.width) and (ey > y  and ey < y + shape.height)
		end
		
	end
	
	-- Callback whenever 'Entity' (usually the 'Player')
	-- enters Shape boundary
	
	function Shape.EntityEntered(shape,entity)
--		assert(false,'Entered Shape')
--		shape.colour	=	{255,0,0,255}
--		for i,attached in pairs(shape.attachedlist) do
--			if (attached.className ~= 'Shape' and attached.EntityEntered) then
--				attached:EntityEntered(entit,shape)
--			end
--		end

		if (shape.killwhenin) then
			shape.alive	=	false
		end

	end

	-- Callback whenever 'Entity' (usually the 'Player')
	-- leaves Shape boundary
	
	function Shape.EntityLeft(shape,entity)
--		shape.colour	=	{255,255,255,80}
--		for i,attached in pairs(shape.attachedlist) do
--			-- Don't allow Shapes to inform other Shapes
--			-- otherwise we will get into a recursive loop 
--			if (attached.className ~= 'Shape' and attached.EntityLeft) then
--				attached:EntityLeft(entity,shape)
--			end
--		end
	end
	
	-- TO BE DEPRACATED.
	function Shape.EntityCheck(shape,entity)	
	
	 	local isinside = (entity and Shape._IsInside(shape,entity))
		if (isinside) then
			if (not shape.wasinside[entity]) then
			 	Shape.EntityEntered(shape,entity)
				shape.wasinside[entity] = true
				
			end
		else
			if (shape.wasinside[entity]) then
		 		Shape.EntityLeft(shape,entity)
				shape.wasinside[entity] = false
			
			end
		end
		
	end
	
	function Shape._GetProperties(properties)	
		local str =	Shape._GetPropertiesTable(properties)	
		return table.concat(str,"\n")
	end


	function Shape._GetPropertiesTable(properties)	
		local str 			=	{}
		table.insert(str,"PROPERTIES")
		for property,propvalue in pairs(properties) do
			table.insert(str,property.." = "..Shape._GetValueString(propvalue))
		end
		return str
	end

	function Shape._GetValueString(value)
		local t = type(value)
		if (t == 'boolean') then
			return value and 'true' or 'false'
		elseif (t == 'table') then
			--return "{table} ="..Shape._GetProperties(value)
			return "??"
		elseif (t == 'string') then
			return "'"..value.."'"
		else
			return value
		end
	end
	
end
