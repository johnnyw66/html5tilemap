-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Message) then

Message				=	{}
Message.className	=	"Message"

    function Message.Create(displayable,springbox)

        local message = {

            displayable     =   displayable,
            springbox       =   springbox,
            className       =   Message.className,
        }
        setmetatable(message,{__index = Message } )
        return message
    end

	function Message.Start(message)
		message.springbox:Start()
	end
	
    function Message.IsFinished(message)
        return message.springbox and message.springbox:IsFinished()
    end

    function Message.Update(message,dt)
        if (message.springbox and message.displayable) then
            message.springbox:Update(dt)
            message.displayable:SetPosition(message.springbox:GetPosition())
        end
    end

    function Message.Render(message,rHelper)
        if (message.displayable) then
            message.displayable:Render(rHelper)
        end
    end
	
	function Message.toPrint(message)
		return "some message"
	end
	

end
