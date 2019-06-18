function onLoad(save_data)
	fan = {
		speed        = 3, -- 3*inc
		max          = 8,
		inc          = 0.04,
		running      = false,
		repo_name    = "boxfan",
		repo_version = "20190618b",
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
function checkForUpdates(asset, current_version, repo_url)
	--simple script to check for updates to this assets lua or xml code
	local updater = {
		asset   = asset,
		version = current_version,
		repo    = repo_url,
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

	local function validResponse(response)
		if not response.text or response.text == "" then
			return false, 0
		elseif response.text == "404: Not Found" then
			return false, 404
		else
			return true
		end
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
				if validResponse(lua_response) then
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
				if validResponse(xml_response) then
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
				if validResponse(json_response) then
					log("   ...loaded json from "..json_response.url)
					local json = JSON.decode(json_response.text)
					for k,v in pairs(json) do
						log("   ...updating custom properties to:")
						log(v)
						self.setCustomObject(v)
						break
					end
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
--@@end include updater.lua