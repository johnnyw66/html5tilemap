-------------------------------------------------------------------------------
--<copyright>
--		VEEMEE LLP
--		Copyright (c) 2011
--		All Rights Reserved.
--</copyright>
-------------------------------------------------------------------------------

LoadLibrary("Xml")
local DUMMYNAME	=	"JOHNNYWILSON444"
local HOSTING	=	'@HOSTING@'		-- 'veemee','local' or 'affinity'

RenegadeScoreRequest = {	
		PHP_KEY		= 	"JPDFC10A9MXS8HHOMOUKYAR3",
		REQ_GAMEID	=	"renegadeops", --"renegadeops",		-- "audipiano"
		REQ_NONE 	= 	0,
		REQ_SET		= 	1,
		REQ_GET		= 	2,
		REQ_LEADERBOARD 			= 3,
		REQ_LEADERBOARD_ALLTIME 	= 3,
		REQ_LEADERBOARD_TODAY 		= 4,
		REQ_LEADERBOARD_YESTERDAY 	= 5,
	}

local HOSTSITE				=	(HOSTING == 'veemee' and "https://home.veemee.com/MetaScores/")  or 
								(HOSTING == 'local' and "http://192.168.1.49/" or "http://affinitystudios.com/MetaScores/")

--assert(false,HOSTSITE)

local SETSCOREURL			=	HOSTSITE.."setScore.php"
local GETSCORESURL			=	HOSTSITE.."getHighScores.php"
local GETSCORESTODAYURL		=	HOSTSITE.."getHighScoresToday.php"
local GETSCORESYESTERDAYURL	=	HOSTSITE.."getHighScoresYesterday.php"

-- curl -d "key=JPDFC10A9MXS8HHOMOUKYAR3&game_id=renegadeops&psnid=johnnyw66&score_1=1&score_2=0" http://www.affinitystudios.com/MetaScores/getHighScores.php
-- curl -d "key=JPDFC10A9MXS8HHOMOUKYAR3&game_id=renegadeops&psnid=johnnyw66&score_1=1&score_2=0" http://www.affinitystudios.com/MetaScores/setScore.php
--
-- curl -d "key=JPDFC10A9MXS8HHOMOUKYAR3&game_id=renegadeops&psnid=johnnyw66&score_1=1&score_2=0" https://home.veemee.com/MetaScores/setScore.php
-- curl -d "key=JPDFC10A9MXS8HHOMOUKYAR3&game_id=renegadeops&psnid=johnnyw66&score_1=1&score_2=0" https://home.veemee.com/MetaScores/getHighScores.php

local vmDbg = {
		
		Printf = function (me,...)
			local args	=	{...}	
			local frm	=	args[1]
			table.remove(args,1)
			local str = string.format(frm,unpack(args))
			--Logger.lprint(str)
		end,

		Errorf = function (me,...)
			local args	=	{...}	
			local frm	=	args[1]
			table.remove(args,1)
			local str = string.format(frm,unpack(args))
			Logger.lprint(str)
		end,

		Warningf = function (me,...)
			local args	=	{...}	
			local frm	=	args[1]
			table.remove(args,1)
			local str = string.format(frm,unpack(args))
			Logger.lprint(str)
		end,


}
	
-- RenegadeScoreRequest.REQ_GAMEID
-------------------------------------------------------------------------------
-- New 
--
-- Create a new score request object.
-------------------------------------------------------------------------------
function RenegadeScoreRequest:Create()
	local object = {
		--object variables
		scorePostContainer 		= {},
		scorePostData 			= {},
		scoreXMLData			= nil,
		className				=	'RenegadeScoreRequest',
		requestType				=	RenegadeScoreRequest.REQ_NONE,
	}
	
	object.scorePostContainer 	= MemoryContainer.Create( 1024 )
	object.scorePostData 		= HttpPostData.Create( object.scorePostContainer  )	
	setmetatable(object, {__index = RenegadeScoreRequest})
	return object
end

-------------------------------------------------------------------------------
-- Start Set
-- 
-- Initiate an upload of the score for the local player.
-------------------------------------------------------------------------------
function RenegadeScoreRequest:StartSet(p_score, isWinner)
	-- Cancel any outstanding requests
	self:CancelRequest()
	
	local localPerson = LocalPlayer.GetPerson()
	local localPSN = localPerson and Person.GetName(localPerson) or DUMMYNAME

	-- Some debug info
	vmDbg:Printf("StartSet :: UploadScores Called for player %s", tostring(localPSN))

	-- Clear the Post Data
	self.scorePostData = HttpPostData.Create( self.scorePostContainer )
	
	success = HttpPostData.AddValue( self.scorePostData, "psnid", localPSN )
	if not success then
		vmDbg:Errorf( "StartSet :: AddValue psnid FAILED!" )
		return false
	end
	
	success = HttpPostData.AddValue( self.scorePostData, "game_id",RenegadeScoreRequest.REQ_GAMEID )
	if not success then
		vmDbg:Errorf( "StartSet :: AddValue game_id FAILED!" )
		return false
	end
	
	success = HttpPostData.AddValue( self.scorePostData, "score_1", p_score )
	if not success then
		vmDbg:Errorf( "StartSet :: AddValue score_1 FAILED!" )
		return false
	end
	
	local won = 0
	if isWinner then won = 1 end
	vmDbg:Printf("StartSet :: Won = %s", tostring(won))
	success = HttpPostData.AddValue( self.scorePostData, "score_2", won )
	if not success then
		vmDbg:Errorf( "StartSet :: AddValue score_2 FAILED!" )
		return false
	end
	
	success = HttpPostData.AddValue( self.scorePostData, "sort_1", "DESC" )
	if not success then
		vmDbg:Errorf( "StartSet :: AddValue sort_1 FAILED!" )
		return false
	end
	
	success = HttpPostData.AddValue( self.scorePostData, "sort_2", "DESC" )
	if not success then
		vmDbg:Errorf( "StartSet :: AddValue sort_2 FAILED!" )
		return false
	end
	
	local success = HttpPostData.AddValue( self.scorePostData, "key", RenegadeScoreRequest.PHP_KEY )
	if not success then
		vmDbg:Errorf("StartSet :: AddValue key FAILED!")
		return false
	end

	success = HttpPostData.Finalize( self.scorePostData )	
	if not success then
		vmDbg:Errorf( "UploadScores :: Finalize FAILED!" )
		return false
	end

	self.scoreXMLData = Resource.Request( SETSCOREURL, "xml", self.scorePostData )	
	vmDbg:Warningf( "UploadScores :: Sending High Scores to Server" )
	
	self.requestType = RenegadeScoreRequest.REQ_SET

	return true
end

-------------------------------------------------------------------------------
-- Start Get
--
-- Initiate a download of the score. If bTop is true then it returns the top
-- player score, otherwise it returns the best score by the local player.
-------------------------------------------------------------------------------
function RenegadeScoreRequest:StartGet(bTop)
	-- Cancel any outstanding requests
	self:CancelRequest()

	local localPSN = "" 

	if bTop == false then
		local localPerson = LocalPlayer.GetPerson()
		localPSN = localPerson and Person.GetName(localPerson) or DUMMYNAME
	end

	-- Some debug info
	vmDbg:Warningf("StartGet :: StartGet Called for player %s", tostring(localPSN))

	-- Clear the Post Data
	self.scorePostData = HttpPostData.Create( self.scorePostContainer  )
	 
	local success = HttpPostData.AddValue( self.scorePostData, "key", RenegadeScoreRequest.PHP_KEY )
	if not success then
		vmDbg:Errorf("StartGet :: AddValue key FAILED!")
		return false
	end	
	
	success = HttpPostData.AddValue( self.scorePostData, "game_id", RenegadeScoreRequest.REQ_GAMEID)
	if not success then
		vmDbg:Errorf( "StartGet :: AddValue game_id FAILED!" )
		return false
	end

	success = HttpPostData.Finalize( self.scorePostData )	
	if not success then
		vmDbg:Errorf( "StartGet :: Finalize FAILED!" )
		return false
	end

	self.scoreXMLData = Resource.Request( GETSCORESURL, "xml", self.scorePostData )	
	vmDbg:Warninf( "StartGet :: Initiating get of High Scores from Server" )
	
	self.requestType = RenegadeScoreRequest.REQ_GET

	return true
end

-------------------------------------------------------------------------------
-- Start Leaderboard Get
--
-- 
-------------------------------------------------------------------------------
function RenegadeScoreRequest:StartLeaderboardGet(leaderboardRequestType)
	-- Cancel any outstanding requests
	self:CancelRequest()
	
	local localPerson = LocalPlayer.GetPerson()
	localPSN = localPerson and Person.GetName(localPerson) or DUMMYNAME
	
	-- Some debug info
	local str = "StartGet :: StartLeaderboardGet "
	if leaderboardRequestType == RenegadeScoreRequest.REQ_LEADERBOARD_ALLTIME then
		str = str .. " <<ALL TIME>> "
	elseif leaderboardRequestType == RenegadeScoreRequest.REQ_LEADERBOARD_TODAY then
		str = str .. " <<TODAY>> "
	elseif leaderboardRequestType == RenegadeScoreRequest.REQ_LEADERBOARD_YESTERDAY then
		str = str .. " <<YESTERDAY>> "
	end
	vmDbg:Printf(str .. "called for player " .. localPSN)
	
	local scoreSetUserDataURL = nil
	
	-- Set the URL for Setting the User Score
	if leaderboardRequestType == RenegadeScoreRequest.REQ_LEADERBOARD_ALLTIME then
		scoreSetUserDataURL = GETSCORESURL
	elseif leaderboardRequestType == RenegadeScoreRequest.REQ_LEADERBOARD_TODAY then
		scoreSetUserDataURL = GETSCORESTODAYURL
	elseif leaderboardRequestType == RenegadeScoreRequest.REQ_LEADERBOARD_YESTERDAY then
		scoreSetUserDataURL = GETSCORESYESTERDAYURL
	else
		--catchall
		scoreSetUserDataURL = GETSCORESURL
	end
	
	if scoreSetUserDataURL == nil then
		vmDbg:Printf("StartLeaderboardGet :: URL Invalid!!")
		return false
	end
	
	-- Clear the Post Data
	self.scorePostData = HttpPostData.Create( self.scorePostContainer  )
	
	success = HttpPostData.AddValue( self.scorePostData, "game_id", RenegadeScoreRequest.REQ_GAMEID )
	if not success then
		vmDbg:Errorf( "StartGet :: AddValue game_id FAILED!" )
		return false
	end
	 
	local success = HttpPostData.AddValue( self.scorePostData, "key", RenegadeScoreRequest.PHP_KEY )
	if not success then
		vmDbg:Errorf("StartLeaderboardGet :: AddValue key FAILED!")
		return false
	end	

	success = HttpPostData.Finalize( self.scorePostData )	
	if not success then
		vmDbg:Errorf( "StartLeaderboardGet :: Finalize FAILED!" )
		return false
	end

	self.scoreXMLData = Resource.Request( scoreSetUserDataURL, "xml", self.scorePostData )	
	vmDbg:Warningf( "StartLeaderboardGet :: Initiating get of High Scores from Server" )
	
	self.requestType = RenegadeScoreRequest.REQ_LEADERBOARD

	return true
end

-------------------------------------------------------------------------------
-- Is Ready
-- 
-- Returns TRUE if the score set or get is complete, FALSE otherwise.
-------------------------------------------------------------------------------
function RenegadeScoreRequest:IsReady()
	if self.requestType ~= RenegadeScoreRequest.REQ_NONE then
		if Resource.IsLoaded(self.scoreXMLData) then
			return true
		end
	end
	return false
end

-------------------------------------------------------------------------------
-- Cancel Request
-- 
-- Cancels an outstanding request.
-------------------------------------------------------------------------------
function RenegadeScoreRequest:CancelRequest()
	if self.requestType ~= RenegadeScoreRequest.REQ_NONE then
		if Resource.CancelRequest(self.scoreXMLData) then
			self.requestType = RenegadeScoreRequest.REQ_NONE
			return true
		end
	end
	return false
end


function RenegadeScoreRequest:CheckForResult()
	local rType = self.requestType
	if ( rType == RenegadeScoreRequest.REQ_SET) then
		return self:CheckForSet(),rType
		
	elseif (rType ~= RenegadeScoreRequest.REQ_NONE) then
		return self:CheckForGet(),rType
	else
		return nil
	end
end

-------------------------------------------------------------------------------
-- Check For Result
--
-- Returns the result of the Set or Get (or nil). This is a VMScore structure.
-------------------------------------------------------------------------------
function RenegadeScoreRequest:CheckForGet()
	if self:IsReady() then
		vmDbg:Printf( "CheckForResult :: Request Type = %s", tostring(self.requestType) )
		
		local retTable = {}
		local parser = Xml.Create()
		Xml.SetData ( parser, self.scoreXMLData )	
		local scoreNum = 0

		-- <scores>
		found = Xml.FindElement( parser, "leaderboard" )
		if found == false then
			vmDbg:Errorf( "CheckForResult :: Found <leaderboard> failed" )
			self.requestType = RenegadeScoreRequest.REQ_NONE
			return nil
		end			
		found = Xml.IntoElement( parser )			
		vmDbg:Printf( "CheckForResult :: Found <leaderboard>" )
		
		while Xml.FindNextElement( parser, "player" ) do
			scoreNum = scoreNum + 1
			found = Xml.IntoElement( parser )			
			if found == false then
				vmDbg:Errorf( "CheckForResult :: Failed to find player" )
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end
			
			found = Xml.FindElement( parser, "psn" )
			if found == false then
				vmDbg:Errorf( "CheckForResult :: Failed to find psn" )
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end
			local psnID = Xml.GetElementValueText( parser )
			if psnID == "" then					
				vmDbg:Errorf( "CheckForResult :: PSNID was empty, returning nil")
		--		self.requestType = RenegadeScoreRequest.REQ_NONE
		--		return nil
				-- Fudge until veemee fixed their table
				psnID	=	"BAD_PSNID"
			end
			
			found = Xml.FindElement( parser, "score_1" )
			if found == false then
				vmDbg:Printf( "CheckForResult :: Failed to find score_1" )
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end
			local score = Xml.GetElementValueText( parser )
			if score == "" then					
				vmDbg:Errorf( "CheckForResult :: Score was empty, returning nil")
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end

			found = Xml.FindElement( parser, "score_2" )
			if found == false then
				vmDbg:Errorf( "CheckForResult :: Failed to find score_2" )
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end
			
			local wins = Xml.GetElementValueText( parser )
			vmDbg:Warningf( "CheckForGet :: %s) %s, %s, %s", tostring(scoreNum), tostring(psnID), tostring(score), tostring(wins))
			retTable[scoreNum] = {psnid = psnID, score = score, wins = wins}
			Xml.OutOfElement( parser )
		end
		self.requestType = RenegadeScoreRequest.REQ_NONE
		return retTable
	end
	return nil
end		


function RenegadeScoreRequest:CheckForSet()
	if self:IsReady() then
		vmDbg:Printf( "CheckForResult :: Request Type = %s", tostring(self.requestType) )
		
		local retTable = {}
		local parser = Xml.Create()
		Xml.SetData ( parser, self.scoreXMLData )	
		local scoreNum = 0

		-- <scores>
		found = Xml.FindElement( parser, "score" )
		if found == false then
			vmDbg:Errorf( "CheckForResult :: Found <score> failed" )
			self.requestType = RenegadeScoreRequest.REQ_NONE
			return nil
		end			
		found = Xml.IntoElement( parser )			
		vmDbg:Printf( "CheckForResult :: Found <score>" )
		
		while Xml.FindNextElement( parser, "player" ) do
			scoreNum = scoreNum + 1
			found = Xml.IntoElement( parser )			
			if found == false then
				vmDbg:Printf( "CheckForResult :: Failed to find player" )
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end
			
			found = Xml.FindElement( parser, "psn" )
			if found == false then
				vmDbg:Errorf( "CheckForResult :: Failed to find psn" )
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end

			local psnName = Xml.GetElementValueText( parser )
			if psnName == "" then					
				vmDbg:Errorf( "CheckForResult :: PSN was empty, returning nil")
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end

			found = Xml.FindElement( parser, "psnid" )
			if found == false then
				vmDbg:Printf( "CheckForResult :: Failed to find psnid" )
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end
			local psnID = Xml.GetElementValueText( parser )
			if psnID == "" then					
				vmDbg:Errorf( "CheckForResult :: PSNID was empty, returning nil")
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end

			
			found = Xml.FindElement( parser, "score_1" )
			if found == false then
				vmDbg:Errorf( "CheckForResult :: Failed to find score_1" )
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end
			local score = Xml.GetElementValueText( parser )
			
			if score == "" then					
				vmDbg:Errorf( "CheckForResult :: Score was empty, returning nil")
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end

			found = Xml.FindElement( parser, "score_2" )
			if found == false then
				vmDbg:Errorf( "CheckForResult :: Failed to find score_2" )
				self.requestType = RenegadeScoreRequest.REQ_NONE
				return nil
			end
			
			local wins = Xml.GetElementValueText( parser )
			vmDbg:Warningf( "CheckForSet :: %s) %s, %s, %s", tostring(scoreNum), tostring(psnID), tostring(score), tostring(wins))
			retTable[scoreNum] = {psnname = psnName, psnid = psnID, score = score, wins = wins}
			Xml.OutOfElement( parser )
		end
		self.requestType = RenegadeScoreRequest.REQ_NONE
		return retTable
	end
	return nil
end
