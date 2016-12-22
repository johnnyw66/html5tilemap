-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not DisplayableImage) then

DisplayableImage				    =	{}
DisplayableImage.className       	=	"DisplayableImage"

    function DisplayableImage.Create(imageName,pos,scale)
  
          local displayableText = {
            imageName       =   imageName,
            position        =   pos or { x = 0, y = 0 },
            scalex          =   scale or 1,
            scaley          =   scale or 1,
            className       =   DisplayableImage.className,
        }
        setmetatable(displayableText,{__index = DisplayableImage } )
        return displayableText
    end


    function DisplayableImage.SetScale(displayableimage,scalex,scaley)
            displayableimage.scalex = scalex or 1
            displayableimage.scaley = scaley or displayableimage.scalex
   end


    function DisplayableImage.Update(displayableimage,dt)
        
    end

    function DisplayableImage.GetPosition(displayableimage)
        return displayableimage.position
    end

    function DisplayableImage.SetPosition(displayableimage,pos)
         displayableimage.position = pos
    end

    function DisplayableImage.Render(displayableimage,rHelper)
            local x = displayableimage.position.x
            local y = displayableimage.position.y
            RenderHelper.DrawTexture(rHelper,displayableimage.imageName,x,y,0,displayableimage.scalex)
    end

end
