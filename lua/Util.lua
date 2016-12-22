-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Util) then
Util = {}
Util.className 			= "Util"

function Util._ModifyLocaleText(text)
	local modtext =	text
	string.gsub(text,"_LOCALE%W*[(]([^)]+)[)]",
		function(txt) 
			modtext = Locale and Locale.GetLocaleText and Locale.GetLocaleText(txt) or txt 
		end)
		
	return modtext
end

function Util.MemoryDebug()
	if (false) then
	debug.sethook (
		function()
			local fn = debug.getinfo(2,"n").name
			print("Function Name = "..fn)	
		end
	, "cr")
	end
end

function Util.Info(str)
	local fn = debug.getinfo(2,"n").name
	Logger.lprint(string.format("%s:Function Name = %s",(str or ""),fn))	
end

function Util.BuildLuaTable(text)
	local modtext 	=	text:gsub("^%s*(.-)%s*$", "%1")
	local tbl		=	{}
	

		string.gsub(modtext,"([A-Za-z_0-9]+)%W*[=][ ]*([^,}]+)",
			function(var,val)
			
				local ch = string.byte(val)
				if (ch == string.byte("'") ) then
					--val = string.gsub(val, "'", "", 2)
				elseif (ch <= string.byte('9')) then
					-- only store 'value = number' pairs
					val = tonumber(val)	
					tbl[var]	=	val
				else

				end
			end)

	return tbl
end

function Util.ShowIcon(currenttime,starttime,duration,phase)
	local time				=	currenttime - starttime
	local nTime				=	math.min(1,time/duration)
	local startbeat			=	0.01
	local endbeat			=	4
	local numbeatspersec 	=	nTime < 0.75 and startbeat or startbeat - (startbeat - endbeat)*nTime
	local f 				=	numbeatspersec*0.5
	return (math.sin(time*6*f+(phase or 0)) > 0) 
end


end
