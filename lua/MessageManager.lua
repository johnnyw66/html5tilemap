-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not MessageManager) then

MessageManager					=	{}
MessageManager.className		=	"MessageManager"
MessageManager.items        	=	{}
MessageManager.pooled        	=   {}
MessageManager.time			 	=   0
MessageManager.lasttime		 	=   0
MessageManager.UPDATEDURATION 	=	5

    function MessageManager.Init(cb)
        MessageManager.items        =   {}
        MessageManager.pooled        =   {}
		MessageManager.time			 =   0
		MessageManager.lasttime		 =   0
		MessageManager.callback		 = 	 cb or MessageManager.DefaultCallBack
    end
	
	function MessageManager.DefaultCallBack(message)
		Logger.lprint("MessageManager.DefaultCallBack")
	end
	
	function MessageManager.Clear()
		MessageManager.Init(MessageManager.callback)
	end

	function MessageManager._GetPooled()
		local item = MessageManager.pooled[1]
		table.remove(MessageManager.pooled,1)
		return item
	end
	
    function MessageManager.Update(dt)
		MessageManager.time	=	MessageManager.time + dt

		if ((MessageManager.time > MessageManager.lasttime + MessageManager.UPDATEDURATION) or #MessageManager.items == 0) then
			local item = MessageManager._GetPooled()
			if (item) then
				item:Start()
				table.insert(MessageManager.items,item)
				if (MessageManager.callback) then
					MessageManager.callback(item)
				end
			end
			MessageManager.lasttime = MessageManager.time
		end
		
		
        local finished = {}

        for index,item in pairs(MessageManager.items) do
            item:Update(dt)
            if (item:IsFinished()) then
               table.insert(finished, { index = index, item = item })
            end
        end

        for k,freeitem in pairs(finished) do
            MessageManager.items[freeitem.index] = nil
--            table.remove(MessageManager.items,freeitem.index)
        end

    end

    function MessageManager.AddPooled(message)
		MessageManager.Add(message,true)
    end

    function MessageManager.Add(message,pooled)

		-- Martin's comments 10th May - remove pop ups.
		if (@NOPOPUPMESSAGES@) then
			return
		end
		
		if (pooled) then
       		table.insert(MessageManager.pooled,message)
		else
			message:Start()
   			table.insert(MessageManager.items,message)
			if (MessageManager.callback) then
				MessageManager.callback(message)
			end
		end
		
    end

    function MessageManager.Render(rHelper)
    
    	for index,item in pairs(MessageManager.items) do
            item:Render(rHelper)
        end
    end


end
