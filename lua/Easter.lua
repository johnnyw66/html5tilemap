--  Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Easter) then

Easter = {}
Easter.enabled	=    not Constants.RELEASE
Easter.debug    =    true

Easter.eggs  = 
{
	
	{ compare = {
 		Constants.KEY_UP,
 		Constants.KEY_DOWN,
 		Constants.KEY_UP,
 		Constants.KEY_DOWN,
 		Constants.KEY_UP,
 		Constants.KEY_DOWN,
 		Constants.KEY_UP,
 		Constants.KEY_DOWN,
 		Constants.KEY_LEFT,
 		Constants.KEY_LEFT,
 		Constants.KEY_RIGHT,
		},state = 1,callback = nil,lastkey = -1},

		{ compare = {
	 		Constants.KEY_UP,
	 		Constants.KEY_UP,
	 		Constants.KEY_UP,
	 		Constants.KEY_UP,
			},state = 1,callback = nil,lastkey = -1},

		{ compare = {
		 		Constants.KEY_R1,
		 		Constants.KEY_R2,
		 		Constants.KEY_L2,
		},state = 1,callback = nil,lastkey = -1},



}

	function Easter.Init(callback)
		for _,egg in pairs(Easter.eggs) do
			Easter.InitEgg(egg,callback)
		end
		
	end
	
	function Easter.InitEgg(egg,callback)
		egg.callback = callback
   		egg.lastkey	=	-1 
    	Easter.RestartEgg(egg) 


	end
	
	function Easter.RestartEgg(egg)
   		egg.state	=	1
	end
	
	function Easter.Compare(egg,key,idx)
		if (Easter.enabled and egg.compare[egg.state] and egg.compare[egg.state] == key) then
			egg.state = egg.state + 1
			if (egg.state > #egg.compare) then
				egg.granted = true
				if (egg.callback) then
					egg.callback(idx)
				end
				Easter.RestartEgg(egg)
			end
		else
			Easter.RestartEgg(egg)
		end
		
	end
	
	function Easter.Input(key)
		
		for idx,egg in pairs(Easter.eggs) do 
			egg.lastkey = key
			Easter.Compare(egg,key,idx)
    	end

	end
	
	function Easter.Render(renderHelper)
        if (Easter.debug) then
		  for idx,egg in pairs(Easter.eggs) do
   		       RenderHelper.DrawText(renderHelper,string.format("Easter Egg STATE %d  KEY %d GRANTED %s",egg.state,egg.lastkey,(egg.granted and 'YES') or 'NO'),700,20+20*idx)
		  end
        end
		
	end
	
	
end

