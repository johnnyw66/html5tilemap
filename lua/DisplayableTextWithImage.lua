-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not DisplayableTextWithImage) then

DisplayableTextWithImage				    =	{}
DisplayableTextWithImage.className       =	"DisplayableTextWithImage"
DisplayableTextWithImage.GlobalFont      =  "60bold"

    function DisplayableTextWithImage.Create(text,sx,sy,pos,imageresource)

          local displayableText = {
            backimageName   =   imageresource or "messagebackground",
            text            =   text,
            scalex          =   sx or 2,
            scaley          =   sy or 5.5,
            font            =   nil,
            position        =   pos or { x = 0, y = 0 },
            colour          =   {red=127,green=127,blue=127,alpha=127},
            className       =   DisplayableTextWithImage.className,
        }
        setmetatable(displayableText,{__index = DisplayableTextWithImage } )

        return displayableText
    end

    function DisplayableText.SetGlobalFont()
        -- TODO
    end


    function DisplayableTextWithImage.Update(displayabletext,dt)

    end

    function DisplayableTextWithImage.GetPosition(displayabletext)
        return displayabletext.position
    end

    function DisplayableTextWithImage.SetPosition(displayabletext,pos)
         displayabletext.position = pos
    end

    function DisplayableTextWithImage.Render(displayabletext,rHelper)

            local x = displayabletext.position.x
            local y = displayabletext.position.y


            if (displayabletext.backimageName) then
                RenderHelper.DrawTextureScale(rHelper,displayabletext.backimageName,x,y,displayabletext.scalex,displayabletext.scaley)
            end

            RenderHelper.SetFont(rHelper,displayabletext.font or FONT_POPUPMENU)
            RenderHelper.SetFontScale(rHelper,1,1.6)
            RenderHelper.DrawTextNoScale(rHelper,displayabletext.text,x+3,y+3,{red=0,green=0,blue=0,alpha=127})
            RenderHelper.DrawTextNoScale(rHelper,displayabletext.text,x,y,displayabletext.colour)
            RenderHelper.SetFont(rHelper,FONT_DEFAULT)
            RenderHelper.SetFontScale(rHelper,1,1)

    end

end
