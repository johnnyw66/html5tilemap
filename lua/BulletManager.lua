-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not BulletManager) then

BulletManager = { }

BulletManager.NUMBULLETS            = 100

BulletManager.freelist = nil
BulletManager.usedlist = nil
BulletManager.enabled  = true


	function BulletManager.Init(player,cb)
		BulletManager.enabled	= true
		BulletManager.player 	= player
		BulletManager.freelist 	= nil
		BulletManager.usedlist 	= nil 
       	BulletManager.enabled  	= true
       	BulletManager.callback  = cb

		for i=1,BulletManager.NUMBULLETS do
			local p = Bullet.Create()
			local o = BulletManager.freelist 
			p.nxt = o 
			if (o ~= nil) then
				o.prev = p
			end
			BulletManager.freelist = p 
		end
	end

	function BulletManager.GetBullet() 

		if (BulletManager.enabled and BulletManager.freelist ~= nil) then
			local p = BulletManager.freelist
		
			if (BulletManager.freelist.nxt ~= nil) then
				BulletManager.freelist.prev = nil
			end
			
			BulletManager.freelist = BulletManager.freelist.nxt

			if (BulletManager.usedlist ~= nil) then
				BulletManager.usedlist.prev = p
			end
			p.nxt = BulletManager.usedlist
			p.prev = nil
			BulletManager.usedlist = p
			return p
		end
	   	return nil
	end

	function BulletManager.Allow()
		BulletManager.enabled = true
	end

	function BulletManager.Disallow()
		BulletManager.enabled = false
	end
	
	function BulletManager.Update(dt)

		local part = BulletManager.usedlist

		while(part ~= nil) do
			local next = part.nxt
			if (part:IsFree()) then
                Bullet.ApplyDamage(part)
			else
				Bullet.Update(part,dt,BulletManager.player)
			end
			part = next
		end

	end

	function BulletManager.BUGGEDUpdate(dt)

		local part = BulletManager.usedlist

		while(part ~= nil) do
			next = part.nxt
			Bullet.Update(part,dt,BulletManager.player)
			if (part:IsFree()) then
                Bullet.ApplyDamage(part)
			end
			part = next
		end

	end

--	function BulletManager.BulletFinished(bullet)
--		BulletManager.Free(bullet)
--	end
	
	function BulletManager.Collide(object)

		local collisionobject	=	object:GetCollisionObject()

		if (BulletManager.enabled) then
			local part = BulletManager.usedlist
			while(part ~= nil) do
				if ((part.owner ~= object) and (part.owner.className ~= object.className) and CollisionObject.CheckCollision(collisionobject,part:GetCollisionObject())) then
					return part
				end
				part = part.nxt
			end
    	end
		return nil
	end


 
	function BulletManager.Render(renderHelper)

		
	 	if (BulletManager.enabled) then

			local part = BulletManager.usedlist
			local count = 0
			while(part ~= nil) do
				part:Render(renderHelper)
				part = part.nxt
				count = count + 1
				--assert(count <= BulletManager.NUMBULLETS*40,"WHAT? "..count)
			end
        end
	end


	function BulletManager.Free(p)
		if (BulletManager.usedlist == p) then
			BulletManager.usedlist = p.nxt
		end

		if (p.prev ~= nil) then
			p.prev.nxt = p.nxt
		end

		if (p.nxt ~= nil) then
			p.nxt.prev = p.prev
		end
		p.prev = nil
		p.nxt = BulletManager.freelist

		if (BulletManager.freelist ~= nil) then
			BulletManager.freelist.prev = p
		end

		BulletManager.freelist = p
	end


	function BulletManager:debugList(p)
		print("Debug List ")

		while(p ~= nil) do
			print("Debug "..p:toString())
			p = p.nxt
		end

		print("End Debug List")
	end

	function BulletManager.Stop()
		BulletManager.enabled = false
	end

	function BulletManager.Resume()
	   BulletManager.enabled = true
	end

   function BulletManager.IterateFree(func)
        BulletManager.Iterate(func,BulletManager.freelist)
   end

   function BulletManager.IterateUsed(func)
        BulletManager.Iterate(func,BulletManager.usedlist)
   end

   function BulletManager.Iterate(func,list)
        local part = list or BulletManager.usedlist

	    while(part ~= nil) do
            if (func) then
                func(part)
            end
            part = part.nxt
	    end
    end

    function BulletManager.ReleaseBullet(bullet)
        BulletManager.Free(bullet)
       	if (BulletManager.callback) then
			BulletManager.callback(bullet,'free')
		end
    end

	function BulletManager.Fire(owner,damage,x,y,vel,angle,duration,animation,scale,radius)
		if (BulletManager.enabled) then
        		local miss = BulletManager.GetBullet()
				if (miss) then
					Bullet.Init(miss,owner,damage,x,y,vel,angle,duration,animation,scale,radius)
					if (BulletManager.callback) then
						BulletManager.callback(bullet,'fire')
					end
				end
       end
	end

	function BulletManager.CountUsed()
		local count =  0
		local p = BulletManager.usedlist
		while(p ~= nil) do
			count = count + 1
			p = p.nxt
		end
		return count
	end
	
	function BulletManager.GetInfo()
		return BulletManager.CountUsed()
	end

    function BulletManager.Terminate()
        BulletManager.freelist = nil
        BulletManager.usedlist = nil
        BulletManager.enabled  = false
    end

end


