function onLoad(save_data)
	fan = {
		speed   = 3, -- 3*inc
		max     = 8,
		inc     = 0.04,
		running = false,
		version = "20190617l"
	}
	if save_data and save_data ~= "" then
		local speed = tonumber(JSON.decode(save_data)[1])
		if not speed then return false end
		log("restoring fan to speed "..speed)
		fan.running = false
		Wait.frames(toggleFan, 1)
		Wait.frames(|| setSpeed(speed), 2)
	end
	checkForUpdates("boxfan", fan.version)
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

--
-- self updater
--
function checkForUpdates(asset, version)
	--simple script to check for updates to this assets lua or xml code
	local updater = {
		asset   = asset,
		version = version,
		repo    = "https://raw.githubusercontent.com/stom66/tts-map-kit/master/scripts/",
		timeout = 20
	}

	local url_s         = "?"..math.floor(os.time())
	updater.url_version = updater.repo..updater.asset.."/version"..url_s
	updater.url_lua     = updater.repo..updater.asset.."/"..updater.asset..".lua"..url_s
	updater.url_xml     = updater.repo..updater.asset.."/"..updater.asset..".xml"..url_s

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
			--get and apply the lua
			log("   ...fetching xml and lua version "..version_response.text)
			local lua_loaded = false
			WebRequest.get(updater.url_lua, function(lua_response)
				self.setLuaScript(lua_response.text)
				log("   ...loaded lua from "..lua_response.url)
				lua_loaded = true
			end)
			--get and apply the xml
			local xml_loaded = false
			WebRequest.get(updater.url_xml, function(xml_response)
				self.UI.setXml(xml_response.text)
				log("   ...loaded xml from "..xml_response.url)
				xml_loaded = true
			end)
			--wait for both to complete before reloading
			Wait.condition(
				function() 
					log("   ...updating asset "..updater.asset.." complete!")
					self.reload() 
				end,
				function() 
					return (lua_loaded and xml_loaded) 
				end,
				timeout, --set above
				function()
					log("Unable to update asset "..asset..", update timed out after "..timeout.." seconds")
				end
			)
		end
	end)
end