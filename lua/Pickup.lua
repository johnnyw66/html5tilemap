-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Pickup) then

assert(Locale,'Locale.lua Source Must be included before Pickup.lua')

Pickup				=	{}
Pickup.className	=	"Pickup"

Pickup.PICKUPDEBUG          =   false
Pickup.FRAMESPERSECOND		=	10


Pickup.PICKUP_MISSILE       =   0
Pickup.PICKUP_SHIELD        =   1
Pickup.PICKUP_HEALTH        =   2
Pickup.RADIUS        		=   24
Pickup.RADIUSSQ        		=   Pickup.RADIUS*Pickup.RADIUS
local tmpV					=	Vector4.Create()
local textColour			=	{red=0,green=0,blue=0,alpha=127}
local textScale				=	1
local PI2					=	math.pi*2 
local random				=	math.random
local cos					=	math.cos
local sin					=	math.sin

local PickupAnimations	=	{

	homingmissile	=	{
			frames = {"pickuppic"}, 
			fps		=	10,
			text	=	Locale.GetLocaleText("HOMING MISSILE"),
		},
	
	rapidfire	=	{
		frames = {"pickuppic"}, 
		fps		=	10,
		text	=	Locale.GetLocaleText("RAPID FIRE"),
	},

	timeshift	=	{
		frames = {"pickuppic"}, 
		fps		=	10,
		text	=	Locale.GetLocaleText("TIME SHIFT"),
	},

	extratime	=	{
		frames = {"pickuppic"}, 
		fps		=	10,
		text	=	Locale.GetLocaleText("EXTRA TIME"),
	},
	
	extralife	=	{
		frames = {"pickuppic"}, 
		fps		=	10,
		text	=	Locale.GetLocaleText("EXTRA LIFE"),
	},
	
--	speedup		=	{
--	
--		frames = {"pickuppic"}, 
--		fps		=	10,
--		text	=	Locale.GetLocaleText("SPEED UP"),
--	},
	
	powerup		=	{
		frames = {"pickuppic"}, 
		fps		=	10,
		text	=	Locale.GetLocaleText("POWER UP"),
	},
	
	indestructible	=	{
		frames = {"pickuppic"}, 
		fps		=	10,
		text	=	Locale.GetLocaleText("INDESTRUCTIBLE"),
	},
	
	chaff	=	{
		frames = {"pickuppic"}, 
		fps		=	10,
		text	=	Locale.GetLocaleText("CHAFF"),
	},
	

}
	function Pickup.Create(pos,type,player)
		Logger.lprint("Pickup.Create")

		local pickup = {
				pos			=	pos or Vector2.Create(80,80),	
				time		=	0,
				type		=	type,
				anim		=	nil,
				player		=	player,
				animations	=	{},
				radius		=	Pickup.RADIUS,
				radiussq	=	Pickup.RADIUSSQ,
				angle		=	0,
				phase		=	random()*PI2,
				superstate	=	superstate,
				ttl			=	20,
				scale		=	1,
				text		=	"?",
				className	=	Pickup.className,
		}

		setmetatable(pickup, { __index = Pickup })
		Pickup.Init(pickup)
		return pickup

	end

	function Pickup.CreateAnimationPackage(pickup)
		local	pickupname	=	pickup.type
	
		local animation		=	PickupAnimations[pickupname] 
		pickup.centre		=	Vector4.Create(pickup.pos)

		pickup.text 		=	animation and animation.text or "UNKNOWN"
		local frames		=	animation and animation.frames or {"unknown"}
		local fps			=	animation and animation.fps	or 10
		
		local tanim  = TextureAnim.Create(#frames,fps)
		for idx,frameName in pairs(frames) do
			print("FrameName "..idx.." = "..frameName)
			tanim:AddFrame(frameName)
		end

		pickup.sprite 		=	Sprite.Create()
		pickup.anim			=	tanim

		if (pickup.anim) then
			TextureAnim.Play(pickup.anim)
		end
		
	--	return tanim
	end

	function Pickup.Init(pickup)
		Pickup.CreateAnimationPackage(pickup)
    end

	function Pickup.GetTypeString(pickup)
		return pickup.type
	end

	function Pickup.GetTextString(pickup)
		return pickup.text
	end
	
	function Pickup.GetCollisionObject(pickup)
		return {x = pickup.pos:X(), y = pickup.pos:Y(), z = 0, radius = pickup.radius, radiussq = pickup.radiussq,className='PickupCollisionObject'}
	end


	function Pickup.Update(pickup,dt)

		pickup.time 		= 	pickup.time + dt
		pickup.angle		=	pickup.angle + dt*360
		pickup.scale		=	0.85 +  (1-0.85)*math.sin(pickup.time*6*2)
		local ang			=	pickup.time*6*0.25+pickup.phase
	
		local dx = 128*sin(ang) 
		local dy = 128*cos(ang) 

		tmpV:SetXyzw(dx,dy,0,0)
		
		Vector4.Add(pickup.pos,pickup.centre,tmpV)
		
		if (pickup.anim) then
			TextureAnim.Update(pickup.anim,dt)
		end
		
		
	end
	
	function Pickup.IsAlive(pickup)
		return (pickup.time < pickup.ttl)
	end

	function Pickup.IsFinished(pickup)
		return (pickup.time >= pickup.ttl)
	end
	
	function Pickup.GetNormalTime(pickup)
		return math.min(1,pickup.time/pickup.ttl)
	end

	function Pickup.Hit(pickup,dt)
	
	end
	
			
	
	function Pickup.Collect(pickup,by)
		PickupManager.CollectPickup(pickup,by)
		if (by and by.CollectPickup) then
			by:CollectPickup(pickup:GetTypeString())
		end
	end
	
	function Pickup.GetX(pickup)
		return pickup.pos:X()
	end

	function Pickup.GetY(pickup)
		return pickup.pos:Y()
	end

	function Pickup.GetZ(pickup)
		return pickup.pos:Z()
	end
	

	function Pickup.Cleanup(pickup)
	
	end
	
	function Pickup.Render(pickup,renderHelper)
		assert(pickup.className ~= Pickup.ClassName,'OH NO NOT OUR CLASS '..(pickup.className or 'NO CLASSNAME'))
	
		local nTime				=	Pickup.GetNormalTime(pickup)
		local textureid 		=	pickup.anim:GetRenderTexture()
		local startbeat			=	0.01
		local endbeat			=	4
		local numbeatspersec 	=	nTime < 0.75 and startbeat or startbeat - (startbeat - endbeat)*nTime
		
		local f 				=	numbeatspersec*0.5
		
		
		
		local xpos,ypos	=pickup:GetX(), pickup:GetY()
		
		--RenderHelper.DrawCircle(renderHelper,xpos,ypos,pickup.radius,{200,0,0})
		RenderHelper.DrawText(renderHelper,pickup.text,xpos,ypos,textScale,textColour)
		
		
		if (math.sin(pickup.time*6*f) > 0) then
			Sprite.SetTexture(pickup.sprite,RenderHelper.TextureFind(textureid))
			RenderHelper.DrawSprite(renderHelper,pickup.sprite,xpos,ypos+16,pickup.scale,pickup.angle)
		end
		
	end
	
	-- Sound FX
	function Pickup.BounceSFX()
	--	RenegadeOpsSoundPlayer.SoundPickupBounce()
	end


	function Pickup.SpawnSFX()
	--	RenegadeOpsSoundPlayer.SoundPickupSpawn()
	end
	
end
