function onLoad(save_data)
	fan = {
		speed        = 3, -- 3*inc
		max          = 8,
		inc          = 0.04,
		running      = false,
		repo_name    = "boxfan",
		repo_version = "20190618c",
		repo_url     = "https://raw.githubusercontent.com/stom66/tts-map-kit/master/data/",
	}
	if save_data and save_data ~= "" then
		local speed = tonumber(JSON.decode(save_data)[1])
		if not speed then return false end
		log("restoring fan to speed "..speed)
		fan.running = false
		Wait.frames(toggleFan, 1)
		Wait.frames(|| setSpeed(speed), 2)
	end
	checkForUpdates(fan.repo_name, fan.repo_version, fan.repo_url)
end
function onSave()
	if fan.running then
		log("Saved fan at speed "..fan.speed)
		return JSON.encode({fan.speed})
	else 
		return false
	end
end
function toggleFan()
	log("Toggling fan: "..tostring(not fan.running))
	if fan.running then
		self.AssetBundle.playTriggerEffect(1)
	else
		self.AssetBundle.playTriggerEffect(0)
	end
	fan.running = not fan.running
	Wait.frames(updateBtnColors, 1)
end

function setSpeed(val)
	log("changeSpeed("..val..")")
	fan.speed = tonumber(val)
	local actual_strength = fan.speed*fan.inc
	local anim_speed = 0.5 + (fan.speed*0.15)
	
	log("Setting fan speed to "..fan.speed.." ("..actual_strength.."), animation speed: "..anim_speed)	
	self.getChildren()[1].getChildren()[7].getComponents()[2].set("windMain", actual_strength)
	self.getChildren()[1].getComponents()[2].set("speed", anim_speed)
	updateBtnColors()
end
	function xml_setSpeed(player, val)
		--called by XML UI
		setSpeed(val)
	end
	function call_setSpeed(t)
		--called by other object scripts
		if type(t[1])=="number" then
			setSpeed(t[1])
		else
			return false
		end
	end
	
function updateBtnColors()
	if fan.running then
		self.UI.setAttribute("btn_power", "color", "green")
	else
		self.UI.setAttribute("btn_power", "color", "red")
	end
	for i=1,fan.max do
		if not fan.running then
			self.UI.setAttribute("power_"..i, "color", "#1A3547")
		else
			if i > fan.speed then
				self.UI.setAttribute("power_"..i, "color", "#6e8b9f")
			else
				self.UI.setAttribute("power_"..i, "color", "#254f6b")
			end
		end
	end
end

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