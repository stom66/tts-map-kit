--
-- version 0.3
--
-- This script was written by stom. You are free to use it for your own mods if you wish.
--
-- This script can be placed on an asset in Tabletop Simualtor and when called it will check the specified repository for a `version` file that 
-- relates to the object. If the version noted in the file is newer than the one passed to the function it will proceed to fetch and apply the 
-- lua and xml script that are in the repo.
--
-- Expected repo structure is as follows:
--
-- --repo_url/
-- -- | --  assetname
-- -- -- | -- assetname.xml
-- -- -- | -- assetname.lua
-- -- -- | -- version
--
-- The version file is a simple text file containing an 8-digit date in YYYYMMDD format with an optional subversion letter (eg 20190617, 
-- 20190617a, 20190617g, etc). Note that version strings > 10 chars will break the updater

function checkForUpdates(asset, current_version, repo_url, timeout)

	-- check all required params are supplied
	if not asset or not current_version or not repo_url then
		if not asset then log("Error: updater was not give an asset name") end
		if not current_version then log("Error: updater was not give a current version to compare") end
		if not repo_url then log("Error: updater was not give a repository url") end
		return false
	end

	local updater = {
		asset   = asset,
		version = current_version,
		repo    = repo_url,
		timeout = timeout or 20,
		cache = {
			xml, lua, json
		},
		loading = {
			xml = true,
			lua = true,
			json = true,
		},
		debug = false
	}
	local url_s         = "?"..math.floor(os.time())
	local url_base 		= updater.repo..updater.asset.."/"

	updater.url = {
		version = url_base.."version"..url_s,
		lua     = url_base..updater.asset..".lua"..url_s,
		xml     = url_base..updater.asset..".xml"..url_s,
		json    = url_base..updater.asset..".json"..url_s
	}

	local function versionIsNewer(t_ver)
		--check if target version [t_ver] is newer than the current [c_ver]
		local c_ver = updater.version
		local name = updater.asset
		
		--check for a straight match
		if t_ver==c_ver then 
			if debug or updater.debug then log("Asset "..name.." is up-to-date: "..t_ver) end
			return false
		end

		--check for newer date
		local t_date = string.match(t_ver, "%d+")
		local c_date = string.match(c_ver, "%d+")
		if t_date > c_date then 
			if debug or updater.debug then log("Asset "..name.." needs to be updated from "..c_ver.." to "..t_ver) end
			return true 
		end

		--check for same date but newer subversion
		if t_date == c_date then
			local t_rev = string.match(t_ver, "%a+") or 0
			local c_rev = string.match(c_ver, "%a+") or 0
			if string.byte(t_rev) > string.byte(c_rev) then 
				if debug or updater.debug then log("Asset "..name.." needs to be patched from "..c_ver.." to "..t_ver) end
				return true 
			end
		end

		--local copy is higher than remote copy
		if debug or updater.debug then log("!#! Warning! asset "..name.." is a higher version than the repo") end
		return false
	end
	
	local function applyUpdate()
		--this function 
		if debug or updater.debug then log("   ...new assets data loaded from repo") end
			--create a json spawn table from the current object and update it with the info from the repository
			local jsonSpawnObj           = JSON.decode(self.getJSON())
				  jsonSpawnObj.XmlUI     = updater.cache.xml
				  jsonSpawnObj.LuaScript = updater.cache.lua

			--apply custom properties from the repo
			for k,v in pairs(JSON.decode(updater.cache.json)) do
				if jsonSpawnObj[k] then
					for kk,vv in pairs(v) do
						jsonSpawnObj[k][kk] = vv
					end
				end
			end

			--spawn the replacement object and destroy the current one
			if debug or updater.debug then log("   ...destroying self and creating a replacement") end
			spawnObjectJSON({
				json = JSON.encode(jsonSpawnObj)
			})
			self.destruct()
		--
	end


	--poll the repo and check the version file to see if we need to update
	--if there's a version mismatch check if we're behind and fetch and apply
	--the lua and xml before reloading the object	

	WebRequest.get(updater.url.version, function(version_response)
		--check the response we got makes sense
		if string.len(version_response.text) > 10 then
			if debug or updater.debug then log("Updating "..updater.asset.." failed: webrequest for version returned a string > 10 chars") end
			return false
		end

		--check if we need to update
		local repo_version = version_response.text
		if versionIsNewer(repo_version) then
			if debug or updater.debug then log("Updating "..updater.asset.." to version "..version_response.text) end

			--cache the lua, xml & json from the repo
			for k,_ in pairs(updater.loading) do
				if debug or updater.debug then log("   ...fetching new "..k.." from repo") end
				WebRequest.get(updater.url[k], function(r)
					updater.cache[k] = r.text
					updater.loading[k] = false
				end)
			end

			--wait for the above to complete before applying the latest version of them to the object
			Wait.condition(
				applyUpdate(),
				function() 
					return (
						not updater.loading.lua and 
						not updater.loading.xml and 
						not updater.loading.json) 
				end,
				updater.timeout,
				function()
					if debug or updater.debug then log("Unable to update asset "..asset..", update timed out after "..updater.timeout.." seconds") end
				end
			)
		end
	end)
end