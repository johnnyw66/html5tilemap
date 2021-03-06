-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Interpolate)  then

Interpolate = {}
Interpolate.className="Interpolate"


	function Interpolate.Exponential(start,finish,nTime,base)
		Logger.print("Interpolate.exponential ")
		local scale 
		local nbase = base or 10 
		if (finish > start) then
			scale = (math.pow(nbase,nTime) - 1 ) / (nbase - 1)
		else 
			scale = 1 - (math.pow(nbase,1-nTime) - 1) / (nbase - 1)
		end
		return Interpolate.interpolate(start,finish,scale) 
	end

	function Interpolate.Cosine(start,finish,nTime)
		Logger.print("Interpolate.cosine ")
		local scale = (1-math.cos(nTime*math.pi))*0.5
		return Interpolate.interpolate(start,finish,scale) 
	end

	function Interpolate.Linear(start,finish,nTime)
		Logger.print("Interpolate.Linear ")
		local scale = nTime 
		return Interpolate.interpolate(start,finish,scale) 
	end


-- Private 
	function Interpolate.interpolate(start,finish,nTime)
		return (finish-start)*nTime + start 
	end



	function Interpolate.Test()
		for t = 0,1.05,0.05 do
			local v = Interpolate.Cosine(0.75,0.25,t)
			print(t,v)	
			end
	end

Logger.print("Included Interpolate") 

-- end of class

end
