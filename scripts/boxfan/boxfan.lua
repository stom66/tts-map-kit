function onLoad(save_data)
	fan = {
		speed   = 3, -- 3*inc
		max     = 8,
		inc     = 0.04,
		running = false,
		version = "20190617c"
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

	local url_version = repo..asset.."/version"
	local url_lua = repo..asset.."/"..asset..".lua"
	local url_xml = repo..asset.."/"..asset..".xml"

	local function isNewerThan(t)
		--check if [t]arget version is newer than current [version]
		
		--check for a straight match
		if t==version then 
			log("Asset "..asset.." is running the latest script")
			return false
		end

		--if we didn't get a match, check that the remote version isn't actually older
		--so as to avoid overwrites during development

		local t_date = string.match(t, "%d+")
		local c_date = string.match(version, "%d+")

		--check for newer date
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
    	if isNewerThan(version_response.text) then
    		local lua_loaded, xml_loaded = false, false
    		WebRequest.get(url_lua, function(lua_response)
    			lua_loaded = lua_response.text
    		end)
    		WebRequest.get(url_xml, function(xml_response)
    			xml_loaded = xml_response.text
    		end)
    		Wait.condition(
    			function()
    				self.setLuaScript(lua_loaded)
    				self.setXml(xml_loaded)
    				log("Asset "..asset.." scripts have been updated to version "..version_response.text..", triggering asset reload")
    				self.reload()
    			end,
    			function()
    				if lua_loaded ~= false and xml_loaded ~= false then
    					return true
    				else
    					return false
    				end
    			end,
    			20, --seconds wait limit
    			function()
    				log("Unable to update asset "..asset..", update timed out after 20 seconds")
    			end
    		)
    	end
    	--if response.some_flag then
    	--	--update ourself
    	--	local lua = ""
    	--	local xml = ""
    	--	self.setLuaScript(lua)
    	--	self.setXmlTable(xml)
    	--	self.reload()
    	--	log(asset_name.." has been updated from the repository: "..repo)
    	--end
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