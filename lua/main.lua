-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt

if (not assert) then
	function assert(test,str)
		if (not test) then
			print(string.format("ASSERT - FAILED %s",str))
		end
	end
end

if (love) then
	function LoadLibrary(name)
		if (love.filesystem.exists( name..".lua" )) then
   				require(name)
		else
		
		end
	end
end



LoadLibrary("Resource")

LResource	=	{}

function LResource.Run(rName)
	Resource.Run(rName)
	Resource.Release(Resource.Find(rName))
end

LResource.Run("LoadLibs")

if (love) then
    g_USECONSOLE = true
	LResource.Run("emu")
end

LResource.Run("Logger")
LResource.Run("Game")   

local dtSample 	= 0
local dtTotal	=	0
AVERAGEDT		=	0.033

if (love) then
	_DIMX,_DIMY		=	love.graphics.getWidth(),love.graphics.getHeight()
else
	_DIMX,_DIMY		=	1024,720		-- Should be 1028,720! Causes Map Objects to misalign on X axis
end


	function getAverageDT()
		local dt = GetDeltaTime()
		dtTotal	 = dtTotal +  dt
		dtSample = dtSample + 1
		return dtTotal/dtSample
	end

	function Init()
   		Logger.lprint("Init")
		Game.Init(_DIMX,_DIMY)
    end


	function Update()
		local dt = getAverageDT()
		Game.Update(dt)
		if (not love) then
            Draw()
        end
   	end

     function Draw()
		Game.Render()
  	 end

	Init() 
	
