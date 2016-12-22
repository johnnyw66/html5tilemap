-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not PickupManager then

PickupManager 				=	{ }
PickupManager.className		=	"PickupManager" 

local	nPickups			=	0	
local	pPlayer				=	nil
local	pickups				=	{}
local  	callback			=	cb

  	function PickupManager.Finish()
		pickups				=	{}
	end

	function PickupManager.Init( ply,cb)

          	nPickups	= 0
         	pPlayer		= ply
         	pickups 	= {}
			callback	= cb
	end


	function PickupManager.Cleanup(pickupmanager)

		pPlayer 			= nil

		for i,pickup in pairs(pickups) do
			pickup:Cleanup()
		end
		
		pickups = {}

	end


	function PickupManager.Reinit()
        Logger.lprint("PickupManager:Reinit()")
		for i,pickup in pairs(pickups) do
			pickup:Cleanup()
		end
		pickups = {}
		nPickups = 0
	end


	function PickupManager.Update( dt)
		local collisions = {}
		
		for i,pickup in pairs(pickups) do
			pickup:Update(dt)
			local collisioninfo = pickup:GetCollisionObject()
			
			if (pickup:IsFinished()) then
				table.insert(collisions,pickup)
				if (callback) then
					callback(pickup,nil,'timedout')
				end
			end
			if pPlayer and pPlayer:IsColliding(collisioninfo.x,collisioninfo.y,collisioninfo.radius) then
				table.insert(collisions,pickup)
				pickup:Collect(pPlayer)
			end
		end

		for _,pickup in pairs(collisions) do
			PickupManager.Remove(pickup)
		end
	end


	function PickupManager.Remove(pickup)
			-- SLOW! TODO
		for i,pickupc in pairs(pickups) do
			if (pickupc == pickup) then
				table.remove(pickups,i)
				nPickups = nPickups - 1
				return
			end
		end	

	end


	function PickupManager.AddRandomPickup(pos,events)
	--	assert(false,'AddRandomPickup: Events ')

		local pdf	=	events.pdf
		local names	=	events.names

		local chosenEvent,chosenIndex = EventChooser.SelectEvent(events.pdf,events.names)


		-- DEBUG
		local choices	=	{}
		for index	=	1,#pdf do 
			table.insert(choices,names[index]..' = '..pdf[index].." ")
		end
		Logger.lprint(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>PickUP Event: = "..chosenEvent.. " Choices: "..table.concat(choices))
		
		-- DEBUG
		
	
		if (chosenEvent ~= 'null') then
			PickupManager.AddPickup(pos,chosenEvent)
		end
		
	end

	function PickupManager.AddPickup(pos,type)
		local pickup = Pickup.Create(pos,type,pPlayer)
		table.insert(pickups,pickup)
		nPickups = nPickups + 1
		if (callback) then
			callback(pickup,nil,'spawned')
		end
	end
		
		
	function PickupManager.GetNumPickups()
		return nPickups
	end
			

	function PickupManager.Collision(object)

		local collisionobject	=	object:GetCollisionObject()
		for i,pickup in pairs(pickups) do
			if CollisionObject.CheckCollision(collisionobject,pickup:GetCollisionObject()) then
				return pickup
			end
		end
		return nil
	end

	function PickupManager.CollectPickup(pickup,by)
		if (callback) then
			callback(pickup,by,'collected')
		end
	end
		

	function PickupManager.GetPickup(idx)
		return pPickup[idx]
	end

	
	function PickupManager.Iterate(pickupmanager,  func)
		for i,pickup in pairs(pickups) do
        	if (func) then
            	func(pickup)
          	end
		end
	end


	function PickupManager.Render(rHelper)
		for i,pickup in pairs(pickups) do
			pickup:Render(rHelper)
		end
   	end

end
