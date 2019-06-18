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

function checkForUpdates(asset, version)
	--simple script to check for updates to this assets lua or xml code
	local updater = {
		asset   = asset,
		version = version,
		repo    = "https://raw.githubusercontent.com/stom66/tts-map-kit/master/data/",
		timeout = 20
	}

	do
		local url_s         = "?"..math.floor(os.time())
		local url_base 		= updater.repo..updater.asset.."/"
		updater.url_version = url_base.."version"..url_s
		updater.url_lua     = url_base..updater.asset..".lua"..url_s
		updater.url_xml     = url_base..updater.asset..".xml"..url_s
		updater.url_json    = url_base..updater.asset..".json"..url_s
	end

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
	WebRequest.get(updater.url_version, function(version_response)
		if versionIsNewer(version_response.text) then
			log("Starting script update...")
			log("   ...fetching xml and lua version "..version_response.text)


			--get and apply the lua
			local lua_loaded = false
			WebRequest.get(updater.url_lua, function(lua_response)
				if lua_response.text and lua_response.text ~= "" then
					log("   ...loaded lua from "..lua_response.url)
					self.setLuaScript(lua_response.text)
				else
					log("   ...no lua found at "..lua_response.url)
				end
				lua_loaded = true
			end)

			--get and apply the xml
			local xml_loaded = false
			WebRequest.get(updater.url_xml, function(xml_response)
				if xml_response.text and xml_response.text ~= "" then
					log("   ...loaded xml from "..xml_response.url)
					self.UI.setXml(xml_response.text)
				else
					log("   ...no xml found at "..xml_response.url)
				end
				xml_loaded = true
			end)

			--get and apply the json
			local json_loaded = false
			WebRequest.get(updater.url_json, function(json_response)
				if json_response.text and json_response.text ~= "" then
					log("   ...loaded json from "..json_response.url)
					local json = JSON.decode(json_response.text)
					log("JSON---")
					log(json)
					log("-----")
					--now
					--do
					--custom
					--properties
					--updates
				else
					log("   ...no json found at "..json_response.url)
				end
				json_loaded = true
			end)

			--wait for both to complete before reloading
			Wait.condition(
				function() 
					log("   ...updating asset "..updater.asset.." complete!")
					self.reload() 
				end,
				function() 
					return (lua_loaded and xml_loaded and json_loaded) 
				end,
				timeout, --set above
				function()
					log("Unable to update asset "..asset..", update timed out after "..timeout.." seconds")
				end
			)
		end
	end)
end