-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not Logger then
Logger 				= {}
Logger.debug 		= false
Logger.className	="Logger"
Logger.m_Int 		= {} 
Logger.m_Int[0]		="Hello World"
Logger.console		= g_console

	function Logger.Init(console)
		Logger.console = console 
	end
	
	function Logger.lprint(s)
		if (Logger.console) then
			Logger.console:print(s)
		else 
			print(s)
		end
	end
	
	function Logger.error(s)
		Logger.lprint("****ERROR****"..s) 
	end

	function Logger.warning(s)
		Logger.lprint("****WARNING****"..s) 
	end

	function Logger.Print(...)
		Logger.print("Update in Slots") 

		if (arg.n == 2) then
			if( slot >= 0 and slot < 10 ) then
				m_Int[ slot ] = value
			end
		elseif (arg.n == 3) then
			if( slot >= 0 and slot < 10 ) then
				m_Int[ slot ] = LuaUtils.Int( 0.5 + scale * value )
			end
		end
	end


	function Logger.debugON()
		Logger.debug = true 
	end

	function Logger.debugOFF()
		Logger.debug = false 
	end

    function Logger.print(...)
		if (Logger.debug) then
			local str = Logger.buildString(unpack(arg))
    		Logger.printstr(str)
		end
    end


    function Logger.buildString(...)
             local i
			 local str = "Logger:"
             for i=1, arg.n  do
                 -- str= str.."("..i..")"
                 local t = type(arg[i])

                 if (arg[i] == nil) then
 		          str= str.."=nil param "

      			elseif (t == "string") then

                    str= str..arg[i]..", "

               	elseif (t == "number") then

                      if (string.find(arg[i],"%d*%.%d+") ~= nil) then
  		          		str= str.."float="..arg[i]..", "
                      else
   		          		str= str.."int="..arg[i]..", "
                      end
              	elseif (t == "boolean") then

                    if (arg[i] == true) then
 		          		str= str.."true, "
                    else
 		          		str= str.."false, "
                    end

             	elseif (t == "table") then

                    local cn = arg[i].className 
                    if (cn == nil) then
 		          		str= str.."className=Unknown, "
                    else
 		          		str= str.."className="..cn..", "
                    end

                 end  -- if
             end -- for
			return str 

    end -- function


	function Logger.printstr(mystr)
		Logger.lprint(mystr)
	end


	function Logger.setSlot(slot,pText)
		Logger.m_Int[slot] = pText 
	end

	function Logger.Render( game )
		Logger.print("Logger.Render - Slots")

		local yStart = 180
		local fHgt = 20 
		i = 0 

		for i,v in ipairs(Logger.m_Int) do
			if (v ~= nil) then
			--	print("Logger.Render["..i.."]"..Logger.m_Int[i])
			end
		end

	end
	
	Logger.print("Including Logger") 

-- End of class
end
