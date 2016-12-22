-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not EnemyData then

	-- brian add your conversion function here
	function PixelsToInternal(pixel,maxvalue)
		return ((pixel/maxvalue)-0.5)
	end

	local DEFAULTPOLYFULL	=
	{
		p1x	=	-0.5, p1y	=	-0.5,
		p2x	=	0.5,  p2y	=	-0.5,
		p3x	=	0.5,  p3y	=	0.5,
		p4x	=	-0.5,  p4y	=	0.5,
	}


	local DEFAULTPOLYSMALL	=
	{
		p1x	=	-0.125, p1y	=	-0.125,
		p2x	=	0.125,  p2y	=	-0.125,
		p3x	=	0.125,  p3y	=	0.125,
		p4x	=	-0.125,  p4y	=	0.125,
	}
	

	local DEFAULTPOLY	=
	{
		p1x	=	-0.25, p1y	=	-0.25,
		p2x	=	0.25,  p2y	=	-0.25,
		p3x	=	0.25,  p3y	=	0.25,
		p4x	=	-0.25,  p4y	=	0.25,
	}
	

--	generic_explosion_smoke =  {{x=0,y=0,scale=2.0},{x=0,y=0,scale=1.5,frameshor=8,delay=0.5,framesvert=8,texture='explosionuv64_smoke'}}

	local generic_explosion			=  	{{x=0,y=0,scale=2.0}}
	local generic_explosion_smoke	= 	{{x=0,y=0,scale=2.0},{x=0,y=0,scale=1.5,frameshor=8,delay=0.5,framesvert=1,texture='explosionuv'}}
	local generic_explosion_large	= 	{{x=0,y=0,scale=2.0}}

	EnemyData = {

		-- used in level_Jungle1 - no  need to define collision polys for player
		-- Player 'Physics' defined within DAME (see docs/README.txt)
		
		playervehicle1	=	{
							{frames = {"vehicle1bottom","vehicle1bottom2"},fps = 12,offset={x=0,y=0},explosions={{scale=2}}},
							{frames = {"vehicle1top"},offset={x=0,y=-24},ctype='turret',}

						},

		playervehicle2	=	{	{frames = {"vehicle2bottom","vehicle2bottom"},fps = 12,explosions={{scale=2}}},
											{frames = {"vehicle2top"},offset={x=12,y=-12},ctype='turret',}

							},


		-- jungle

		deadouthouse			=	{{frames = {"outhouse4_dead"},offset={x=0,y=0},explosions={{scale=1.7}}}},
		outhouse	=	{{frames = {"outhouse4"},explosions={{scale=2}},

								collidepoly = {
									p1x = 	PixelsToInternal(80,256),	p1y = PixelsToInternal(45,256),
									p2x = 	PixelsToInternal(178,256),	p2y = PixelsToInternal(45,256),
									p3x = 	PixelsToInternal(178,256),	p3y = PixelsToInternal(196,256),
									p4x = 	PixelsToInternal(80,256),	p4y = PixelsToInternal(196,256),
								},


		}},
		deadhut			=	{{frames = {"hut5_dead"},offset={x=0,y=0},explosions={{scale=1.7}}},
									{uvanimation = {texture="smoke_loop",frameshor=8,framesvert=4},offset={x=-20,y=0},scale=2.5,}

							},
		hut			=	{{frames = {"hut5"},explosions={{scale=1.7}},
								collidepoly = {
									p1x = 	PixelsToInternal(58,256),	p1y = PixelsToInternal(6,256),
									p2x = 	PixelsToInternal(197,256),	p2y = PixelsToInternal(6,256),
									p3x = 	PixelsToInternal(196,256),	p3y = PixelsToInternal(192,256),
									p4x = 	PixelsToInternal(61,256),	p4y = PixelsToInternal(192,256),
								},

		
		}},
		
		
		-- jungle
		deadhouse			=	{
									{frames = {"house3_dead"},offset={x=0,y=0},explosions={{scale=1.7}}},
									{uvanimation = {texture="smoke_loop",frameshor=8,framesvert=4},offset={x=0,y=0},scale=2.0,}
								},
		house		=	{{frames = {"house3"},
		
         explosions=generic_explosion_smoke,

								collidepoly = {
									p1x = 	PixelsToInternal(17,256),	p1y = PixelsToInternal(62,256),
									p2x = 	PixelsToInternal(240,256),	p2y = PixelsToInternal(69,256),
									p3x = 	PixelsToInternal(240,256),	p3y = PixelsToInternal(202,256),
									p4x = 	PixelsToInternal(16,256),	p4y = PixelsToInternal(196,256),
								},

		
		}},







		deadradar			=	{{frames = {"radarbase2_dead"},offset={x=0,y=0},explosions={{scale=1.7}}}},
		radar	=	{	{
							frames  = {"radarbase2"},
							weaponcollide=false
						},
						{
							frames = {"radar6"},
							offset={x=0,y=0},
							collidepoly = {
									p1x = 	PixelsToInternal(1,128),	p1y = PixelsToInternal(38,128),
									p2x = 	PixelsToInternal(128,128),	p2y = PixelsToInternal(38,128),
									p3x = 	PixelsToInternal(63,128),	p3y = PixelsToInternal(114,128),
								},

							explosions={
									{x = 0, y = 0,scale = 2},
									{x = 0, y = 32, delay = 0.4},
									{x = 0, y = -32, delay = 0.2},
									{x = -32, y = 0, delay = 0.3},
									--{x = 32, y = -0},
							},
							ctype	= 'rotate'
						}

					},

		-- new brian
		
		

		
		

		enemyheli	=	{
							{frames  = {"enemy_helishadow"},offset={x = -16, y = 16},weaponcollide=false},
							{
							frames  = {"enemy_helibody"},
							collidepoly = {
									p1x = 	PixelsToInternal(16,64),	p1y = PixelsToInternal(20,128),
									p2x = 	PixelsToInternal(45,64),	p2y = PixelsToInternal(20,128),
									p3x = 	PixelsToInternal(51,64),	p3y = PixelsToInternal(124,128),
									p4x = 	PixelsToInternal(12,64),	p4y = PixelsToInternal(124,128),
								},

							explosions={
									{x = 0, y = 0,scale = 2},
									{x = 0, y = 32, delay = 0.4},
									{x = 0, y = -32, delay = 0.2},
									{x = -32, y = 0, delay = 0.3},
									--{x = 32, y = -0},
							},
						},
						{
							frames = {"enemy_heliblades"},
							ctype	= 'rotate',
							weaponcollide=false
						}

					},
		enemyhelispline	=	
					{
							{frames  = {"enemy_helishadow"},offset={x = -16, y = 16},weaponcollide=false},
							{
							frames  = {"enemy_helibody"},
							collidepoly = {
									p1x = 	PixelsToInternal(16,64),	p1y = PixelsToInternal(20,128),
									p2x = 	PixelsToInternal(45,64),	p2y = PixelsToInternal(20,128),
									p3x = 	PixelsToInternal(51,64),	p3y = PixelsToInternal(124,128),
									p4x = 	PixelsToInternal(12,64),	p4y = PixelsToInternal(124,128),
								},

							explosions={
									{x = 0, y = 0,scale = 2},
									{x = 0, y = 32, delay = 0.4},
									{x = 0, y = -32, delay = 0.2},
									{x = -32, y = 0, delay = 0.3},
									--{x = 32, y = -0},
							},
						},
						{
							frames = {"enemy_heliblades"},
							ctype	= 'rotate',
							weaponcollide=false
						}

					},


		--radar		=	{{frames = {"radar6"}}},
		--radarbase		=	{{frames = {"radarbase2"}}},


	
		playerHelicopxter	=	{{frames = {"outhouse4"},explosions={{scale=2}}}},


-- ************************** DESERT LEVEL BUILDINGS



		solidhousea		=	{{frames = {"solid_a"},
         explosions=generic_explosion_smoke,
								collidepoly = {
									p1x = 	PixelsToInternal(6,256),	p1y = PixelsToInternal(39,256),
									p2x = 	PixelsToInternal(254,256),	p2y = PixelsToInternal(39,256),
									p3x = 	PixelsToInternal(254,256),	p3y = PixelsToInternal(212,256),
									p4x = 	PixelsToInternal(6,256),	p4y = PixelsToInternal(212,256),
								},
		}},


		solid_a_dead			=	{
									{frames = {"solid_a_dead"},offset={x=0,y=0},explosions={{scale=1.7}}},
									{uvanimation = {texture="smoke_loop",frameshor=8,framesvert=4},offset={x=0,y=0},scale=2.0,}
								},


		solidhouseb		=	{{frames = {"solid_b"},
         explosions=generic_explosion_smoke,
								collidepoly = {
									p1x = 	PixelsToInternal(3,256),	p1y = PixelsToInternal(34,256),
									p2x = 	PixelsToInternal(254,256),	p2y = PixelsToInternal(44,256),
									p3x = 	PixelsToInternal(254,256),	p3y = PixelsToInternal(215,256),
									p4x = 	PixelsToInternal(6,256),	p4y = PixelsToInternal(215,256),
								},

		}},
		

		solid_b_dead			=	{
									{frames = {"solid_b_dead"},offset={x=0,y=0},explosions={{scale=1.7}}},
									{uvanimation = {texture="smoke_loop",frameshor=8,framesvert=4},offset={x=0,y=0},scale=2.0,}
								},

		solidhousec		=	{{frames = {"solid_c"},
         explosions=generic_explosion_smoke,
								collidepoly = {
									p1x = 	PixelsToInternal(5,256),	p1y = PixelsToInternal(28,256),
									p2x = 	PixelsToInternal(254,256),	p2y = PixelsToInternal(28,256),
									p3x = 	PixelsToInternal(254,256),	p3y = PixelsToInternal(215,256),
									p4x = 	PixelsToInternal(6,256),	p4y = PixelsToInternal(215,256),
								},

		}},
		solid_c_dead			=	{
									{frames = {"solid_c_dead"},offset={x=0,y=0},explosions={{scale=1.7}}},
									{uvanimation = {texture="smoke_loop",frameshor=8,framesvert=4},offset={x=0,y=0},scale=2.0,}
								},

		market1		=	{{frames = {"market1"},
         explosions=generic_explosion_smoke,
								collidepoly = {
									p1x = 	PixelsToInternal(30,256),	p1y = PixelsToInternal(5,256),
									p2x = 	PixelsToInternal(254,256),	p2y = PixelsToInternal(10,256),
									p3x = 	PixelsToInternal(254,256),	p3y = PixelsToInternal(250,256),
									p4x = 	PixelsToInternal(2,256),	p4y = PixelsToInternal(252,256),
								},


		}},

		market1_dead			=	{
									{frames = {"market1_dead"},offset={x=0,y=0},explosions={{scale=1.7}}},
									{uvanimation = {texture="smoke_loop",frameshor=8,framesvert=4},offset={x=0,y=0},scale=2.0,}
								},

		deserthut		=	{{frames = {"hut2"},
         explosions=generic_explosion_smoke,
								collidepoly = {
									p1x = 	PixelsToInternal(20,256),	p1y = PixelsToInternal(20,256),
									p2x = 	PixelsToInternal(230,256),	p2y = PixelsToInternal(40,256),
									p3x = 	PixelsToInternal(233,256),	p3y = PixelsToInternal(236,256),
									p4x = 	PixelsToInternal(18,256),	p4y = PixelsToInternal(236,256),
								},

		
		
		
		}},
		
		deserthut_dead			=	{{frames = {"hut2_dead"},offset={x=0,y=0},explosions={{scale=1.7}}}},

-- brian got here

		factory		=	{{frames = {"factory"},
         explosions=generic_explosion_smoke,
								collidepoly = {
									p1x = 	PixelsToInternal(16,256),	p1y = PixelsToInternal(32,256),
									p2x = 	PixelsToInternal(250,256),	p2y = PixelsToInternal(74,256),
									p3x = 	PixelsToInternal(254,256),	p3y = PixelsToInternal(223,256),
									p4x = 	PixelsToInternal(14,256),	p4y = PixelsToInternal(228,256),
								},

		}},
		factory_dead			=	{{frames = {"factory2_dead"},offset={x=0,y=0},explosions={{scale=1.7}}}},

		barracks		=	{{frames = {"barracks"},
         explosions=generic_explosion_smoke,
								collidepoly = {
									p1x = 	PixelsToInternal(80,256),	p1y = PixelsToInternal(4,256),
									p2x = 	PixelsToInternal(186,256),	p2y = PixelsToInternal(8,256),
									p3x = 	PixelsToInternal(184,256),	p3y = PixelsToInternal(233,256),
									p4x = 	PixelsToInternal(84,256),	p4y = PixelsToInternal(244,256),
								},

		}},
		barracksdead			=	{{frames = {"barracksdead"},offset={x=0,y=0},explosions={{scale=1.7}}}},

		factorysmall		=	{{frames = {"factory_small"},
         explosions=generic_explosion_smoke,
								collidepoly = {
									p1x = 	PixelsToInternal(17,128),	p1y = PixelsToInternal(1,128),
									p2x = 	PixelsToInternal(120,128),	p2y = PixelsToInternal(1,128),
									p3x = 	PixelsToInternal(120,128),	p3y = PixelsToInternal(126,128),
									p4x = 	PixelsToInternal(17,128),	p4y = PixelsToInternal(126,128),
								},
		}},
		factorysmall_dead			=	{{frames = {"factory_small2_dead"},offset={x=0,y=0},explosions={{scale=1.4}}}},

--[[
		radarbase	=	{	{frames  = {"radarbase2"}},
							{frames = {"radar6"},offset={x=128,y=32},
								collidepoly = {
									p1x = 	-0.125,	p1y = -0.125,
									p2x	=	0.125,	p2y	=	-0.125,
									p3x	=	0.125,	p3y	=	0.125,
									p4x	=	-0.125, p4y	=	0.125,
								},
								explosions={
									{x = 0, y = 0,scale=2},
									{x = 0, y = 32},
									{x = 0, y = },
									{x = -32, y = -32},
									{x = -64, y = -64},
								},
								ctype	= 'rotate'
							}

						},
]]--

		car			=	{{frames  = {"orbitor1"}}},
		train		=	{{frames  = {"train2"}, explosions={{x = 0, y = 0,scale=4},}},
						{
						frames  = {"traingun2"},
						offset={x=0,y=0},
						explosions= generic_explosion_large,
						ctype='turret',

						collidepoly = {
									p1x = 	PixelsToInternal(69,256),	p1y = PixelsToInternal(52,256),
									p2x = 	PixelsToInternal(187,256),	p2y = PixelsToInternal(52,256),
									p3x = 	PixelsToInternal(191,256),	p3y = PixelsToInternal(242,256),
									p4x = 	PixelsToInternal(61,256),	p4y = PixelsToInternal(242,256),
								},

						}
						},


		artillery		=	{{frames  = {"artillery"}, explosions={{x = 0, y = 0,scale=4},}},
						{
						frames  = {"artillerygun"},
						offset={x=0,y=16},
						explosions= generic_explosion_large,
						ctype='turret',

						collidepoly = {
									p1x = 	PixelsToInternal(69,256),	p1y = PixelsToInternal(52,256),
									p2x = 	PixelsToInternal(187,256),	p2y = PixelsToInternal(52,256),
									p3x = 	PixelsToInternal(191,256),	p3y = PixelsToInternal(242,256),
									p4x = 	PixelsToInternal(61,256),	p4y = PixelsToInternal(242,256),
								},

						}
						},




		tank		=	{{frames  = {"tankbottom6"}, explosions={{x = 0, y = 0,scale=4},},
							-- collidepoly = DEFAULTPOLYFULL
								collidepoly = {
									p1x = 	PixelsToInternal(69,256),	p1y = PixelsToInternal(52,256),
									p2x = 	PixelsToInternal(187,256),	p2y = PixelsToInternal(52,256),
									p3x = 	PixelsToInternal(191,256),	p3y = PixelsToInternal(242,256),
									p4x = 	PixelsToInternal(61,256),	p4y = PixelsToInternal(242,256),
								},

						 },
						{	frames  = {"tanktop6"},
						offset={x=0,y=0},
						explosions= generic_explosion_large,
						ctype='turret',

						}
		},
		smalljeep		=	{
						-- Example Shadow
						-- {frames  = {"smalljeep6shadow"},offset={x = -4, y = -4},weaponcollide=false},
						-- Main Parts
						{frames  = {"smalljeep6"}},
						{frames  = {"smalljeepgun6"},
						offset={x=0,y=0},
						ctype='turret',

						collidepoly = {
									p1x = 	PixelsToInternal(16,64),	p1y = PixelsToInternal(19,128),
									p2x = 	PixelsToInternal(48,64),	p2y = PixelsToInternal(19,128),
									p3x = 	PixelsToInternal(48,64),	p3y = PixelsToInternal(83,128),
									p4x = 	PixelsToInternal(16,64),	p4y = PixelsToInternal(83,128),
								},


						}
		},

		largejeep		=	{{frames  = {"largejeep2"}},
						{frames  = {"largejeeptop2"},
						offset={x=0,y=0},
						ctype='turret',

						collidepoly = {
									p1x = 	PixelsToInternal(16,64),	p1y = PixelsToInternal(19,128),
									p2x = 	PixelsToInternal(48,64),	p2y = PixelsToInternal(19,128),
									p3x = 	PixelsToInternal(48,64),	p3y = PixelsToInternal(83,128),
									p4x = 	PixelsToInternal(16,64),	p4y = PixelsToInternal(83,128),
								},


						}
		},



		}

	NOTUSED = {

		car			=	{
			{frames = {"orbitor1","orbitor2","orbitor3"}, collisionpoly = {}},
			{frames = {"turret1","turret2"}, collidepoly = {}},
			},


		radxar	=	{
		
					{	frames = {"radarbase"}, 
						fps	   = 10,
						collidepoly = {
							-- identical format to tilemap collisions
							-- fractions of images width and height
							-- we may need to put scale in here - as well (i.e double up on the data)
							p1x	=	-0.5, p1y	=	-0.5,
							p2x	=	0.5,  p2y	=	-0.5,
							p3x	=	0.5,  p3y	=	0.5,
							p4x	=	-0.5,  p4y	=	-0.5,
							},
						
						weaponcollide=false,
						indestruct=true,
						collidescale = 1,
						ctype		=	'benign'
					
					},
					{frames = {"radarantenna1","radarattena2"},radius=10,weaponcollide=true, ctype='rotating'},
				},
				
	}

	

	function EnemyData.CreateEnemyParts(enemy)
		local classname		=	enemy.name	
	
		local classObject	=	EnemyData[classname] or {{frames = {"outhouse4"}}}
		assert(classObject,'NO DEFINITION FOR '..classname)
		local	numParts	=	#classObject

		print("Class  = "..classname)
		print("Number of Parts = "..numParts)

		local parts		=	{}
		
		for partIndex,part in pairs(classObject) do
	
				local frames		= 	part.frames
				local fps			=	part.fps or 10
				local cpoly			=	part.collidepoly or  DEFAULTPOLY
				local scale			=	part.collidescale or 1
				local ctype			=	part.ctype or 'benign'
				local indes			=	part.indestruct
				local weaponcollide	=	part.weaponcollide 
				local offset		=	part.offset  or {x = 0, y = 0}
				local explosions	=	part.explosions  or {{x = 0, y = 0}}
				local width,height	=	0,0
				local tanim,sprite	=	nil,nil

				if (part.uvanimation) then	
					local animation	=	part.uvanimation
					local anim,sprite,fwidth,fheight	=	RenderHelper.CreateTextureAnimation(animation.frameshor,animation.framesvert,animation.texture,animation.fps or 10)
					tanim				=	{textureanimation = anim, loop = animation.loop, sprite = sprite,className='uvAnimation'}
					width				=	fwidth
					height				=	fheight
					
				elseif (part.frames) then
					
					-- build up animation Frames
					print("Number of Frames "..#frames.." FPS = "..fps)
					tanim  = TextureAnim.Create(#frames,fps)
	
					for idx,frameName in pairs(frames) do
						print("FrameName "..idx.." = "..frameName)
						tanim:AddFrame(frameName)
					end
				
					local t			=	Texture.Find(frames[1])
					assert(t,"Texture Missing "..frames[1].." for "..classname)
					width		=	Texture.GetWidth(t) 
					height		=	Texture.GetHeight(t)
				
				else
					assert(false,'frames or animation table not defined')
				end
				
				
				local polypoints = {}
				
				
				-- DO NOT SUPPORT MORE THAN 100 POINTS!
				for idx = 1, 100 do
					local px = cpoly["p"..idx.."x"]
					local py = cpoly["p"..idx.."y"]
					if ((not px) or (not py)) then
						assert( not (px or py),'tileInfo:COORDINATES MUST BE PAIRED: Index = '..idx)
						break
					end
					local u = px*width*scale
					local v = py*height*scale
					table.insert(polypoints,{x = u,y = v})
				end

				print("Collision Points "..#polypoints)
		
				for i,point in pairs(polypoints) do
					print(i,point.x,point.y)
				end

				local radius	=	math.max(width,height)*scale/math.sqrt(2)
				local poly 		= 	Polygon.Create(polypoints,radius)
				poly.radius 	= 	radius

				local ePart = EnemyPart.Create(enemy,width,height,ctype,tanim,offset,poly,radius,indes,weaponcollide,explosions)
				table.insert(parts,ePart)
		end
		return parts
	end
	
end

