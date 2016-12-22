-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not ScoreManager then

ScoreManager							=	{ }
ScoreManager.className					=	"ScoreManager" 
ScoreManager.score						=	0
ScoreManager.multiplier					=	1
ScoreManager.bestscore					=	0

	function ScoreManager.Init(callback)
		ScoreManager.round		=	0
		ScoreManager.score		=	0
		ScoreManager.levelscore	=	0
		ScoreManager.multipiler	=	1
		ScoreManager.recordings	=	{}
		ScoreManager.callback 	= 	callback
		assert(callback,'ScoreManager.Init - NIL CALLBACK')
		
	end
	
	local function causeEvent(eventName)
		if (ScoreManager.callback) then
			ScoreManager.callback(eventName or 'unknownscoreEvent',ScoreManager.score)
		end
	end
	

	function ScoreManager.StartRound()
		ScoreManager.round		=	ScoreManager.round + 1
		ScoreManager.levelscore	=	0
		ScoreManager.recordings	=	{}
		causeEvent('StartRound')
	end
	
	function ScoreManager.Record(name)
		if (not ScoreManager.recordings[name]) then
			ScoreManager.recordings[name]	=	0
		end
		ScoreManager.recordings[name]	=	ScoreManager.recordings[name] + 1
	end
	
	function ScoreManager.GetTotalDestroyed()
		local total = 0
		for name,subtotal in pairs(ScoreManager.recordings) do
			total = total + subtotal
		end
		return total
	end

	function ScoreManager.GetRecord(name)
		return ScoreManager.recordings[name] or 0
	end
	

	
	function ScoreManager.GetRecords()
		--return {radar=14,tanks=22,helipads=4,zippy=220,oilbanks=44} 
		return ScoreManager.recordings
	end
	

	function ScoreManager.EnemyKilled(enemy)
		causeEvent('EnemyKilled')
		ScoreManager.AddScore(enemy.GetScore and enemy:GetScore() or 100)
	end

	function ScoreManager.XXXDeductScore(score)
		ScoreManager.score	=	ScoreManager.score - score
		if (ScoreManager.score < 0) then
			ScoreManager.score = 0
		end
	end
	
	function ScoreManager.AddScore(score,multiplier)
		local	amount		=	score*(multiplier or ScoreManager.multiplier)
		causeEvent("AddScore")
		
		ScoreManager.score	=	ScoreManager.score + amount
		ScoreManager.levelscore	=	ScoreManager.levelscore	+ amount

        if (ScoreManager.score > 9999999) then
            ScoreManager.score = 9999999
        end

        if (ScoreManager.levelscore > 9999999) then
            ScoreManager.levelscore = 9999999
        end

      --  GameLevels.ScoreHook({score = ScoreManager.GetScore(), wave = AlienManager.GetWave(), player = Game.player, bosses = BossManager.LiveRemaining()})

	end

	function ScoreManager.SetMultiplier(mult)
		ScoreManager.multiplier	=	mult
	end
	
	function ScoreManager.ResetMultiplier()
		ScoreManager.SetMultiplier(1)	
	end
	
	function ScoreManager.GetScore()
		return ScoreManager.score
	end

	function ScoreManager.GetBestScore()
		return ScoreManager.bestscore
	end

	function ScoreManager.SetBestScore(val)
		ScoreManager.bestscore	=	val
	end
	
	function ScoreManager.GetLevelScore()
		return ScoreManager.levelscore
	end
	
	function ScoreManager.GetScores()
		return ScoreManager.score,ScoreManager.levelscore
	end
	
	function ScoreManager.TallyUp()
	
		if (ScoreManager.score > ScoreManager.bestscore) then
			causeEvent("BestScore")
			ScoreManager.bestscore = ScoreManager.score
			return ScoreManager.score
		else
			return false
		end
	end
	
	function ScoreManager.RenderDebug(renderHelper)

    	RenderHelper.SetFontScale(renderHelper,1,1)
		RenderHelper.SetFont(renderHelper ,FONT_SCOREMANAGER_DEBUG)
		
		local fontsize 				= 	RenderHelper.GetTextSize(renderHelper,"W")
		local fh					=	fontsize:Y()
	
		local totalscore,levelscore	=	ScoreManager.GetScores()
		local multiplier			=	ScoreManager.multiplier
		local records				=	ScoreManager.GetRecords()
		local bestscore				=	ScoreManager.bestscore
		local round					=	ScoreManager.round
		local totalDestroyed		=	ScoreManager.GetTotalDestroyed()
		
		
		local sstr1					=	string.format("TOTAL SCORE %d LEVELSCORE %d MULTIPLIER %d ROUND %d",totalscore,levelscore,multiplier,round)
		local sstr2					=	string.format("TOTAL DESTROYED %d BESTSCORE %d",totalDestroyed,bestscore)
		

		local index					=	0
		
		local xposName				=	20
		local xposTally				=	140
		local ypos					=	400
		
		for name,total in pairs(records) do
			RenderHelper.DrawText(renderHelper,name,xposName,ypos+index*fh,1,{red=0,blue=0,green=255,alpha=255},"left")
			RenderHelper.DrawText(renderHelper,""..total,xposTally,ypos+index*fh,1,{red=0,blue=0,green=255,alpha=255},"left")
			index	=	index + 1
		end
		

		RenderHelper.DrawText(renderHelper,sstr1,xposTally,ypos+(index+2)*fh,1,{red=0,blue=0,green=255,alpha=255},"left")
		RenderHelper.DrawText(renderHelper,sstr2,xposTally,ypos+(index+3)*fh,1,{red=0,blue=0,green=255,alpha=255},"left")
		
	
	end
	
	
	
end
