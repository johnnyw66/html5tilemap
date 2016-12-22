-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt

if not HomingMissile then

HomingMissile							=	{ }
HomingMissile.className					=	"HomingMissile" 

HomingMissile.STATE_HMISSILE_TRACKING	=	1
HomingMissile.STATE_HMISSILE_FALLING	=	2
HomingMissile.STATE_HMISSILE_SLEEPING	=	3


HomingMissile.kHMISSILES_MAX					= 	8
HomingMissile.kHMISSILE_MAXTURNANGLE			=	90.0
HomingMissile.kHMISSILE_SPEED					=	200.0
HomingMissile.kHMISSILE_LIFESPAN				=	15.0
HomingMissile.kHMISSILE_ANGULAR_ACCELERATION	=	180.0


local	ANIM_ENEMYMISSILE_FRAME1	=	"enemy_missile__1"
local	ANIM_ENEMYMISSILE_FRAME2	=	"enemy_missile__2"
local	ANIM_ENEMYMISSILE_FRAME3	=	"enemy_missile__3"

local	ANIM_PLAYERMISSILE_FRAME1	=	"player_missile__1"
local	ANIM_PLAYERMISSILE_FRAME2	=	"player_missile__2"
local	ANIM_PLAYERMISSILE_FRAME3	=	"player_missile__3"


	function HomingMissile.Create( startpos,  rot,  follow,  damage, lifespan)

		--Logger.lprint("HomingMissile.Create()") 

		local homingmissile = {
            	following		=	follow,
				vPos			=	startpos and Vector4.Create(startpos) or 
									Vector4.Create(follow:GetVectorPosition():X()-50+math.random(0,100),follow:GetVectorPosition():Y()-720),
				vDir			=	Vector4.Create(0.7,0.7),
	            rot				=	rot or 0.0,
	            Lifespan		=	lifespan or HomingMissile.kHMISSILE_LIFESPAN,
	            time			=	0.0,
				strength		=	255,
	            nState			=	HomingMissile.STATE_HMISSILE_TRACKING,
	            damage			=	damage or 0,
	            bInvincible		=	false,
				bMarkedForDeath	=	false,
				isPlayer 		=	follow.className ~= 'Player', 
				colline 		=	Line2D.Create(Vector4.Create(0,0),Vector4.Create(0,0)),
	            currentAngularDir,
	            currentAngularSpeed,
	            tMissile,
				className		=	HomingMissile.className,

		}
		setmetatable(homingmissile, {
	  		__index = HomingMissile
		})

		homingmissile.vPos:Add(homingmissile.vPos,Vector4.Create(math.random(1,4),math.random(1,4)))
		homingmissile.animation = TextureAnim.Create(3)

		
		if (homingmissile.isPlayer) then
			homingmissile.animation:AddFrame(ANIM_PLAYERMISSILE_FRAME1)
			homingmissile.animation:AddFrame(ANIM_PLAYERMISSILE_FRAME2)
			homingmissile.animation:AddFrame(ANIM_PLAYERMISSILE_FRAME3)
		else
			homingmissile.animation:AddFrame(ANIM_ENEMYMISSILE_FRAME1)
			homingmissile.animation:AddFrame(ANIM_ENEMYMISSILE_FRAME2)
			homingmissile.animation:AddFrame(ANIM_ENEMYMISSILE_FRAME3)
		end

		homingmissile.animation:Play(true, true)

		return homingmissile 
	end

	function HomingMissile.Follow(homingmissile,who)
		homingmissile.following = who
	end
	
	function HomingMissile.Update(homingmissile,dt)
 		HomingMissile.UpdateLive(homingmissile,dt)
	end
	
	function HomingMissile.UpdateLive(homingmissile,dt)

		--Logger.lprint("HomingMissile:Update()") 

		assert(dt ~= 0,'HomingMissile - invalid Update dt')

		if (homingmissile.animation) then
		 	homingmissile.animation:Update(dt)
		end
		
		homingmissile.time =	homingmissile.time +	dt
		
		
		local	diff_vec	=	Temp.v0 
		local	state		=	homingmissile.nState
				
		if(state	~=	HomingMissile.STATE_HMISSILE_FALLING and homingmissile.time > homingmissile.Lifespan) then
		
			homingmissile.nState	=	HomingMissile.STATE_HMISSILE_FALLING
			state					=	homingmissile.nState
		
		end
			   		
		if(state	==	HomingMissile.STATE_HMISSILE_FALLING or not homingmissile.following:IsAlive()) then

			diff_vec:SetXyzw(0,homingmissile.vPos:Y(),0,0)
			if (homingmissile.time > 1.25*homingmissile.Lifespan) then
				homingmissile.nState	=	HomingMissile.STATE_HMISSILE_SLEEPING
				HomingMissile.MarkForDeath(homingmissile)
				homingmissile.time		=	0
				return
			end
		elseif(state	==	HomingMissile.STATE_HMISSILE_TRACKING) then

			Vector4.Subtract(diff_vec,homingmissile.following:GetVectorPosition(), homingmissile.vPos)

		elseif(state	==	HomingMissile.STATE_HMISSILE_SLEEPING) then
			if (homingmissile.time > 4) then
				homingmissile.nState	=	HomingMissile.STATE_HMISSILE_TRACKING
			end
			return
		end

		diff_vec:Normalise2()

		-- Work out current angle
		local rot_tar = math.atan2(diff_vec:Y(), diff_vec:X())
		rot_tar = math.deg(rot_tar)
		rot_tar = ( rot_tar + 360.0 ) % 360.0


		local heading_vec= Temp.v1  	
		
		heading_vec:SetXyzw(homingmissile.vDir:X(),homingmissile.vDir:Y(),0,0)
		heading_vec:Normalise2()

		local perpheading_vec= Temp.v2 

		perpheading_vec:SetXyzw(-heading_vec:Y(), heading_vec:X(), 0, 0)


		local perpCosineAngle = Vector4.Dot2(diff_vec, perpheading_vec)
		
		local newAngularDirection	=	(perpCosineAngle>0) and 1.0 or -1.0
		
		
		if ( newAngularDirection ~= homingmissile.currentAngularDir ) then
			homingmissile.currentAngularDir = newAngularDirection
			
			homingmissile.currentAngularSpeed = 0.0
		end

		homingmissile.currentAngularSpeed = homingmissile.currentAngularSpeed +(dt * HomingMissile.kHMISSILE_ANGULAR_ACCELERATION)

		if ( homingmissile.currentAngularSpeed > HomingMissile.kHMISSILE_MAXTURNANGLE ) then
			homingmissile.currentAngularSpeed = HomingMissile.kHMISSILE_MAXTURNANGLE
		end
		
		local maxTurnAngle = homingmissile.currentAngularSpeed * dt

		if(math.abs(rot_tar-homingmissile.rot)>maxTurnAngle) then
			local leftAngle  = ( homingmissile.rot + 360.0 - maxTurnAngle ) % 360.0
			local rightAngle = ( homingmissile.rot + maxTurnAngle ) % 360.0

			if(perpCosineAngle>0) then
				homingmissile.rot = rightAngle
			else
				homingmissile.rot = leftAngle
			end
		else
			homingmissile.rot = rot_tar
		end

		-- Work out new direction
		local rotrad	=	math.rad(homingmissile.rot)
		
		local vx = math.cos(rotrad) 
		local vy = math.sin(rotrad)
		
		homingmissile.vDir:SetXyzw(vx * dt * HomingMissile.kHMISSILE_SPEED,vy * dt * HomingMissile.kHMISSILE_SPEED,0,0)
		
		Vector4.Add(homingmissile.vPos, homingmissile.vDir, homingmissile.vPos)

		
	end

	function HomingMissile.GetCollisionLine(homingmissile,dt)
		--Logger.lprint("HomingMissile:GetCollisionLine()") 
		
		local future = Vector4.Create( homingmissile.vDir)
		Vector4.Multiply(future,future,4) 
		Vector4.Add(future,future,homingmissile.vPos)
		
		homingmissile.colline:SetPoints(homingmissile.vPos,future)
--		homingmissile.colline:CalculateCentreAndRadius() 

		return homingmissile.colline 
		
	end
	
	function HomingMissile.Render(homingmissile,renderHelper)
		--	Logger.lprint("HomingMissile:Render()") 

		RenderHelper.DrawTexture(renderHelper,homingmissile.animation:GetRenderTexture(),homingmissile.vPos:X(), homingmissile.vPos:Y(),-homingmissile.rot - 90,0.5)
	--	HomingMissile.RenderDebug(homingmissile,renderHelper)

	end

	function HomingMissile.RenderDebug(homingmissile,renderHelper)
		local mpos 	= 	homingmissile:GetVectorPosition()
 		RenderHelper.SetColour(renderHelper, {0, 0, 255, 128} )
		RenderHelper.DrawCircle(renderHelper,mpos:X(), mpos:Y(),  10)
		RenderHelper.DrawText(renderHelper,homingmissile:toString(),mpos:X()+40, mpos:Y())
		
		HomingMissile.GetCollisionLine(homingmissile):Render(renderHelper)
		
		
	end

	function HomingMissile.toString(homingmissile)
		local str =	{}
		return string.format("HomingMissile: state %d rot %f time %f pos = %s  diffV = %s",
			homingmissile.nState,
			homingmissile.rot,
			homingmissile.time,homingmissile.vPos:toString(),Temp.v0:toString())
	end
	
	function HomingMissile.GetVectorPosition(homingmissile)
		return homingmissile.vPos
	end

	function HomingMissile.GetCoords(homingmissile)
		return homingmissile.vPos:X(),homingmissile.vPos:Y(),homingmissile.vPos:Z()
	end
	
	function HomingMissile.GetPosition(homingmissile)
		return homingmissile.vPos:X(),homingmissile.vPos:Y(),homingmissile.vPos:Z()
	end
	
	function HomingMissile.SetPosition(homingmissile, v)
		homingmissile.vPos = Vector4.Create(v)
	end
	
	function HomingMissile.MarkForDeath(homingmissile)
		homingmissile.bMarkedForDeath = true
		ExplosionManager.AddExplosion({x=homingmissile.vPos:X(),y=homingmissile.vPos:Y(),z=0})
	end
	
	function HomingMissile.IsMarkedForDeath(homingmissile)
		return homingmissile.bMarkedForDeath
	end
	
	function HomingMissile.ApplyDamage(homingmissile,damage)
		homingmissile:MarkForDeath()
	end
	
	function HomingMissile.GetDamage(homingmissile)
		return homingmissile.damage
	end
	
	function HomingMissile.Cleanup(homingmissile)
		--Logger.lprint("HomingMissile.Render()") 
		homingmissile.vPos		=	nil
		homingmissile.following	=	nil
		homingmissile.tMissile	=	nil
		homingmissile.vDir		=	nil
		homingmissile.colline	=	nil 
	end

end
