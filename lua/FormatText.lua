-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not FormatText then
--[[
 Main Function of interest is FormatText.BuildFormattedLineList(renderer,str,maxWidth)
renderer is a PS3 object - (pass nil for character formatting)
str is string you want to format,
maxWidth is the pixel width limit 

Returns  lines array (table),Max Pixel Width ,Min Pixel Width ,wordList array
lines have two members - 'line' - the String and 'size' the pixel width of that line - 

See FormatText.Test() - for an example on how to use

Requirements: For PS3 Renderering - we need the 'Renderer' library to be loaded.

John


]]


FormatText = {}
FormatText.fontHSize = 1 ;		-- Used to Format 'Character' strings
FormatText.fontVSize = 1 ;		-- Used to Format 'Character' strings

	
	string.startsWith = function(str,comp)
       	return str:byte(1) == comp:byte(1)
    end
    
	string.removePara = function(str,rem)
	  	local nw,num = string.gsub(str,rem or "@","") 
		return nw
	end
	
	function FormatText.Split(str, pat)

   		local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   		local fpat = "(.-)" .. pat
   		local last_end = 1
   		local s, e, cap = str:find(fpat, 1)
   		while s do
      		if s ~= 1 or cap ~= "" then
	 			table.insert(t,cap)
      		end
      		last_end = e+1
      		s, e, cap = str:find(fpat, last_end)
   		end
   		if last_end <= #str then
      		cap = str:sub(last_end)
      		table.insert(t, cap)
   		end
   		return t
	end

	function FormatText.trim (s)
	      return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
	end

	
	function FormatText.GetPixelStringSize(renderer,str)
		if (renderer ~= nil) then
			return renderer:GetTextSize(str):X()
		else
			return str:len()*FormatText.fontHSize;
		end
	end


	function FormatText.GetFontHeight(renderer,str)
		if (renderer) then
            -- Font Height is not dependent on String
			return renderer:GetTextSize(str or " "):Y() ;
		else
			return FormatText.fontVSize ;
		end
	end

	function FormatText.GetMinMax(renderer,str)
		local psize ;
		local maxw = 0 ;
		local minw = 9999999 ;
		local wordList = FormatText.Split(str," ") ;
		for index,word in ipairs(wordList) do
			psize = FormatText.GetPixelStringSize(renderer,word) ;
			if (psize > maxw) then
				maxw = psize ;
			end
			if (psize <= minw) then
				minw = psize ;
			end
		end
		return minw,maxw,wordList
	end
	
	function FormatText.BuildFormattedLineList(renderer,str,maxWidth)
		local lines={}
		local wordList = FormatText.Split(str," ")
		local line="" ;
		local ln,psize ;
		local maxw = 0 ;
		local minw = 9999999 ;

		for index,word in ipairs(wordList) do
			if (word:startsWith("@") or FormatText.GetPixelStringSize(renderer,line..word:removePara()) > maxWidth) then
				-- output current line so far    
				ln = FormatText.trim(line) ;
				psize = FormatText.GetPixelStringSize(renderer,ln) ;
				
				if (psize > 0) then
					if (psize > maxw) then
						maxw = psize ;
					end
					if (psize < minw) then
						minw = psize ;
					end
					table.insert(lines,{line=ln,size=psize}) ;
				end
				line = word.." " ;
			else
				line = line..word.." " ;
			end	
		end
		
		ln = FormatText.trim(line) ;
		psize = FormatText.GetPixelStringSize(renderer,ln) ;
		
		if (psize > 0) then
			if (psize > maxw) then
				maxw = psize ;
			end
			if (psize < minw) then
				minw = psize ;
			end
			table.insert(lines,{line=ln,size=psize}) ;
		end
		
		return lines,minw,maxw,wordList  ;
	end


	function FormatText.FormatToScreen(renderer,text,screenWidth,screenHeight)
	
	
		local minSize,maxSize,words = FormatText.GetMinMax(renderer,text)	
		--print("Word Count is ",#words," Min/Max ",minSize,maxSize)
		local lines,minWidth,maxWidth,wordList = FormatText.BuildFormattedLineList(renderer,text,screenWidth)
		
--		for index,lineinfo in pairs(lines) do
--			print("<"..lineinfo.line..">".." Size = "..lineinfo.size) ;
--		end
		
		local fh				=	FormatText.GetFontHeight(renderer)
		local numLinesPerPage	=	math.floor(screenHeight/fh)
		local numberOfPages		=	math.ceil(#lines/numLinesPerPage)
		
		
		local formattedpages = {}
		local pageNumber = 1
		local cPage		 = {}
		formattedpages[pageNumber]	=	cPage
			
		for idx,lineinfo in pairs(lines) do
			table.insert(cPage,lineinfo.line:removePara())
    		if ((idx - 1) % numLinesPerPage == (numLinesPerPage - 1)) then
				pageNumber = pageNumber + 1
				cPage	=	{}
				formattedpages[pageNumber] = cPage
			end
		end
		
		return formattedpages
		
	end
	

	function FormatText.Test(renderer)
	
		local helpText = "As the highly influential ConservativeHome points out today, in the first edition of their conference newspaper, there are 4000 of we party members here in Manchester, each of whom has paid around £700 to attend. There are 7000 delegates from the media, and lobby groups. @ @ @ @The lobbyists are on their way to destroying conference: they take over fringe events, prevent open debate and push, push, push the line their employers pay them to articulate. Try speaking plain Tory at a Stonewall meeting on 'Diversity' and see how far you get."

		local formattedpages = FormatText.FormatToScreen(renderer,helpText,28,10)

		for pageNumber,page in pairs(formattedpages) do
			print(">>>>>START OF PAGE ",pageNumber)
			for linenum,line in pairs(page) do
					print(linenum,line)
			end
			print("<<<<<END OF PAGE ",pageNumber)
		end
		
	end
	
	-- FormatText.Test()
	
end
	
