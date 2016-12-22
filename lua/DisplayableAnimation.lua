-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not DisplayableImage) then

DisplayableAnimation				    =	{}
DisplayableAnimation.className       	=	"DisplayableAnimation"

    function DisplayableAnimation.Create(animation,pos,scale)

          local displayableanimation = {
            animation       =   animation,
            position        =   pos or { x = 0, y = 0 },
            scalex          =   scale or 1,
            scaley          =   scale or 1,
            sprite          =   Sprite.Create(),
            className       =   DisplayableAnimation.className,
        }
        setmetatable(displayableanimation,{__index = DisplayableAnimation } )
        return displayableanimation
    end


    function DisplayableAnimation.SetScale(displayableanimation,scalex,scaley)
            displayableanimation.scalex = scalex or 1
            displayableanimation.scaley = scaley or displayableanimation.scalex
   end


    function DisplayableAnimation.Update(displayableanimation,dt)

        if (displayableanimation.animation) then
            displayableanimation.animation:Update(dt)
        end
    end

    function DisplayableAnimation.GetPosition(displayableanimation)
        return displayableanimation.position
    end

    function DisplayableAnimation.SetPosition(displayableanimation,pos)
         displayableanimation.position = pos
    end

    function DisplayableAnimation.Render(displayableanimation,renderHelper)

            local textureid =	displayableanimation.animation:GetRenderTexture().textureid
		    Sprite.SetTexture(displayableanimation.sprite,RenderHelper.TextureFind(textureid))
            local x = displayableanimation.position.x
            local y = displayableanimation.position.y
            RenderHelper.DrawSprite(renderHelper,displayableanimation.sprite,x,y,displayableanimation.scalex)

    end

end
