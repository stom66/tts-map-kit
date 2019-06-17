function onLoad(save_data)
	fan = {
		speed   = 3, -- 3*inc
		max     = 8,
		inc     = 0.04,
		running = false,
		version = "20190617"
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
function checkForUpdates()
	--simple script to check for updates to this assets lua or xml code
	local repo = "https://api.bitbucket.org/2.0/repositories/st0m/tts-map-kit/"
	local asset_name = "boxfan"
	local url = ""
    WebRequest.get(url, function(response) 
    	log(response)
    	if response.some_flag then
    		--update ourself
    		local lua = ""
    		local xml = ""
    		self.setLuaScript(lua)
    		self.setXmlTable(xml)
    		self.reload()
    		log(asset_name.." has been updated from the repository: "..repo)
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
