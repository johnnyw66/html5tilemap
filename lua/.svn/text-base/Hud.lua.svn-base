if not Hud then

Hud							=	{ }
Hud.className					=	"Hud" 

local	NUMDIGITFRAMES	=	2
local	DIGITGAP     	=   16

local 	ICON_CHAFF				=	"icon_chaff"			-- player chaff 
local 	ICON_HOME				=	"icon_missile"			-- player homing missiles
local 	ICON_LIVES				=	"icon_lives"			-- player lives
local 	ICON_MISSIONS			=	"icon_missions"			-- missions remaining

local 	ICON_RAPID_FIRE_ON1		=	"icon_rapidfire_on1"
local 	ICON_RAPID_FIRE_ON2		=	"icon_rapidfire_on2"
local 	ICON_RAPID_FIRE_OFF		=	"icon_rapidfire_off"

local 	ICON_LOCK_ON1			=	"icon_lock_on1"
local 	ICON_LOCK_ON2			=	"icon_lock_on2"
local 	ICON_LOCK_OFF			=	"icon_lock_off"

local 	ICON_SHIELD_ON1			=	"icon_shield_on1"
local 	ICON_SHIELD_ON2			=	"icon_shield_on2"
local 	ICON_SHIELD_OFF			=	"icon_shield_off"

local 	ICON_ARMED_MISSILE		=	'icon_missilearmed'
local 	ICON_FREE_MISSILE		=	'icon_missilefree'
local 	ICON_BAR				=	'HUD_Bar'

local	TEXT_SCORE				=	Locale.GetLocaleText("SCORE")	
local 	TEXT_TIME				=	Locale.GetLocaleText("TIME")


local 	POS_CHAFF_X_ICON		=	0
local 	POS_CHAFF_Y_ICON		=	0
local 	POS_CHAFF_X_TEXT		=	0
local 	POS_CHAFF_Y_TEXT		=	0
local 	ALIGN_CHAFF_Y			=	""


local 	POS_HOME_X_ICON			=	0
local 	POS_HOME_Y_ICON			=	0
local 	POS_HOME_X_TEXT			=	0
local 	POS_HOME_Y_TEXT			=	0

local 	POS_LIVES_X_ICON		=	0
local 	POS_LIVES_Y_ICON		=	0
local 	POS_LIVES_X_TEXT		=	0
local 	POS_LIVES_Y_TEXT		=	0

local 	POS_MISSIONS_X_ICON		=	0
local 	POS_MISSIONS_Y_ICON		=	0
local 	POS_MISSIONS_X_TEXT		=	0
local 	POS_MISSIONS_Y_TEXT		=	0

local 	POS_RAPIDF_X_ICON		=	0
local 	POS_RAPIDF_Y_ICON		=	0

local 	POS_LOCKED_X_ICON		=	0
local 	POS_LOCKED_Y_ICON		=	0

local 	POS_SHIELD_X_ICON		=	0
local 	POS_SHIELD_Y_ICON		=	0

local 	POS_ARMEDM_X_ICON		=	0
local 	POS_ARMEDM_Y_ICON		=	0




local rad				=	math.rad
local deg				=	math.deg
local sin				=	math.sin
local cos				=	math.cos
local atan2				=	math.atan2

local arrowColour		=   {red = 123,green = 107,blue = 52, alpha = 127}
local textColour		=   {red = 123,green = 107,blue = 52, alpha = 127}
local arrowlineColour	=   {red = 123,green = 107,blue = 52, alpha = 127}
local titleColour		=  {red = 127,green = 127,blue = 127, alpha = 127}
local infoColour		=   {red = 27,green = 27,blue = 27, alpha = 127}
local lineColour		=   {red = 119,green = 63,blue = 3, alpha = 127}
Hud.arrowBaseVector		=	Vector4.Create(800,600)
Hud.time				=	0
Hud.timeRemaining		=	0
	
Hud.sprite				=	Sprite.Create()
Hud.digit				=	Sprite.Create()
Hud.digitAnimations			=	{}
Hud.debug					=	false

    local function drawTitle(renderHelper,x,y,length,title)
            RenderHelper.DrawLine(renderHelper,x,y,x+length,y,lineColour)
            RenderHelper.DrawLine(renderHelper,x,y+1,x+length,y+1,lineColour)
            RenderHelper.SetFont(renderHelper,FONT_HUD_TITLE)
            RenderHelper.DrawText(renderHelper,x + length,y-linetitlegap,title,1,textColour ,"right","bottom")
          end

	
	local function causeEvent(eventName,bl)
		if (Hud.callback) then
			Hud.callback(eventName,bl)
		end
	end
	


	function Hud.Init(player,scoreman,missionman,missileman,callback)
		Hud.time					=	0
		Hud.score					=	0
		Hud.player 					= 	player
		Hud.scoreman				=	scoreman
		Hud.missionman				=	missionman
		Hud.missileman				=	missileman
		
		Hud.callback				=	callback
		
		Hud.rapidfire				=	false
		Hud.shield					=	false
		Hud.missileLocked			=	false

		Hud.timeRemaining			= 	0
		Hud.submissions				=	0
		
		Hud.lastmissileLocked		=	false
		Hud.lastrapidfire			= 	Hud.player and Hud.player.rapidfire or false
		Hud.lastshield				=   Hud.player and (Hud.player.damagemultiplier < 1) or false
		

		Hud._SetUpDigitAnimations(0,"0_")
		Hud._SetUpDigitAnimations(1,"1_")
		Hud._SetUpDigitAnimations(2,"2_")
		Hud._SetUpDigitAnimations(3,"3_")
		Hud._SetUpDigitAnimations(4,"4_")
		Hud._SetUpDigitAnimations(5,"5_")
		Hud._SetUpDigitAnimations(6,"6_")
		Hud._SetUpDigitAnimations(7,"7_")
		Hud._SetUpDigitAnimations(8,"8_")
		Hud._SetUpDigitAnimations(9,"9_")

		Hud.homefiring,Hud.maxhomemissiles		= 0,0
		
	end
	
	function Hud._SetUpDigitAnimations(number,baseName)
		Hud.digitAnimations[number] = TextureAnim.Create(NUMDIGITFRAMES)

		local anim = Hud.digitAnimations[number]

		for frm = 1,NUMDIGITFRAMES do
			TextureAnim.AddFrame(anim,{frame=frm,textureid=baseName..'1'})
		end

		
	end
	
	
	function Hud.Update(dt)
		Hud.time			= Hud.time + dt	
		Hud.timeRemaining	= Hud.missionman and Hud.missionman:GetTimeRemaining() or 0
		Hud.submissions		= Hud.missionman and Hud.missionman:GetSubmissionsRemaining() or 0
		Hud.homefiring,Hud.maxhomemissiles		= Hud.missileman:GetHomeMissilesFired() 
		
		
		Hud.score			= Hud.scoreman and Hud.scoreman:GetScore() or 0
		Hud.lifes			= Hud.player and Hud.player:GetLives() or 0
		Hud.homingmissiles	= Hud.player and Hud.player:GetNumberOfHomingMissiles() or 0
		Hud.missileLocked	= Hud.player and Hud.player:GetLocked() 
		
		Hud.chaff			= Hud.player and Hud.player:GetChaff() or 0
		Hud.rapidfire		= Hud.player and Hud.player.rapidfire or false
		Hud.shield			= Hud.player and (Hud.player.damagemultiplier ~= Hud.player.odamagemultiplier) or false
		Hud.direction		= Hud.missionman and Hud.missionman.GetDirection(Hud.player) --or Vector4.Create()
		Hud.lowtime			= Hud.missionman and Hud.missionman.IsMissionTimeLow()
		
		
		if (Hud.lastrapidfire ~= Hud.rapidfire) then
			causeEvent("RapidFire",Hud.rapidfire)
		end

		if (Hud.lastshield ~= Hud.shield) then
			causeEvent("Shield",Hud.shield)
		end

		if (Hud.lastmissileLocked ~= Hud.missileLocked) then
			causeEvent("Target",Hud.missileLocked)
		end
		
		
		Hud.lastrapidfire		=	Hud.rapidfire
		Hud.lastshield			=	Hud.shield
		Hud.lastmissileLocked	=	Hud.missileLocked
		
	end

  function Hud._RenderNumberR(renderHelper, x,  ypos,  number, nDigits, spacing, scale )

        local iDigit = 0

        repeat
			local mod = ( 10 * math.modf( number / 10 ) )
			if( mod > 0 ) then
				digit = number % mod
			elseif( number > 0 )  then
				digit = number
			else
				digit = 0
			end

			local xpos =  x - iDigit * (spacing or 16)

			local anim = Hud.digitAnimations[digit]
			local textureid =	anim:GetRenderTexture().textureid
			Sprite.SetTexture(Hud.sprite,RenderHelper.TextureFind(textureid))

			RenderHelper.DrawSprite(renderHelper,Hud.sprite,xpos,ypos,scale or 1)

			number = math.modf(number/10)
            iDigit = iDigit + 1
		until (number == 0)

	end

    -- TO BE DEPRECATED

    function Hud._RenderNumber(renderHelper, x,  ypos,  number, nDigits, spacing, scale )

      	if( nDigits < 0 ) then
			local calc = number
			nDigits = 0
			repeat
				nDigits = nDigits + 1
				calc,_ = math.modf(calc/10)
			until(calc <= 0)
		end

		local digit

  		for iDigit = nDigits - 1, 0,-1 do
			local mod = ( 10 * math.modf( number / 10 ) )
			if( mod > 0 ) then
				digit = number % mod
			elseif( number > 0 )  then
				digit = number
			else
				digit = 0
			end

			local xpos =  x + iDigit * (spacing or 16)

			local anim = Hud.digitAnimations[digit]
			local textureid =	anim:GetRenderTexture().textureid
			Sprite.SetTexture(Hud.sprite,RenderHelper.TextureFind(textureid))

			RenderHelper.DrawSprite(renderHelper,Hud.sprite,xpos,ypos,scale or 1)

			number = math.modf(number/10)
		end
	end


    function Hud._RenderIcon(renderHelper,x,y,scale,icon,text)
		local textureid =	icon or Hud.iconAnimation:GetRenderTexture().textureid
		Sprite.SetTexture(Hud.sprite,RenderHelper.TextureFind(textureid))
     	RenderHelper.DrawSprite(renderHelper,Hud.sprite,x,y,scale or 1)
		if (Hud.debug and text) then
			RenderHelper.DrawText(renderHelper,icon,x-32,y+32,0.5,textColour,"left","center")
		end

	end

 
   	function Hud._RenderHudInfo(renderHelper,x,y,scale,texid,text,number,valign,halign,noinfo,titlecolour,infocolour)

	end

    function Hud.RenderIcons(renderHelper)

    end

	function Hud._RenderArrowHead(rHelper,direction,baseVector,stemLength,tipAngle,colour)
		

		local xbase,ybase	=	baseVector:X(),baseVector:Y()

		local tipLength		=	stemLength*0.20

		local ly = ybase + stemLength*sin(rad(direction - 90))
		local lx = xbase + stemLength*cos(rad(direction - 90))

		local t1y = tipLength*sin(rad(direction - 90 + tipAngle))
		local t1x = tipLength*cos(rad(direction - 90 + tipAngle))

		local t2y = tipLength*sin(rad(direction - 90 - tipAngle))
		local t2x = tipLength*cos(rad(direction - 90 - tipAngle))


		RenderHelper.DrawLine(rHelper,xbase, ybase, lx,ly,colour)
		RenderHelper.DrawLine(rHelper,lx, ly, lx-t1x, ly-t1y,colour)
		RenderHelper.DrawLine(rHelper,lx, ly, lx-t2x, ly-t2y,colour)
	end
	
	
	function Hud.DrawDirection(renderHelper)
		if (Hud.direction) then
			local pDirection = Hud.player.direction 
			local dy,dx = Hud.direction:Y(),Hud.direction:X()
			local px,py	=	Hud.player:GetPosition()

			local disttonose	= 48+16*math.sin(6*Hud.time*(1/4))	
			local radangle	=	math.rad(pDirection)

			local pdx = disttonose*math.sin(radangle)	
			local pdy = -disttonose*math.cos(radangle)	

			local 	dot = (pdx*dx + pdy*dy)/disttonose
			-- between -1 and +1 (+1 is closest angle)
			dot	=	dot + 1
			-- between 0 and 2
			dot =	dot *0.5
			
			-- dot between 0 and 1 (1 being in the correct direction)
			arrowColour.alpha 		=	127*dot
			arrowlineColour.alpha 	=	127*dot
			
			--Logger.lprint("Dot = "..dot)
			
			--RenderHelper.DrawLine(renderHelper,px,py,px+pdx,py+pdy,arrowlineColour)
			local arrowdirection = deg(atan2(dy,dx)) + 90
			local imghgt = 12
			RenderHelper.DrawTexture(renderHelper,"directionarrow",px+pdx+imghgt*dx,py+pdy+imghgt*dy,- arrowdirection ,1,arrowColour)
		end
	end
	
	local function GetHomeFiringStatus()
		local status	=	{}
		for i = 1,Hud.maxhomemissiles do
			if (i <= Hud.homefiring) then
				-- this missile is being fired
				table.insert(status,"M")
			else
				-- this one is free
				table.insert(status,"m")
			end
		end
		return table.concat(status," "),status
	end
	

	local function RenderIconNumber(renderHelper,icon,number,xpos,ypos,text)
		local iconscale	=	0.6
		local sc =0.5*1
		local hw,hh		=	16,16
		RenderHelper.DrawImage(renderHelper,icon,xpos,ypos,0,iconscale)
		Hud._RenderNumberR(renderHelper,xpos+hw,ypos+hh,number,2,DIGITGAP*sc ,sc)
		if (Hud.debug and text) then
			RenderHelper.DrawText(renderHelper,text.." ("..icon..")",xpos,ypos,0.5,textColour,"left","center")
		end
		
	end
	
	
	
	function Hud.XXXRenderXXXX(renderHelper)
		local missStr,missilesStatus	=	GetHomeFiringStatus()

		local scale		=	1
		local XPOS		=	60
		local YPOS		=	40
	
		RenderHelper.SetFontScale(renderHelper,1,1)
		RenderHelper.SetFont(renderHelper,FONT_HUD)
	
		local fh		=	scale*RenderHelper.GetFontHeight(renderHelper)


		local tr = string.format("%s %02d:%02d",TEXT_TIME,math.modf(Hud.timeRemaining/60),(Hud.timeRemaining % 60)) 
		local ftr =	Hud.lowtime and (math.sin(Hud.time*6*2+0.5) > 0 and tr or "") or tr 
		local sc = string.format("%s %d",TEXT_SCORE,Hud.score)
		local mr = string.format("MISSIONS %02d",Hud.submissions)
		local lf = string.format("LIVES %02d",Hud.lifes or 0)
		local cf = string.format("CHAFF %02d",Hud.chaff or 0)
		local hm = string.format("MISSILES %02d %s",Hud.homingmissiles or 0,missStr)

		local ln = string.format("LEVEL :%s",Levels.GetCurrentLevelName() or '???')
		

		local lockicon		=	Hud.missileLocked and (math.sin(Hud.time*6*2) > 0 and ICON_LOCK_ON1 or ICON_LOCK_ON2) or ICON_LOCK_OFF 
		local rapidicon 	=	(Hud.rapidfire  and (Hud.player:ShowPlayerRapidFireIcon() and ICON_RAPID_FIRE_ON1 or ICON_RAPID_FIRE_ON2) or ICON_RAPID_FIRE_OFF)
		local shieldicon	=	(Hud.shield  and (Hud.player:ShowPlayerShieldIcon() and ICON_SHIELD_ON1  or ICON_SHIELD_ON2) or ICON_SHIELD_OFF)
		
		local extras = string.format("%s %s %s",rapidicon,shieldicon,lockicon)

		RenderHelper.DrawText(renderHelper,sc,XPOS,YPOS,scale,textColour,"left","top")
		RenderHelper.DrawText(renderHelper,ftr,1024-XPOS,YPOS,scale,textColour,"right","top")

		local icon_heightgap	=	64
		local TXPOS				=	XPOS + 32
		
		RenderHelper.DrawText(renderHelper,mr,TXPOS,YPOS+2*icon_heightgap,scale,textColour,"left","center")
		RenderHelper.DrawText(renderHelper,lf,TXPOS,YPOS+3*icon_heightgap,scale,textColour,"left","center")
		RenderHelper.DrawText(renderHelper,cf,TXPOS,YPOS+4*icon_heightgap,scale,textColour,"left","center")
		RenderHelper.DrawText(renderHelper,hm,TXPOS,YPOS+5*icon_heightgap,scale,textColour,"left","center")
		RenderHelper.DrawText(renderHelper,extras,TXPOS,YPOS+6*icon_heightgap,scale,textColour,"left","center")

		if (Hud.direction and false) then
			local dy,dx = Hud.direction:Y(),Hud.direction:X()
			local arrowdirection = deg(atan2(dy,dx)) + 90
			Hud._RenderArrowHead(renderHelper,arrowdirection,Hud.arrowBaseVector,64,22,textColour)
			-- RenderHelper.DrawTexture(renderhelper,textid,x,y,rotation,lscale,rgba,uvs)
		end
			

		Hud.RenderNew(renderHelper)

		-- Hmmm - this is bad!
		RenderHelper.SetFont(renderHelper,FONT_DEFAULT)
	end
	
	function Hud.Render(renderHelper)
		RenderHelper.SetFontScale(renderHelper,1,1)
		RenderHelper.SetFont(renderHelper,FONT_HUD)

	
		local icon_heightgap			=	48	
		local missStr,missilesStatus	=	GetHomeFiringStatus()
		
		Hud._RenderIcon(renderHelper,512,684,1,ICON_BAR,"xx")
		local XPOS			=	60
		local YPOS			=	100
		
		local HUDSCOREXPOSL			=	236
		local HUDSCOREWIDTH			=	204
		local HUDSCOREXPOSR			=	HUDSCOREXPOSL+HUDSCOREWIDTH
		local HUDSCOREXPOSC			=	HUDSCOREXPOSL+HUDSCOREWIDTH*0.5
		
		local HUDTIMEXPOSL			=	1024-236-204
		local HUDTIMEXPOSR			=	HUDTIMEXPOSL+HUDSCOREWIDTH
		local HUDTIMEXPOSC			=	HUDTIMEXPOSL+HUDSCOREWIDTH*0.5

		local HUDYPOS				=	692
		
		
		local tr = string.format("%02d:%02d",math.modf(Hud.timeRemaining/60),(Hud.timeRemaining % 60)) 
		local ftr =	Hud.lowtime and (math.sin(Hud.time*6*2+0.5) > 0 and tr or "") or tr 
		local sc = string.format("%d", Hud.score)
		local hudScale	=	1.2

		RenderHelper.DrawText(renderHelper,sc,HUDSCOREXPOSC,HUDYPOS,hudScale,textColour,"center","center")
		RenderHelper.DrawText(renderHelper,ftr,HUDTIMEXPOSC,HUDYPOS,hudScale,textColour,"center","center")

	--	RenderHelper.DrawLine(renderHelper,0,HUDYPOS,1024,HUDYPOS,textColour)

		XPOS		=	60
		YPOS		=	50
	
		local iconWidth	=	46
		local iconScale	=	0.6
		
		local lockicon		=	Hud.missileLocked and (math.sin(Hud.time*6*2) > 0 and ICON_LOCK_ON1 or ICON_LOCK_ON2) or ICON_LOCK_OFF 
		local rapidicon 	=	(Hud.rapidfire  and (Hud.player:ShowPlayerRapidFireIcon() and ICON_RAPID_FIRE_ON1 or ICON_RAPID_FIRE_ON2) or ICON_RAPID_FIRE_OFF)
		local shieldicon	=	(Hud.shield  and (Hud.player:ShowPlayerShieldIcon() and ICON_SHIELD_ON1  or ICON_SHIELD_ON2) or ICON_SHIELD_OFF)
		
		local iGap			=	iconWidth+6 
		local PUPSXPOS		=	1024 - 3*iGap + 20
		local PUPSYPOS		=	688
		Hud._RenderIcon(renderHelper,PUPSXPOS,PUPSYPOS,iconScale,rapidicon,"rapid")
		Hud._RenderIcon(renderHelper,PUPSXPOS+iGap,PUPSYPOS,iconScale,shieldicon,"shield")
		Hud._RenderIcon(renderHelper,PUPSXPOS+2*iGap,PUPSYPOS,iconScale,lockicon,"lock")

		XPOS				=	iconWidth*0.5
		iGap				=	iconWidth 

		RenderIconNumber(renderHelper,ICON_MISSIONS,Hud.submissions or 0,XPOS,PUPSYPOS,"missions")
		RenderIconNumber(renderHelper,ICON_LIVES,Hud.lifes or 0,XPOS+iGap,PUPSYPOS,"lives")
		RenderIconNumber(renderHelper,ICON_CHAFF,Hud.chaff or 0,XPOS+iGap*2,PUPSYPOS,"chaff")
		RenderIconNumber(renderHelper,ICON_HOME,Hud.homingmissiles or 0,XPOS+iGap*3,PUPSYPOS,"missiles")

	
		-- Draw Status line for player's homing missiles
	--	local missStr,missilesStatus	=	GetHomeFiringStatus()
	--	local XPOSMISSILE,YPOSMISSILE	=	XPOS,YPOS
	--	
	--	for idx,status in pairs(missilesStatus) do
	--		local xpos,ypos,icon = XPOSMISSILE+(idx - 1)*iconWidth,YPOSMISSILE,(status == 'm' and ICON_FREE_MISSILE or ICON_ARMED_MISSILE)
	--		Hud._RenderIcon(renderHelper,xpos,ypos,iconScale,icon,"missile")
	--	end
	
		RenderHelper.SetFontScale(renderHelper,1,1)
		RenderHelper.SetFont(renderHelper,FONT_DEFAULT)
	
	end
	
end
