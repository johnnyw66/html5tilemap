-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Particle) then
Particle = {}
Particle.className = "Particle"

	function Particle.Create()
		local particle = {
			prev 		=	nil,
			next 		=	nil,
			className = Particle.className,
    	}
		
		setmetatable(particle,{ __index = Particle }) 
		return particle 
	end
	
	function Particle.Init(particle,constructor,initpackage)
	    particle.time = 0 
		particle.moveobject	=	constructor(initpackage)
    end

	function Particle.Render(particle,renderhelper)
		if (particle.moveobject) then
			particle.moveobject:Render(renderhelper)
  		end
	end
	
	function Particle.Update(particle,dt)
		particle.time = particle.time + dt 
		if (particle.moveobject) then
			particle.moveobject:Update(dt)
		end
    end

	function Particle.GetTimeLivedFor(particle)
		return particle.time 
	end
	
	function Particle.IsFree(particle)
		return particle.moveobject and particle.moveobject:IsFree()
	end

	function Particle.IsAlive(particle)
		return not Particle.IsFree(particle)
	end

	function Particle.GetVectorPosition(particle)
		return particle.moveobject and particle.moveobject:GetVectorPosition()
	end

	
end
