-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not Locale) then

Locale = {}
Locale.className="Locale"
Locale.gUseKeyAsText = false
Locale.locale = nil
Locale.prefix = "*"
Locale.keys		=	{}


	function Locale.Init(usekey)
		Locale.keys		=	{}
		if (not Locale.locale) then
			LoadLibrary("Object")
			Locale.locale = Object.GetMe() 
		end

		Locale.gUseKeyAsText = usekey
	
		
	end
	
	function Locale.AddLocaleText(key,text)
		Locale.keys[key] = text
	end
	
 	-- We use a wrapper for retrieving localised text, 
	-- that way we can use the keys for text if 
 	-- we don't have the localized xml ready
	-- If we are using the key for our ingame text 
	-- we pre-append a 'prefix' string infront on our text string.
	
	
	function Locale.GetLocaleText(key)
		if (Locale.gUseKeyAsText) then
			return (Locale.prefix..(Locale.keys[key] or key or "NIL")) 
		else
			if (not Locale.locale) then
				Locale.Init(Locale.gUseKeyAsText)
			end
	    	return (Object.GetLocalizedText(Locale.locale,key) or "") 
		end

	end

	function Locale.ModifyText(text)
		local modtext 	=	text
		string.gsub(text,"_LOCALE%W*[(]([^)]+)[)]",
			function(txt) 
				modtext = Locale and Locale.GetLocaleText and Locale.GetLocaleText(txt) or txt 
			end)
			
		return modtext
	end
	
	-- DEBUG VERSION
	Locale.Init(true)
	Resource.Run("LocaleKeys")

	-- RELEASE VERSION
	--Locale.Init(false)
	
end
