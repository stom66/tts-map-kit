function onLoad(save_data)
	fan = {
		speed   = 3, -- 3*inc
		max     = 8,
		inc     = 0.04,
		running = false,
		version = "20190617d"
	}
	if save_data and save_data ~= "" then
		local speed = tonumber(JSON.decode(save_data)[1])
		if not speed then return false end
		log("restoring fan to speed "..speed)
		fan.running = false
		Wait.frames(toggleFan, 1)
		Wait.frames(|| setSpeed(speed), 2)
	end
	checkForUpdates()
end
function onSave()
	if fan.running then
		log("Saved fan at speed "..fan.speed)
		return JSON.encode({fan.speed})
	else 
		return false
	end
end

--
-- self updater
--

function checkForUpdates()
	--simple script to check for updates to this assets lua or xml code
	--change these settings
	local version = fan.version
	local repo    = "https://raw.githubusercontent.com/stom66/tts-map-kit/master/scripts/"
	local asset   = "boxfan"
	local timeout = 20

	local url_version = repo..asset.."/version?"..os.time()
	local url_lua = repo..asset.."/"..asset..".lua?"..os.time()
	local url_xml = repo..asset.."/"..asset..".xml?"..os.time()

	local function versionIsNewer(t)
		--check if [t]arget version is newer than current [version]
		--log("Asset "..asset.." is currently running script version "..version)
		--log("Asset "..asset.." latest script version is "..t)
		
		--check for a straight match
		if t==version then 
			log("Asset "..asset.." is running the latest script: "..version)
			return false
		end

		--check for newer date
		local t_date = string.match(t, "%d+")
		local c_date = string.match(version, "%d+")
		if t_date > c_date then 
			log("Asset "..asset.." needs to be updated")
			return true 
		end

		--check for same date but newer subversion
		if t_date == c_date then
			local t_rev = string.match(t, "%a+") or 0
			local c_rev = string.match(version, "%a+") or 0
			if string.byte(t_rev) > string.byte(c_rev) then 
				log("Asset "..asset.." needs to be patched")
				return true 
			end
		end

		--local copy is higher than remote copy
		log("!#! Warning! your local asset "..asset.." has components that a higher version that those on the github")
		return false
	end

	--work out params
    WebRequest.get(url_version, function(version_response)
    	if versionIsNewer(version_response.text) then
    		--get and apply the lua
    		local lua_loaded = false
    		WebRequest.get(url_lua, function(lua_response)
				self.setLuaScript(lua_response.text)
    			log("Loading lua from repo complete")
				lua_loaded = true
    		end)
    		--get and apply the xml
    		local xml_loaded = false
    		WebRequest.get(url_xml, function(xml_response)
    			self.UI.setXml(xml_response.text)
    			log("Loading xml from repo complete")
    			xml_loaded = true
    		end)
    		--wait for both to complete before reloading
    		Wait.condition(
    			function() self.reload() end,
    			function() return (lua_loaded and xml_loaded) end,
    			timeout, --seconds wait limit
    			function()
    				log("Unable to update asset "..asset..", update timed out after "..timeout.." seconds")
    			end
    		)
    	end
    end)
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