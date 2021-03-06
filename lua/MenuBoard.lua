-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not MenuBoard then

MenuBoard					=	{ }
MenuBoard.className			=	"MenuBoard" 
MenuBoard.currentHelpPage	=	1
MenuBoard.numHelpPages		=	1

local HELPTEXT_KEY			=	"HELP_TEXT"


local MenuBoardWidth    	=   1024
local MenuBoardHeight   	=   720
local helpBoardWidth    	=   300
local helpBoardHeight   	=   300
local displayScores			=	false
local displayHelp			=	false
local helpText				=	"nil"	
local menuSM				=	nil


local sizeScoreHeadingFont,sizeScoreEntryFont

local function causeEvent(event)
	if (MenuBoard.eventcallback) then
		MenuBoard.eventcallback(event)
	end
end

local menuStateMachineTable	=	{
	states		=
	{	

		sendscore	=	{
			on_entry	=	function(obj,time)
								Logger.lprint("Enter sendscore.........................")
								displayHelp		=	false
								displayScores	=	false
								MenuBoard.Request(	function(tbl)
														displayScores	=	true
													end,
													obj:GetScore()	
													)
							
							end,
							
				on_update 	=	function(obj,time,dt)
								end,
				on_exit		=	function(obj,time)
								end,

			},				
			

		initmenus	=	{
			on_entry	=	function(obj,time)
								Logger.lprint("Enter initmenus.........................")
								displayHelp		=	false
								displayScores	=	false
								if (true) then
								MenuBoard.Request(	function(tbl)
													end,
													nil
													)
								end
								
							end,
			on_update 	=	function(obj,time,dt)
							end,
			on_exit		=	function(obj,time)
							end,
		},

		mainmenu	=	{
			on_entry	=	function(obj,time)
							end,
			on_update 	=	function(obj,time,dt)
							end,
			on_exit		=	function(obj,time)
							end,
		},
		
		instructionmenu	=	{
			on_entry	=	function(obj,time)
								displayHelp	=	true
								MenuBoard.currentHelpPage	=	1
								
							end,
			on_update 	=	function(obj,time,dt)
								if (obj and obj.KeyHit) then
								 	if (obj:KeyHit(Constants.KEY_RIGHT)) then
										MenuBoard.currentHelpPage = math.min(MenuBoard.currentHelpPage + 1,MenuBoard.numHelpPages)
										menuSM:ResetTime()
									elseif (obj:KeyHit(Constants.KEY_LEFT)) then
										MenuBoard.currentHelpPage = math.max(MenuBoard.currentHelpPage - 1,1)
										menuSM:ResetTime()
									end
									
								end
							end,
			on_exit		=	function(obj,time)
								displayHelp	=	false
							end,
		},
		
		scoremenu	=	{
			on_entry	=	function(obj,time)
								displayScores	=	true
								displayHelp		=	false
							end,

			on_update 	=	function(obj,time,dt)
							end,

			on_exit		=	function(obj,time)
								displayScores	=	false
							end,
		},


		allmissionscompleted	=	{
			on_entry	=	function(obj,time)
								causeEvent("AllMissionsCompleted")
							end,

			on_update 	=	function(obj,time,dt)
							end,

			on_exit		=	function(obj,time)

							end,
		},
		
	},
	transitions	=	{
		initmenus	=	{
			transitions	=	{
--				{'scoremenu',function(obj,time) return MenuBoard.table end},
--				{'instructionmenu',function(obj,time) return time > 10 end},
				{'mainmenu',function(obj,time) return true end},
			}
		},
		mainmenu	=	{
			transitions	=	{
				{'instructionmenu',function(obj,time) return (obj and obj.KeyHit and obj:KeyHit(Constants.KEY_SELECT)) or time > 15 end},
			}
		},
		
		instructionmenu	=	{
			transitions	=	{
--				{'instructionmenu',function(obj,time) return obj and obj.KeyHit and obj:KeyHit(Constants.KEY_DOWN) end},
				{'scoremenu',function(obj,time) return MenuBoard.table and time > 10 end},
--				{'scoremenu',function(obj,time) return obj and obj.KeyHit and obj:KeyHit(Constants.KEY_SELECT) end},
--				{'mainmenu',function(obj,time) return obj and obj.KeyHit and obj:KeyHit(Constants.KEY_SELECT) end},
			}
		},
		
		scoremenu	=	{
			transitions	=	{
--				{'scoremenu',function(obj,time) return obj and obj.KeyHit and obj:KeyHit(Constants.KEY_UP) end},
--				{'scoremenu',function(obj,time) return obj and obj.KeyHit and obj:KeyHit(Constants.KEY_DOWN) end},
				{'instructionmenu',function(obj,time) return (obj and obj.KeyHit and obj:KeyHit(Constants.KEY_SELECT)) or (time > 10) or (not MenuBoard.table) end},
			}
		},
		
		
		allmissionscompleted
				=	{
					transitions	=	{
						{'scoremenu',function(obj,time) return (obj and obj.KeyHit and obj:KeyHit(Constants.KEY_SELECT)) or (time > 10)  end},
					}
				},
		
		sendscore = {
		
					transitions	=	{
						{'scoremenu',function(obj,time) return displayScores end},
					}
		
		},
		
	}
	

}

	GameHelper	=	{}
	function GameHelper.Create(padid,scoreManager,assetLoaderHelper)
		local gamehelper	=	{
			padid			=	padid,
			scoreHelper		=	scoreManager,
			assetHelper		=	assetLoaderHelper,
			className 	=	'GameHelper',
		}
		
		setmetatable(gamehelper,{ __index = GameHelper })
		assert(scoreManager and scoreManager.GetScore,'No ScoreHelper or ScoreHelper.GetScore function')
		return gamehelper
		
	end
	
	function GameHelper.KeyHit(gamehelper,keyid)
		local controller	=	gamehelper.controller or Pad.GetPad(gamehelper.padid)
--		gamehelper.controller = controller
		return Pad.WasJustPressed(controller,keyid)
	end

	function GameHelper.GetScore(gamehelper)
		if (gamehelper.scoreHelper and gamehelper.scoreHelper.GetScore) then
			return gamehelper.scoreHelper.GetScore()
		end
		assert(false,'GameHelper:NO SCOREHELPER')
		return nil
	end

	
	function MenuBoard.Init(renderHelper,scoreHelper,eventcallback)

		helpText			=	Locale and Locale.GetLocaleText(HELPTEXT_KEY) or "WHAT?"
		MenuBoard.request	=	nil
		MenuBoard.eventcallback	=	eventcallback or function()  end
		MenuBoard.ResetCurrentPage()

        RenderHelper.SetFont(renderHelper,FONT_MENU_INSTRUCTIONS)
        RenderHelper.SetFontScale(renderHelper,1,1)

		MenuBoard.HelpInfo 			=	FormatText.FormatToScreen(renderHelper,helpText,helpBoardWidth,helpBoardHeight)
		MenuBoard.numHelpPages		=	#MenuBoard.HelpInfo
		--assert(false,MenuBoard.numHelpPages..":"..#MenuBoard.HelpInfo[1])
		MenuBoard.currentHelpPage	=	1
		
		menuSM						=	FStateMachine.Create(GameHelper.Create(1,scoreHelper))
		
		menuSM:Initialise(menuStateMachineTable.states)
		menuSM:Initialise(menuStateMachineTable.transitions)
		
		menuSM:SetState('initmenus')
	
   		RenderHelper.SetFont(renderHelper ,FONT_MENU_SCOREHEADING)
  		sizeScoreHeadingFont = RenderHelper.GetTextSize(renderHelper ,"W")

    	RenderHelper.SetFont(renderHelper ,FONT_MENU_SCOREENTRY)
    	sizeScoreEntryFont = RenderHelper.GetTextSize(renderHelper ,"W")

    
							
	end

	function MenuBoard.SendScore()
		if (menuSM) then
			menuSM:SetState('sendscore')
		end

	end
		
	function MenuBoard.ShowScore()
		if (menuSM) then
			menuSM:SetState('scoremenu')
		end

	end
		
	function MenuBoard.ShowAllMissionsCompleted()
		if (menuSM) then
			menuSM:SetState('allmissionscompleted')
		end

	end
		

--	function MenuBoard.SendScore(cb,score)
--		MenuBoard.Request(cb,score)
--	end
	

	-- Call function in two ways - with a score or without score parameter.
	-- cb - Callback function - when Data has been retrieved from website
	-- score - to set a score, or nil to retrieve 'All Time' leaders
	
	function MenuBoard.Request(cb,score)
	
		MenuBoard.request						=	RenegadeScoreRequest.Create()
		MenuBoard.callBack						=	cb 	or 	function(tbl)  
																Logger.lprint('DUMMY MenuBoard.Request CALLBACK '..MenuBoard._TableToString(tbl or {})) 
															end

		if (MenuBoard.request) then
			if (score) then
				MenuBoard.request:StartSet(score, true)
			else
				MenuBoard.request:StartLeaderboardGet(RenegadeScoreRequest.REQ_LEADERBOARD_ALLTIME)
			end
		end
	end


	function MenuBoard._TableToString(sTable)
		local tbl	=	{}
		
		for idx,entry in pairs(sTable) do
			local str = string.format("PSNID %s SCORE %d WINS %s",entry.psnid or 'NIL ID',entry.score or -1,entry.wins or 'NIL WINS')
			table.insert(tbl,str)
		end
		
		return table.concat(tbl,"\n")
	end
	
	function MenuBoard.Update(dt,playing)
	--	Logger.lprint("MenuBoard.Update -- "..(displayHelp and ' Display Help ' or ' ? ')..(displayScores and 'Display Scores' or ' ?'))
		isPlaying	=	playing
		menuSM:Update(dt)
	
		if (MenuBoard.request and MenuBoard.request:IsReady()) then
			local table,ttype = MenuBoard.request:CheckForResult()
			if (table and ttype ~= RenegadeScoreRequest.REQ_SET) then
				MenuBoard.table	=	table
			end
			
			if MenuBoard.callBack	then
				MenuBoard.callBack(table)	
			end
			MenuBoard.request	=	nil
		end
		
	end
	

	function MenuBoard.Render(renderHelper)
		--if (MenuBoard.table) then
		--	RenderHelper.DrawText(renderHelper,"SCORE BOARD ",100,200,2,{red=128,green=0,blue=0,alpha=128},"left","bottom")
		--	local fh = 16
		--	for idx,entry in pairs(MenuBoard.table) do
		--		local str = string.format("PSN %s PSNID %s SCORE %d WINS %s",entry.psnname or 'NIL NAME',entry.psnid or 'NIL ID',entry.score or -1,entry.wins or 'NIL WINS')
		--		RenderHelper.DrawText(renderHelper,str,100,220+fh*idx,1,{red=128,green=0,blue=0,alpha=128},"left","bottom")
		--	end
		--end


		
		if (menuSM) then

		 	if (MenuBoard.debug) then
				RenderHelper.DrawText(renderHelper,"SCORE BOARD ",100,200,1,{red=128,green=0,blue=0,alpha=128},"left","bottom")
			end
			
			local state = menuSM:GetCurrentState()
			--Logger.lprint("STATE = "..state)
			if (state == 'mainmenu') then
				MenuBoard.DisplayIntroScreen(renderHelper)
				MenuBoard.DisplayDebugText(renderHelper,"INTRO SCREEN")

			elseif (state == 'instructionmenu') then
				MenuBoard.DisplayInstructions(renderHelper,displayHelp)
				MenuBoard.DisplayDebugText(renderHelper,"INSTRUCTION SCREEN")
				
			elseif (state =='scoremenu') then
				MenuBoard.DisplayLeaderBoard(renderHelper,displayScores)
				MenuBoard.DisplayDebugText(renderHelper,"SCORE SCREEN")
			
			elseif (state =='allmissionscompleted') then
				MenuBoard.DisplayWellDoneScreen(renderHelper,displayScores)
			end
		end

	end
 	
	
	function MenuBoard.Render2(renderHelper)
	end
	

	function MenuBoard.DisplayDebugText(renderHelper,debugText,xpos,ypos)
		if (not @RELEASE@) then
			local valign		=	"center"
    		local halign		=	"center"
        	RenderHelper.SetFont(renderHelper,FONT_MENU_DEFAULT)
   			RenderHelper.DrawText(renderHelper,debugText,xpos or 512,ypos or 80,1,{red=127,green=0,blue=0,alpha=127},halign,valign)
		end
	end

	function MenuBoard.DisplayIntroScreen(renderHelper)
		RenderHelper.DrawImage(renderHelper,"titleBKG",512,360)
		
	end


	function MenuBoard.DisplayWellDoneScreen(renderHelper)
		RenderHelper.DrawImage(renderHelper,"backgroundBKG",512,360)
		MenuBoard.DisplayDebugText(renderHelper,"WELL DONE ALL MISSIONS COMPLETED",512,600)
	end

	function MenuBoard.DisplayInstructions(renderHelper,display)
			if (display) then
				
				if (isPlaying) then
				
				end
				
				RenderHelper.DrawImage(renderHelper,"backgroundBKG" or "instructionsBKG",512,360)
			
	            local fontScale		=   1
	            local fontColour	=   {red = 127,green = 0,blue = 0, alpha = 127}
	        	local xstartpos 	=	1024/2
				local ystartpos		=	(720-helpBoardHeight)/2
	            RenderHelper.SetFont(renderHelper,FONT_MENU_INSTRUCTIONS)
	            RenderHelper.SetFontScale(renderHelper,fontScale,fontScale)
	
	            local lineSpace		=	RenderHelper.GetFontHeight(renderHelper)*1.00
	            local valign		=	"center"
	            local halign		=	"center"


				local page = MenuBoard.HelpInfo[MenuBoard.currentHelpPage or 1]	
	         	for row,text in pairs(page) do
					--Logger.lprint("TEXT "..row..":"..text)
	      		    RenderHelper.DrawText(renderHelper,text,xstartpos,ystartpos + lineSpace*(row - 1),fontScale,fontColour,halign,valign)
	            end
	
	           -- RenderHelper.DrawText(renderHelper," "..MenuBoard.currentHelpPage,20,40,fontScale,{red=127,green=127,blue=0,alpha=127},halign,valign)

	            RenderHelper.DrawText(renderHelper,MenuBoard.currentHelpPage.."/"..#MenuBoard.HelpInfo,xstartpos,
													ystartpos+helpBoardHeight+lineSpace,
													fontScale,
													{red=127,green=0,blue=0,alpha=127},halign,valign)

				if (MenuBoard.currentHelpPage > 1) then
	            	RenderHelper.DrawText(renderHelper,"<",xstartpos-64,
													ystartpos+helpBoardHeight+3*lineSpace,
													fontScale,
													{red=127,green=0,blue=0,alpha=127},halign,valign)
				end
														
				if (MenuBoard.currentHelpPage < #page) then
	            	RenderHelper.DrawText(renderHelper,">",xstartpos+64,
													ystartpos+helpBoardHeight+3*lineSpace,
													fontScale,
													{red=127,green=0,blue=0,alpha=127},halign,valign)
					
				end

			end

		end

	function MenuBoard.DisplayLeaderBoard(renderHelper,display)

		if (MenuBoard.table and display) then
			RenderHelper.DrawImage(renderHelper,"backgroundBKG" or "scoresBKG",512,360)


	--          	RenderHelper.DrawText(renderHelper,"Size of Board "..#Game.leaderBoard,MenuBoardWidth/2,100)
	--          	RenderHelper.DrawText(renderHelper,Locale.GetLocaleText("HIGH SCORES"),MenuBoardWidth/2,120)

    			local limit 				= 	10

	            local fh   					=	1.0*Vector4.Y(sizeScoreEntryFont)
	            local cw   					=	Vector4.X(sizeScoreEntryFont)

	            local score_width       	=	6*cw
	            local psnid_width       	=	20*cw
	            local position_width    	=	8*cw
	            local titleIconHeight   	=	256

	            local total_width         	=	position_width + psnid_width + score_width
	            local xpos                 	=	(MenuBoardWidth - total_width)/2
	            local yBoardStart          	=	(720-limit*fh)/2 + 12 - 0  
	
				-- (MenuBoardHeight + titleIconHeight  - #Game.leaderBoard*fh)/2
				local scoreBoxHeadingHeight	=	1.2*Vector4.Y(sizeScoreHeadingFont)

	            local yHeaderStart      	=	yBoardStart - 1.2*scoreBoxHeadingHeight



	            local titleColour			=	{red = 119,green = 63, blue = 3, alpha = 127}   -- not used?
	            local headerScale       	=	1
	            local headerColour      	=   {red = 110,green = 110,blue = 110, alpha = 127}

	            --  Horizontal Positions
	            local scoreTableStart   	=	1024/2 - (512-16)/2
	            local scoreTableWidth   	=   512 - 16
	            local tableMidx         	=   scoreTableStart + scoreTableWidth / 2
	            local rankPos           	=   scoreTableStart + 0.10*scoreTableWidth
	            local namePos           	=   scoreTableStart + 0.20*scoreTableWidth
	            local scorePos          	=   scoreTableStart + scoreTableWidth - 0.05*scoreTableWidth
	            local scoreLineHeight  		=   fh
	            local scoreBoxHeight  		=   1.2*fh

	            local textColour    = {red = 42,green = 42,blue = 42, alpha = 127}
	            local entryColour2  = {red=110,green=110,blue=110,alpha=127}
	            local entryColour1  = {red = 102,green=102,blue=102,alpha=127}


	            -- Draw Title Box
	            -- Draw Column Heading Bar

	     	      RenderHelper.SetFont(renderHelper,FONT_MENU_SCOREHEADING)
	              RenderHelper.DrawRect(renderHelper,scoreTableStart,yHeaderStart,scoreTableWidth,scoreBoxHeadingHeight,entryColour1)
				  local yHeaderBottom 	=	yHeaderStart + scoreBoxHeadingHeight 
	           	  RenderHelper.DrawText(renderHelper,Locale.GetLocaleText("RANK"),rankPos,yHeaderBottom,headerScale,headerColour,"center","bottom")
	         	  RenderHelper.DrawText(renderHelper,Locale.GetLocaleText("NAME"),namePos,yHeaderBottom,headerScale,headerColour,"left","bottom")
	          	  RenderHelper.DrawText(renderHelper,Locale.GetLocaleText("SCORE"),scorePos,yHeaderBottom,headerScale,headerColour,"right","bottom")


	            RenderHelper.SetFont(renderHelper,FONT_MENU_SCOREENTRY)
				local start 		= (MenuBoard.GetCurrentPage() - 1)*limit

				for row = 1,limit do
					local entry = 	MenuBoard.table[start+row]
					if (entry) then	
						local yoff		=	yBoardStart + (row-1)*scoreBoxHeight
						local score 	= entry.score
						local position 	= row		--entry.position
						local psnID		= entry.psnid or '****'
	                	local col       =   (((row % 2) == 1) and entryColour1) or entryColour2
		              	RenderHelper.DrawRect(renderHelper,scoreTableStart,yoff,scoreTableWidth,scoreBoxHeight,col)

						local txtyoff	=	yoff + (scoreBoxHeight)/2 
		
						RenderHelper.DrawText(renderHelper,string.format("%02d",position),rankPos,txtyoff,1,textColour,"right","center")
		              	RenderHelper.DrawText(renderHelper,psnID,namePos,txtyoff,1,textColour,"left","center")
		              	RenderHelper.DrawText(renderHelper,score,scorePos,txtyoff,1,textColour,"right","center")
		              --	RenderHelper.DrawCircle(renderHelper,rankPos,txtyoff,4,textColour)
		
					end
				end

	        local score = ScoreManager.GetBestScore() 
	        local bsypos = (720 + 512)/2 + 40 - 8 -- yBoardStart + (limit + 1) * scoreLineHeight
	        local bsxpos = tableMidx --rankPos
	       	RenderHelper.DrawText(renderHelper,string.format("%s %d",Locale.GetLocaleText("YOUR BEST SCORE IS"),score),bsxpos,bsypos,1,textColour,"center","bottom")

		end


	        RenderHelper.SetFont(renderHelper,FONT_MENU_DEFAULT)
			RenderHelper.DrawText(renderHelper,"",0,0,1,{red=127,green=127,blue=127,alpha=127},"center","center")

	--		RenderHelper.DrawTextureScale(rHelper,"SEGAVT_DisplayTextBackground",1280/2,720/2+40,2,60)

		end

		function MenuBoard.GetNumberOfPages()
			local limit = 10
			local sizelb = (MenuBoard.table and #MenuBoard.table) or 0
			local numPages  =  math.max(1,math.modf((sizelb+limit-1)/ limit))
			return numPages
		end

		function MenuBoard.BumpPage()

			if (Game.currentPage >= MenuBoard.GetNumberOfPages()) then
				MenuBoard.currentPage = 1
			else
				MenuBoard.currentPage = MenuBoard.currentPage + 1
			end

		end

		function MenuBoard.GetCurrentPage()
			return MenuBoard.currentPage
		end

		function MenuBoard.ResetCurrentPage()
			MenuBoard.currentPage = 1
		end

	
end
