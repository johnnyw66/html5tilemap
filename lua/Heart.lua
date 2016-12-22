-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not Heart then

Heart = {}
--	x(t)	= (1/20) [16*sin(t)]
--  y(t)	= (1/20)[13*cos(t)-5*cos(2t)-cos(4t)-7]

local sin	=	math.sin
local cos	=	math.cos
local pi	=	math.pi
local floor	=	math.floor
local rad	=	math.rad

local steps	=	1024
local resolution	=	16834
local xHeart = {}
local yHeart = {}


	-- t = 0 to pi -- will give a distance 
	-- of approx 1.03 units
	
	function Heart.Init(stps)
		steps	=	stps or 1024
		
		local k = (resolution/20)
		
		for ti = 0,steps do
			local t = pi*ti/steps
			local st	=	sin(t)
			local xt	=	floor(k*16*st*st*st + 0.5)
			local yt	=	floor(k*(13*cos(t) - 5*cos(2*t) - cos(4*t) - 7) + 0.5)
			xHeart[ti] = xt
			yHeart[ti] = yt
		end
		
	end



	function Heart.GetPosition(direction,t)
		
		
	end
	
	function Heart.PlotPlayer(rHelper,player,time)
	
		local freq	=	0.5	
		local len 	=	128 + 24*sin(time*2*pi*freq)
		
		local rang		=	rad(player.direction)
		local xc,yc,_	=	player:GetPosition()
		
		local ca			=	cos(rang)
		local sa			=	sin(rang)
		

		for t = 0, steps,16 do
		
			local x	=	len*xHeart[t]/resolution
			local y	=	len*yHeart[t]/resolution
		
			local xt	=	x*ca - y*sa
			local yt	=	x*sa + y*ca
			local mxt	=	-x*ca - y*sa
			local myt	=	-x*sa + y*ca
			
			if (rHelper) then
				RenderHelper.DrawCircle(rHelper,xt+xc,yt+yc,1)
				RenderHelper.DrawCircle(rHelper,mxt+xc,myt+yc,1)
			end
		end
		
	end

	
	Heart.Init(1024)
	
end
