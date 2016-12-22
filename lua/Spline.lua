-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not Spline then

Spline 				=	{}
Spline.className	=	"Spline"
Spline.debug		=	false

function Spline.Create(primitive)

	local spline = {
		primitive	=	primitive,
		type		=	'spline',
		className 	= 	Spline.className,
	}

	setmetatable(spline,{ __index = Spline })
	Spline._Init(spline,primitive)
	return spline
end


function Spline._Init(spline,primitive)
	if (primitive.type == 'spline') then
		Spline._InitSpline(spline,primitive)
	else
		Spline._InitBezier(spline,primitive)
	end
end

function Spline._InitBezier(spline,primitive)
	spline.type		=	primitive.type
	local nodes		=	primitive.nodes 
	local closed	=	primitive.closed
	spline.closed	=	closed
	local totalLen 	=	0
	local sections 	= 	{}
	local lastNode	=	nil
	
	local cp1,cp2,cp3,cp4
	
	for bezIndex, bez in pairs(nodes) do

		if (not lastNode) then
			cp1	=	bez[1]
			cp2	=	bez[2]
			cp3	=	bez[3]
			cp4	=	bez[4]
		else
			cp1	=	lastNode
			cp2	=	bez[1]
			cp3	=	bez[2]
			cp4	=	bez[3]
		end

--		local dbg=string.format("cp1 = %f,%f cp2 = %f,%f, cp3=%f,%f cp4=%f,%f",cp1.x,cp1.y,cp2.x,cp2.y,cp3.x,cp3.y,cp4.x,cp4.y)
--		assert(false,dbg)	

		lastNode	=	cp4
		
		assert(lastNode,'LastNode is nil!')
		
		-- Create bez,bz 
		local bz = Bezier.Create( 
								Vector2.Create(cp1.x,cp1.y),  
								Vector2.Create(cp2.x,cp2.y), 
								Vector2.Create(cp3.x,cp3.y), 
								Vector2.Create(cp4.x,cp4.y))

		
		local len = Bezier.GetLength(bz)

		totalLen = totalLen + len

		table.insert(sections,{splineVector = bz, length = len, accumlen = totalLen, 
				cp1  = {x = cp1.x, 	y = cp1.y}, 
				cp2 =  {x = cp4.x, 	y = cp4.y}, 
				cp1a = {x = cp2.x,	y = cp2.y},
		 		cp2a = {x = cp3.x,	y = cp3.y}
				})


	end

	if (closed) then
		local bez	=	nodes[1]
		cp1			=	cp4
		cp2			=	cp3
		cp3			=	bez[2]
		cp4			=	bez[1]

		local dbg=string.format("cp1 = %f,%f cp2 = %f,%f, cp3=%f,%f cp4=%f,%f",cp1.x,cp1.y,cp2.x,cp2.y,cp3.x,cp3.y,cp4.x,cp4.y)
		--assert(false,dbg)	

		local bz = Bezier.Create( 
								Vector2.Create(cp1.x,cp1.y),  
								Vector2.Create(cp2.x,cp2.y), 
								Vector2.Create(cp3.x,cp3.y), 
								Vector2.Create(cp4.x,cp4.y))

		
		
		
		local len = Bezier.GetLength(bz)

		totalLen = totalLen + len
		
		table.insert(sections,{splineVector = bz, length = len, accumlen = totalLen, 
				cp1  = {x = cp1.x, 	y = cp1.y}, 
				cp2 =  {x = cp4.x, 	y = cp4.y}, 
				cp1a = {x = cp2.x,	y = cp2.y},
		 		cp2a = {x = cp3.x,	y = cp3.y}
				})
		


	end
	
	spline.sections 		=	sections 
	spline.totalLength		=	totalLen
end

function Spline._InitSpline(spline,primitive)

	spline.type		=	primitive.type
	
	local nodes		=	primitive.nodes 
	local ptype		=	primitive.type 
	local closed	=	primitive.closed
	spline.closed	=	closed

	local totalLen 	=	0

	local sections 	= 	{}
	local lastNode	=	nil
	
	for nodeIndex, node in pairs(nodes) do


		if (lastNode) then

			local cp1	=	lastNode.controlPoint
			local cp2	=	node.controlPoint
			
			local cp1a	=	{x = cp1.x + lastNode.tan1.x, y = cp1.y + lastNode.tan2.y}
			local cp2a	=	{x = cp2.x - node.tan1.x, y = cp2.y - node.tan2.y}

			local bz = Bezier.Create( 
									Vector2.Create(cp1.x,cp1.y),  
									Vector2.Create(cp1a.x,cp1a.y), 
									Vector2.Create(cp2a.x,cp2a.y), 
									Vector2.Create(cp2.x,cp2.y))


			local len = Bezier.GetLength(bz)

			totalLen = totalLen + len

			table.insert(sections,{splineVector = bz, length = len, accumlen = totalLen, 
				cp1  = {x = cp1.x, 	y = cp1.y}, 
				cp2 =  {x = cp2.x, 	y = cp2.y}, 
				cp1a = {x = cp1a.x,	y = cp1a.y},
			 	cp2a = {x = cp2a.x,	y = cp2a.y}
				})


		end
		
		lastNode	=	node

	end
	if (closed) then
		local node	=	nodes[1]
		local cp1	=	lastNode.controlPoint
		local cp2	=	node.controlPoint
	
		local cp1a	=	{x = cp1.x + lastNode.tan1.x, y = cp1.y + lastNode.tan2.y}
		local cp2a	=	{x = cp2.x - node.tan1.x, y = cp2.y - node.tan2.y}

		local bz = Bezier.Create( 
							Vector2.Create(cp1.x,cp1.y),  
							Vector2.Create(cp1a.x,cp1a.y), 
							Vector2.Create(cp2a.x,cp2a.y), 
							Vector2.Create(cp2.x,cp2.y))


							local len = Bezier.GetLength(bz)

							totalLen = totalLen + len

		table.insert(sections,{splineVector = bz, length = len, accumlen = totalLen, 
		cp1  = {x = cp1.x, 	y = cp1.y}, 
		cp2 =  {x = cp2.x, 	y = cp2.y}, 
		cp1a = {x = cp1a.x,	y = cp1a.y},
	 	cp2a = {x = cp2a.x,	y = cp2a.y}
		})

		
	end
	
	spline.sections 		=	sections 
	spline.totalLength		=	totalLen
	
	
end


function Spline.IsClosed(spline)
	return spline.closed
end

function Spline.GetTotalLength(spline)
	return spline.totalLength
end


function Spline.Debug(spline)


	local sections	=	spline.sections 
	local tLen		=	spline.totalLength
	local isCls		=	spline.closed and 'closed' or 'not closed'
	print("Spline.Debug",isCls," total Len",tLen,"Number of Sections = ",#sections)
	
--	for secIdx,section in pairs(sections) do
--		print("Section ",secIdx," Direction Vector ",section.splineVector:toString()," length = ",section.length, " Position Vector ",section.position:toString())
--	end

end


-- tValue from 0 to 1
function Spline.CalcPosition(spline,vector,tValue,fromEnd)
	local rtValue			=	fromEnd and (1-tValue) or tValue
	local lengthTravelled	=	rtValue*spline.totalLength
	local sections			=	spline.sections 

	for secIdx,section in pairs(sections) do
		if lengthTravelled <= section.accumlen  then
			-- found section, now calculate how far 'in' we are on that section (0 = @start 1 = @end)
			local lt 		= 	1 - (section.accumlen - lengthTravelled)/section.length
			local bz		= 	section.splineVector
			local x,y		=	Bezier.GetPositionXY(bz,lt)
			vector:SetXyzw(x,y,0,0)
			return
		end
	end
end

-- Calculate Spline tValue from DAME segmentID and DAME t value

function Spline.FindPathTValue(spline,segmentID,tValue)
	local sections			=	spline.sections 
	local section			=	sections[segmentID + 1]		-- segmentID is 0 based
	local lenTravelled 		=	section.accumlen + (tValue-1)*section.length
	return lenTravelled/spline.totalLength
end


function Spline._RenderDebug(spline,rHelper)

	for _,section in pairs(spline.sections) do
		local cp1,cp2,cp1a,cp2a 	=	section.cp1,section.cp2,section.cp1a,section.cp2a
	
		--RenderHelper.DrawLine(rHelper,cp1.x,cp1.y,cp2.x,cp2.y,{255,255,255,220})

		RenderHelper.DrawCircle(rHelper,cp1.x,cp1.y,16,{255,255,255,255})
		RenderHelper.DrawCircle(rHelper,cp1a.x,cp1a.y,32,{255,0,0,255})
		RenderHelper.DrawCircle(rHelper,cp2a.x,cp2a.y,32,{0,0,255,255})
		RenderHelper.DrawCircle(rHelper,cp2.x,cp2.y,16,{0,255,0,255})

		local bz = section.splineVector
		
		local blen = bz:GetLength()

		RenderHelper.DrawText(rHelper,"BEZIER LENGTH = "..blen,cp1.x,cp1.y)
	
		for t = 0,1,0.001 do
			local x,y = Bezier.GetPositionXY(bz,t)
			RenderHelper.DrawCircle(rHelper,x,y,1,{0,255,0,120})
		end
	
	end
	
end

function Spline.Render(spline,rHelper)

	if (Spline.debug) then
		Spline._RenderDebug(spline,rHelper)
	end
	
end

end
