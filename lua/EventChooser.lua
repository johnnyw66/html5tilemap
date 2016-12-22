-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not EventChooser)  then

EventChooser = {}
EventChooser.className="EventChooser"


	-- EventChooser.SelectEvent 
	-- Input a Table of % probabilities of a particular event
	-- Returns - a Random index - weighted by that table
	-- Eg. eventdistTable = {10,25,50,15}
	-- Gives 10% chance of returning 1 
	-- Gives 25% chance of returning 2
	-- Gives 50% chance of returning 3
	-- Gives 15% chance of returning 4

	-- NB: Sum of eventdistTable elements must work out to be 100
	--  If it doesn't then % chances are worked out
	--  over the sum of elements in eventdistTable


	function EventChooser.SelectEvent(eventdistTable,eventSelectTable)
	
	
		local sumTable = EventChooser.Sum(eventdistTable) 
		local rnd = math.random(1,sumTable) 

		local index = 1 
		local cummSum = 0 
		while(true) do
         	cummSum = cummSum + eventdistTable[index]
         	if (rnd <= cummSum) then
         		if (eventSelectTable) then
       				return eventSelectTable[index],index 
       			else
       				return index 
       			end
			end
         	index = index + 1 

		end

	end
	
	function EventChooser.SelectEventByItemName(eventdistTable,itemName)
		local pdf = {}	
		for idx,event in pairs(eventdistTable) do
			table.insert(pdf,event[itemName])
		end
		return EventChooser.SelectEvent(pdf,eventdistTable)
	end

 	function EventChooser.Sum(tbl)
	   local sum = 0 

	   for i=1,#tbl do
	      sum = sum + tbl[i] 
	   end
	   return sum 

	end


	function EventChooser.Test()

    	local seed = 1234 
		local t = os.date("*t") 
		math.randomseed(t.sec) 

		testtable = {10,85,5}
		history = {}

        for i=1,#testtable do
			history[i] = 0 
        end

		for i=1,100 do
			local choice = EventChooser.SelectEvent(testtable) 
			history[choice] = history[choice]+ 1 
		end

    	for i=1,#history do
			print("Choice ",i,history[i]) 
		end
  	end

--	EventChooser.Test() 


Logger.print("Included EventChooser") 

end
