-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not AssetLoader) then

local	WAITING			=	'WAITING'
local 	LOADING			=	'LOADING'
local 	LOADED			=	'LOADED'
local 	RELEASING		=	'RELEASING'
local 	RELEASED		=	'RELEASED'

AssetLoader = {}
AssetLoader.className="AssetLoader"
AssetLoader.loaded		=	{}
AssetLoader.loading		=	{}

AssetLoader.called		=	0

-- This is the table we fill in deferred loaded assets 
-- Broken down into missions, each mission table
-- contains an array of assets (resource, 'resourcename' and asset type, 'rtype')


AssetLoader.testassets		=	{
-- these two are down here at the moment to support the test Levels menu
-- we run for debugging purposes.
-- Example Levels

	['MISSION1']	=	{
		{resourcename="LEVEL_TESTM1",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},
	['MISSION2']	=	{
		{resourcename="LEVEL_TESTM2",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},
	['MISSION3']	=	{
		{resourcename="LEVEL_TESTM3",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},

	['LEVEL_JUNGLE1']	=	{
		{resourcename="LEVEL_JUNGLE1",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},

	['LEVEL_DESERT1_WITH_FLYING']	=	{
		{resourcename="LEVEL_DESERT1_WITH_FLYING",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},

	['LEVEL_DESERT1']	=	{
		{resourcename="LEVEL_DESERT1",rtype="lua"},
		{resourcename="tileset1_desert",rtype="texture"},
	},

	['LEVEL_JUNGLE1h']	=	{
		{resourcename="LEVEL_JUNGLE1h",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},

	['LEVEL_DESERT1h']	=	{
		{resourcename="LEVEL_DESERT1h",rtype="lua"},
		{resourcename="tileset1_desert",rtype="texture"},
	},

	['LEVEL_INDUSTRIAL1']	=	{
		{resourcename="LEVEL_INDUSTRIAL1",rtype="lua"},
		{resourcename="tileset1_industrial",rtype="texture"},
	},

	['LEVEL_SAND1']	=	{
		{resourcename="LEVEL_SAND1",rtype="lua"},
		{resourcename="tileset1_sand",rtype="texture"},
	},


	-- brian add here
	['LEVEL_JUNGLE2']	=	{
		{resourcename="LEVEL_JUNGLE2",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},
	
	['LEVEL_JUNGLE3']	=	{
		{resourcename="LEVEL_JUNGLE3",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},

	['LEVEL_JUNGLE4']	=	{
		{resourcename="LEVEL_JUNGLE4",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},
	['LEVEL_JUNGLE5']	=	{
		{resourcename="LEVEL_JUNGLE5",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},

	['LEVEL_DESERT2']	=	{
		{resourcename="LEVEL_DESERT2",rtype="lua"},
		{resourcename="tileset1_desert",rtype="texture"},
	},


	['LEVEL_TEST']	=	{
		{resourcename="LEVEL_TEST",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},


}

Resource.Run("AssetLoaderTest")

AssetLoader.releaseassets	=	{

	['MISSION1']	=	{
		{resourcename="LEVEL_JUNGLE1",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},
	['MISSION2']	=	{
		{resourcename="LEVEL_JUNGLE2",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},
--	['MISSION2']	=	{
--		{resourcename="LEVEL_DESERT1",rtype="lua"},
--		{resourcename="tileset1_desert",rtype="texture"},
--	},

	['MISSION3']	=	{
		{resourcename="LEVEL_JUNGLE3",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},
--	['MISSION3']	=	{
--		{resourcename="LEVEL_INDUSTRIAL1",rtype="lua"},
--		{resourcename="tileset1_industrial",rtype="texture"},
--	},

	['MISSION4']	=	{
		{resourcename="LEVEL_JUNGLE4",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},
	['MISSION5']	=	{
		{resourcename="LEVEL_JUNGLE5",rtype="lua"},
		{resourcename="tileset1",rtype="texture"},
	},

	['MISSION6']	=	{
		{resourcename="LEVEL_DESERT1",rtype="lua"},
		{resourcename="tileset1_desert",rtype="texture"},
	},
	['MISSION7']	=	{
		{resourcename="LEVEL_DESERT2",rtype="lua"},
		{resourcename="tileset1_desert",rtype="texture"},
	},
	['MISSION8']	=	{
		{resourcename="LEVEL_DESERT3",rtype="lua"},
		{resourcename="tileset1_desert",rtype="texture"},
	},
	['MISSION9']	=	{
		{resourcename="LEVEL_DESERT4",rtype="lua"},
		{resourcename="tileset1_desert",rtype="texture"},
	},
	['MISSION10']	=	{
		{resourcename="LEVEL_DESERT5",rtype="lua"},
		{resourcename="tileset1_desert",rtype="texture"},
	},
	['MISSION11']	=	{
		{resourcename="LEVEL_INDUSTRIAL1",rtype="lua"},
		{resourcename="tileset1_industrial",rtype="texture"},
	},
	['MISSION12']	=	{
		{resourcename="LEVEL_INDUSTRIAL2",rtype="lua"},
		{resourcename="tileset1_industrial",rtype="texture"},
	},
	['MISSION13']	=	{
		{resourcename="LEVEL_INDUSTRIAL3",rtype="lua"},
		{resourcename="tileset1_industrial",rtype="texture"},
	},
	['MISSION14']	=	{
		{resourcename="LEVEL_INDUSTRIAL4",rtype="lua"},
		{resourcename="tileset1_industrial",rtype="texture"},
	},
	['MISSION15']	=	{
		{resourcename="LEVEL_INDUSTRIAL5",rtype="lua"},
		{resourcename="tileset1_industrial",rtype="texture"},
	},

	['MENUASSETS']	=
		{
		{resourcename="titleBKG",rtype="texture"},
		{resourcename="instructionsBKG",rtype="texture"},
		{resourcename="scoreBKG",rtype="texture"},
		{resourcename="missionBKG",rtype="texture"},
		{resourcename="loadingBKG",rtype="texture"},
	}	
}


AssetLoader.assets	=	@TESTMENU@ and AssetLoader.testassets or AssetLoader.releaseassets


	-- Find Out Lua Asset loaded
	function AssetLoader.GetLuaAssetName(groupName)
			local assets = AssetLoader.assets[groupName] 
			for k,v in pairs(assets) do
				if (v.rtype == 'lua') then
					return v.resourcename
				end
			end
	end
	

	function AssetLoader.GetLoaded()
		local names			=	{}
		
		for index,resourcedef in pairs(AssetLoader.loaded) do
			if (true or resourcedef.rtype ~= 'texture') then
				table.insert(names,{resourcename = resourcedef.resourcename, rtype=resourcedef.rtype})
			end
		end
		return names
	end
	
	function AssetLoader.LoadAssets(levelName,callBack)
		AssetLoader.levelName	=	AssetLoader.assets[levelName] and levelName	or "TEST1"	
		AssetLoader.callBack	=	callBack
		AssetLoader.failed		=	0	
		AssetLoader.called		=	AssetLoader.called + 1
	
	--	assert(false,AssetLoader.levelName)
		local wantedassets		=	{}
		wantedassets.n			=	0

		for assetIndex,assetdefn in pairs(AssetLoader.assets[AssetLoader.levelName]) do
			wantedassets[assetdefn.resourcename] = assetdefn.resourcename
			wantedassets.n		=	wantedassets.n + 1
		end
		
		-- 1st Release those not needed
		for resourceIndex,resourcedef in pairs(AssetLoader.loaded) do
			local rName	=	resourcedef.resourcename
			if (not wantedassets[rName]) then
				AssetLoader.Release( resourceIndex, resourcedef )
			end
		end
			
		for assetIndex,assetdefn in pairs(AssetLoader.assets[AssetLoader.levelName]) do
			if (not AssetLoader.loaded[assetdefn.resourcename]) then
				AssetLoader.Load({resourcename = assetdefn.resourcename, rtype=assetdefn.rtype, status = (AssetLoader.loaded[assetdefn.resourcename] and LOADED) or WAITING})
			end
		end
		
		AssetLoader.progress		=	0
		AssetLoader.progresscnt		=	0
		AssetLoader.Update(0)
	end
	
	function AssetLoader.Update(dt)

		if (AssetLoader.progresscnt ~= 1) then
			AssetLoader.LoadUpdate(dt)
		end
		
	end
	
	function AssetLoader.LoadUpdate(dt)
	
		local loadingcount		=	0
		local progresscount		=	0
		AssetLoader.progresscnt	=	AssetLoader.progresscnt + dt
		
		for assetIndex,assetdefn in pairs(AssetLoader.loading) do
			local status	=	assetdefn.status
			if (status == LOADING) then
			
				loadingcount	=	loadingcount + 1
				local resource	=	assetdefn.resource

				if (resource:IsLoading()) then
					local progress = 0.5		--resource:GetDownloadProgress()  NOT ALLOWED!! 
					progresscount	=	progresscount + progress
				
				elseif (resource:IsLoaded()) then
					progresscount	=	progresscount + 1
					assetdefn.index	=	assetIndex
					AssetLoader.loaded[assetdefn.resourcename]=assetdefn
					AssetLoader.loading[assetIndex] = nil
					assetdefn.status		=	LOADED
				else
					progresscount	=	progresscount + 1
					Logger.lprint("FAILED TO LOAD ASSET "..assetdefn.resourcename)
					AssetLoader.failed	=		AssetLoader.failed + 1
				end
					
				
			elseif (status == WAITING) then
				loadingcount	=	loadingcount + 1
				local rname		=	assetdefn.resourcename or 'NIL'
				-- start loading
				Logger.lprint("START LOADING "..rname)

				assetdefn.resource = Resource.Find( rname )
				assert(assetdefn.resource,'FAILED TO FIND RESOURCE '..rname)
				local loading = Resource.StartLoading( assetdefn.resource )
				if (loading) then
					assetdefn.status		=	LOADING
				else
					assert(false,'FAILED TO START LOADING '..rname)
				end
				
			elseif (status == LOADED) then
				progresscount	=	progresscount + 1
				
			end
			
		end
		AssetLoader.progress	=	((loadingcount == 0) and 1) or progresscount/loadingcount
		
		if (AssetLoader.progresscnt >= 1) then

			if (AssetLoader.callBack) then
				AssetLoader.callBack(AssetLoader.GetLoaded(),AssetLoader.failed)
			end
		end

	end
	

	function AssetLoader.GetProgress()
		return math.min(1,AssetLoader.progresscnt)
	end
	
	function AssetLoader.IsXXXLoaded(assetdefn)
		return AssetLoader.loaded[assetdefn.resourcename]
	end
	
	function AssetLoader.Load(resourcedef)
		table.insert(AssetLoader.loading,resourcedef)
	end
	
	local function _Release(loadedindex)
		local resourcedef	=	AssetLoader.loaded[loadedindex]
		local resourceName	=	resourcedef.resourcename
		local resource		=	resourcedef.resource
		AssetLoader.loaded[loadedindex] = nil
		Resource.Release(resource)
		Logger.lprint(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>RELEASE "..resourceName)
	end
	
	function AssetLoader.ReleaseAll()
		for resourceIndex,resourcedef in pairs(AssetLoader.loaded) do
			_Release(resourceIndex)
		end
	end
	
	function AssetLoader.Release(rsrc)
		local t	=	type(rsrc)
		if (t == 'number') then
			_Release(rsrc)
		elseif (t == 'string') then
			-- we have resource name here - find index
			for resourceIndex,resourcedef in pairs(AssetLoader.loaded) do
				local rName	=	resourcedef.resourcename
				if (rName == rsrc) then
					_Release(resourceIndex)
					break
				end
			end
		else
			assert(false,'AssetLoader.Release - unknown type to release - see a code doctor')
		end
		
	end
	

	-- Useful function for building menu,
	-- from a table of mission strings - return a Levels.levels type table
	-- of lua file asset strings
	
	function AssetLoader.BuildMenuTableFromMission(missiontable)
		local menutable	=	{}
		for missionindex,missionstr in ipairs(missiontable) do
			
			local assets = AssetLoader.assets[missionstr]
			if (assets) then
				for _,asset in pairs(assets) do
					if (asset.rtype == 'lua') then
						table.insert(menutable,{name = asset.resourcename, complete = false, score = 0})
					end
				end
			end

		end
		return menutable
	end
	
	function AssetLoader.RenderDebug(renderHelper)
		local loaded = AssetLoader.GetLoaded()
		for index,resource in pairs(loaded) do
			local resourceName	=	resource.resourcename
--			RenderHelper.DrawTexture(renderHelper,resourceName,80+index*10,600,0,0.125)
			RenderHelper.DrawText(renderHelper,resourceName,80,600+index*20,1,{red=127,green=0,blue=0,alpha=127})
		end
	end

end
