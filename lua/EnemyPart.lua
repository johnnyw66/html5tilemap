-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt

if not EnemyPart then

EnemyPart 			=	{}
EnemyPart.className	=	"EnemyPart"
EnemyPart.debug						=	false
local tmpV						=	Vector4.Create()
local sqrt						=	math.sqrt
local cos						=	math.cos
local sin						=	math.sin
local rad						=	math.rad

local kENEMY_MAXTURNANGLE			=	90.0
local kENEMY_ANGULAR_ACCELERATION	=	120.0


	-- EnemyPart.Create(width,height,tanim,poly,radius,indes,weaponcollide)

	function EnemyPart.Create(enemy,width,height,ctype,animation,offset,poly,radius,indesct,weaponcollide,explosions)

		local enemypart = {
			enemy		=	enemy,
			width		=	width	or 1,
			height		=	height	or 1,
			ctype		=	ctype,
			radius		=	radius  or 1,
			animation	=	animation,
			poly 		=	poly or 1,
			indes		=	indes,
			offset		=	offset or {x = 0, y = 0},
			explosions	=	explosions or {x = 0, y = 0},
			direction		=	0,
			weaponcollide	=	weaponcollide,
	
					currentAngularSpeed	=	0,
					currentAngularDir	=	0,
	
			className	=	EnemyPart.className,
		}
		assert(animation,'NIL ANIMATION '..enemy.name)
		setmetatable(enemypart,{ __index = EnemyPart })
		EnemyPart._Init(enemypart)
		return enemypart
	end


	function EnemyPart._Init(enemypart)
		enemypart.xoff		=	enemypart.offset.x
		enemypart.yoff		=	enemypart.offset.y
		enemypart.direction	=	enemypart.enemy.direction

		if (enemypart.animation.className == 'uvAnimation') then
			local loop			=	enemypart.animation.loop
			enemypart.sprite	=	enemypart.animation.sprite
			enemypart.animation	=	enemypart.animation.textureanimation
			TextureAnim.Play(enemypart.animation,true)
			
		else
			TextureAnim.Play(enemypart.animation,true)
		end
		
	end
	
	function EnemyPart.GetExplosions(enemypart)
		return enemypart.explosions
	end
	
	function EnemyPart.Render(enemypart,renderHelper,xpos,ypos,direction,scale)
		xpos	=	xpos + enemypart.xoff
		ypos	=	ypos + enemypart.yoff

		local tid = enemypart.animation:GetRenderTexture()
		local uvs	= tid.uvs

		if (uvs) then
		
			Sprite.SetUvs(enemypart.sprite,
				uvs.tlu,uvs.tlv,
				uvs.blu,uvs.blv,
				uvs.bru,uvs.brv,
				uvs.tru,uvs.trv
			)
		
			RenderHelper.DrawSprite(renderHelper,enemypart.sprite,xpos,ypos,scale,direction)
		
		else
			RenderHelper.DrawTexture(renderHelper,tid,xpos,ypos,direction ,scale)
		end
		
		EnemyPart.RenderDebug(enemypart,renderHelper,xpos,ypos,direction,scale)

	end
	

	
	function EnemyPart.RenderDebug(enemypart,renderHelper,xpos,ypos,direction,scale)
		
		if (EnemyPart.debug) then
			Polygon.SetScale(enemypart.poly,scale)
			Polygon.SetPosition(enemypart.poly,xpos,ypos)
			Polygon.Render(enemypart.poly,renderHelper,direction)
		end
		
	end


	function EnemyPart.Update(enemypart,dt)
		if (enemypart.animation) then
			--Logger.lprint("Enemy.Update Animation")
			enemypart.animation:Update(dt)
			--enemypart.follow	=	enemypart.enemy.follow
			--EnemyPart.Turn(enemypart,dt)
		end
	end
	
	function EnemyPart.GetVectorPosition(enemypart)
		return enemypart.enemy:GetVectorPosition()
	end
	


	function EnemyPart.Turn(enemypart,dt)

		local	diff_vec	=	Temp.v0 

		Vector4.Subtract(diff_vec,enemypart.follow:GetVectorPosition(), enemypart:GetVectorPosition())
		diff_vec:Normalise2()

		-- Work out target bearing
		
		local rot_tar = math.atan2(diff_vec:Y(), diff_vec:X())
		rot_tar = (math.deg(rot_tar)	+ 90)
		enemypart.targetbearing	=	rot_tar % 360

		enemypart.angdistance = ((enemypart.targetbearing - (enemypart.direction % 360)))

		enemypart.leftangdist = ((360-enemypart.targetbearing)	+ (enemypart.direction % 360)) % 360
		enemypart.rightangdist = ((enemypart.targetbearing + (360-(enemypart.direction % 360)))) % 360
		

		local	clockwiseDirection	=	(enemypart.rightangdist < enemypart.leftangdist) 
		
		
		if ( clockwiseDirection ~= enemypart.currentAngularDir ) then
			enemypart.currentAngularDir = clockwiseDirection
			enemypart.currentAngularSpeed = 0.0
		end

		enemypart.currentAngularSpeed = enemypart.currentAngularSpeed +(dt * kENEMY_ANGULAR_ACCELERATION*enemypart.turnrate)

		if ( enemypart.currentAngularSpeed > kENEMY_MAXTURNANGLE ) then
			enemypart.currentAngularSpeed = kENEMY_MAXTURNANGLE
		end
		
		local maxTurnAngle = enemypart.currentAngularSpeed * dt
		
		if(math.min(enemypart.rightangdist,enemypart.leftangdist)>maxTurnAngle) then
		
			if (clockwiseDirection) then
				enemypart.direction = (enemypart.direction + maxTurnAngle) % 360

			else
				-- go anti clockwise
				enemypart.direction = (enemypart.direction - maxTurnAngle) % 360
			end

		else
			enemypart.direction = enemypart.targetbearing
		end

	end
	
	function EnemyPart.CollidePoly(enemypart,xpos,ypos,px,py,direction,scale)
		return Polygon.IsPointInside2(enemypart.poly,xpos+enemypart.xoff,ypos+enemypart.yoff,px,py,direction,scale)
	end

end
