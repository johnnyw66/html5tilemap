-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if not TextureAnim then

TextureAnim				=	{}
TextureAnim.className	=	"TextureAnim" 

	function TextureAnim.Create(val,fps)
		local object = {
			MaxSize 			=	val,
  			FramesPerSecond		=	fps or 15.0,
  			
			looping				=	true,
			bouncing			=	true,
			playing				=	true,

			TexIDList 			=	{},
			nFrames				=	0,
  			FrameTimer			=	0.0,
			className	=	TextureAnim.className
		}
		setmetatable(object,{ __index = TextureAnim }) 
		return object 
	end 
	


	function TextureAnim.AddFrame(textureanim,texID) 
  
		if (textureanim.nFrames < textureanim.MaxSize) then
    		textureanim.TexIDList[textureanim.nFrames]  = texID  
			textureanim.nFrames = textureanim.nFrames + 1 
  		end
  
	end 
	

	function TextureAnim.Update(textureanim,dt) 
	
  	--	Logger.lprint("TextureAnim:Update ",dt) 
		if (textureanim.playing) then
  			textureanim.FrameTimer = textureanim.FrameTimer + dt 
			if (not textureanim.looping) then
				local nFrames,_ = math.modf(textureanim.FrameTimer * textureanim.FramesPerSecond)
				if (nFrames > textureanim.MaxSize - 1) then
					textureanim.playing = false
				end
			end
			
		end
	end
	
	
  
	function TextureAnim.GetRenderTexture(textureanim)
 
		local nFrames,_ = math.modf(textureanim.FrameTimer * textureanim.FramesPerSecond)

		if (not textureanim.looping) then
			nFrames = math.min(nFrames,textureanim.MaxSize - 1)
		else
		
			if (textureanim.bouncing) then
				nFrames = textureanim.MaxSize > 1 and nFrames % (textureanim.MaxSize*2 - 2) or 0
				if (nFrames > textureanim.MaxSize -1) then
					nFrames = (textureanim.MaxSize*2 - 2) - nFrames
				end
			else
				nFrames = nFrames % textureanim.MaxSize
			end
		end
		--return {name='FRAME'..nFrames}
		return textureanim.TexIDList[nFrames] 
	end
	
  
	function TextureAnim.Play(textureanim,looping,bouncing) 
		
 		textureanim.looping  	= 	looping
 		textureanim.bouncing  	=	bouncing 
		textureanim.FrameTimer	=	0.0
		textureanim.playing		= 	true

	end
	
  
  
	function TextureAnim.IsPlaying(textureanim) 
		return textureanim.playing
	end
	
  
  function TextureAnim.Stop(textureanim) 
	textureanim.playing		=	false
  end 
  
  
end
  
