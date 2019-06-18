--
--	version 0.2
--
-- This script was written by stom. You are free to use it for your own 
-- mods if you wish.
--
-- This script can be placed on an asset in Tabletop Simualtor and when
-- called it will check the specified repository for a `version` file that 
-- relates to the object. If the version noted in the file is newer than 
-- the one passed to the function it will proceed to fetch and apply the 
-- lua and xml script that are in the repo.
--
-- Expected repo structure is as follows:
-- 
-- --scripts/
-- -- | --  assetname
-- -- -- | -- assetname.xml
-- -- -- | -- assetname.lua
-- -- -- | -- version
--
-- The version file is a simple text file containing an 8-digit date in YYYYMMDD 
-- format with an optional subversion letter (eg 20190617, 20190617a, 20190617g, etc).
-- 
-- Example call:
--
-- 		function onLoad()
-- 			asset = {
-- 				name = "boxfan",
-- 				version = "20190617a"
-- 			}
-- 			checkForUpdates("asset.name", asset.version)
-- 		end

--@@include updater.lua
function checkForUpdates(asset, current_version, repo_url, timeout)

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
		}
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
		local c_ver = updater.version
		local name = updater.asset
		--check if target version [t_ver] is newer than the current [c_ver]
		
		--check for a straight match
		if t_ver==c_ver then 
			log("Asset "..name.." is up-to-date: "..t_ver)
			return false
		end

		--check for newer date
		local t_date = string.match(t_ver, "%d+")
		local c_date = string.match(c_ver, "%d+")
		if t_date > c_date then 
			log("Asset "..name.." needs to be updated from "..c_ver.." to "..t_ver)
			return true 
		end

		--check for same date but newer subversion
		if t_date == c_date then
			local t_rev = string.match(t_ver, "%a+") or 0
			local c_rev = string.match(c_ver, "%a+") or 0
			if string.byte(t_rev) > string.byte(c_rev) then 
				log("Asset "..name.." needs to be patched from "..c_ver.." to "..t_ver)
				return true 
			end
		end

		--local copy is higher than remote copy
		log("!#! Warning! asset "..name.." is a higher version than the repo")
		return false
	end
	
	--poll the repo and check the version file to see if we need to update
	--if there's a version mismatch check if we're behind and fetch and apply
	--the lua and xml before reloading the object	

	WebRequest.get(updater.url.version, function(version_response)
		if versionIsNewer(version_response.text) then
			log("Updating "..updater.asset.." to version "..version_response.text)

			for k,_ in pairs(updater.loading) do
				log("   ...fetching new "..k.." from repo")
				WebRequest.get(updater.url[k], function(r)
					updater.cache[k] = r.text
					updater.loading[k] = false
				end)
			end

			--wait for both to complete before reloading
			Wait.condition(
				function() 
					log("   ...new assets data loaded from repo")
						local jsonSpawnObj     = JSON.decode(self.getJSON())
						jsonSpawnObj.XmlUI     = updater.cache.xml
						jsonSpawnObj.LuaScript = updater.cache.lua
						--apply custom properties
						for k,v in pairs(JSON.decode(updater.cache.json)) do
							if jsonSpawnObj[k] then
								for kk,vv in pairs(v) do
									jsonSpawnObj[k][kk] = vv
								end
							end
						end
						--replace object
						log("   ...destroying self and creating a replacement")
						spawnObjectJSON({
							json = JSON.encode(jsonSpawnObj)
						})
						self.destruct()
					--
				end,
				function() 
					return (
						not updater.loading.lua and 
						not updater.loading.xml and 
						not updater.loading.json
					) 
				end,
				timeout, --set above
				function()
					log("Unable to update asset "..asset..", update timed out after "..timeout.." seconds")
				end
			)
		end
	end)
end
--@@end include updater.lua