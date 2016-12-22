-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Constants) then
Constants = {}

Constants.INGAMEFONT                =   "60bold"
Constants.SCOREFONT                 =   "26bold"
Constants.DEFAULTFONT               =   "18bold"
Constants.MESSAGEFONT               =   "60bold"

Constants.PLAYERSHIPID				=	'ship'
Constants.NASTYID					=	'heavy' --'orbitor'

Constants._OFFLINE					= 	false		-- set to false for real live game
Constants._USEDUMMYID				=	false		-- set to true if running the game in offline mode
Constants._MYDUMMYPSNID				=	"johnny16"	-- Dummy offline id - if _OFFLINE true - also see GameSessionManager.dummyUsers for unid names
Constants.GAMETYPE					= 	"mini"		-- or "arcade"
Constants.GAMETYPE					= 	"arcade"

Constants.PARTICLEGRAVITY 			=	9.8

-- System Messages

Constants.SYSTEM_MESSAGE_REFRESH	=	"REFRESH"
Constants.SYSTEM_MESSAGE_REMOVE		=	"REMOVE"



Constants.SEED					=	12345		-- TESTING ONLY CONSTANT (Seeding Random number generator)
Constants.SCREENWIDTH			=	1024
Constants.SCREENHEIGHT			=	720

Constants.SCREENMIDX			=	Constants.SCREENWIDTH/2
Constants.SCREENMIDY			=	Constants.SCREENHEIGHT/2

Constants.DIRECTIONLEFT			=	"LEFT"
Constants.DIRECTIONRIGHT		=	"RIGHT"
Constants.DIRECTIONDOWN			=	"DOWN"
Constants.DIRECTIONUP			=	"UP"

Constants.MAXJOYSTICKS			=	1
	
Constants.KEY_UP				=	0
Constants.KEY_DOWN				=	1
Constants.KEY_LEFT				=	2
Constants.KEY_RIGHT				=	3
Constants.KEY_SELECT			=	4
Constants.KEY_START				=	5
Constants.KEY_DEBUG				=	6
Constants.KEY_SPEEDUP			=	7
Constants.KEY_NORMAL			=	8


Constants.KEY_CHAFF				=	9
Constants.KEY_MISSILES			=	10
Constants.KEY_MISSILES2			=	11

Constants.AXISX					=	12
Constants.AXISY					=	13
Constants.AXISZ					=	14
Constants.GYROY					=	15

-- Alternative Keys for playing the game 
-- 1 Joystick Key maps to a particular arrow direction

Constants.KEY_SELECTLEFT		=	16
Constants.KEY_SELECTRIGHT		=	17
Constants.KEY_SELECTUP			=	18
Constants.KEY_SELECTDOWN		=	19
	
Constants.XANALMOVE             =   20
Constants.YANALMOVE             =   21

Constants.XANALMOVE2             =   22
Constants.YANALMOVE2             =   23

Constants.KEY_FIRE				=	24

Constants.VIBRATESTRENGTH		=	1.0
Constants.VIBRATEDURATION		=	0.5

Constants.PIXELCELLWIDTH		=	64
Constants.PIXELCELLHEIGHT		=	64


Constants.USEKEYASTEXT			= 	false


Constants.SFX_VOLUME			=	1.0
Constants.DEFAULTFADE_DURATION	=	2.0		-- Default Fade time (secs) for music


Constants.SOUNDBANKRESOURCENAME	=	"arcadesoundfx"


Constants.kPI		=	3.1415926535897932384626433832795
Constants.kTwoPI	=	6.283185307179586476925286766559
Constants.kHalfPI	=	1.5707963267948966192313216916398
Constants.kDegToRad	=	0.017453292519943295769236907684886
Constants.kRadToDeg	=	57.295779513082320876798154814105

Constants.MISSILES_MAX	=	10
Constants.HMISSILES_MAX	=	10


end
