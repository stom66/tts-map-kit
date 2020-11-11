--
--basic events
--
function onLoad(save_data)
	
	data = {
		guids   = {}, --dynamic table of object guid indexes
		zones   = {}, --dynamic table of managed zones
		current = 0,  --notes index of current view
	}
	
	updater = {
		name    = "weathercontroller",
		version = "20201110a",
		repo    = "https://github.com/stom66/tts-map-kit/tree/master/data",
	}
	checkForUpdates(updater.name, updater.version, updater.repo)

	settings = {
		debug        = true,
		color        = {
			success  = "Green",
			info     = "Blue",
			error    = "Red",
			disabled = "rgb(0.4, 0.4, 0.4)",
			enabled  = "rgb(0.9, 0.9, 0.9)",
		},
		fontSize = 32,
		lang                 = {
			count_sep        = " of ",
			no_object        = "No object found! Possibly it was removed?",
			no_perms         = "This feature is only available to game admins",
			zones_refreshed  = function(i) return "Found "..i.." Weather Zones" end,
		},
		look_pitch    = 35,
		look_distance = 15
	}
	effects = {
		Outlines    = {"Outlines: Off", "Outlines: On"},
		Blizzard    = {"Blizzard: Off", "Blizzard: On"},
		Tornado     = {"Tornado: Off", "Tornado: On"},
		Downpour    = {"Downpour: Off", "Downpour: On"},
		Clouds      = {"Clouds: Off", "Clouds: White", "Clouds: Grey", "Clouds: Dark"},
		Rain        = {"Rain: Off", "Rain: Light", "Rain: Medium", "Rain: Heavy", "Rain: Extreme"},
		Hail        = {"Hail: Off", "Hail: Light", "Hail: Medium", "Hail: Heavy", "Hail: Extreme"},
		Snow        = {"Snow: Off", "Snow: Light", "Snow: Medium", "Snow: Heavy", "Snow: Extreme"},
		Mist        = {"Mist: Off", "Mist: Light", "Mist: Medium", "Mist: Heavy", "Mist: Extreme"},
		Lightning   = {"Lightning: Off", "Lightning: Short", "Lightning: Medium", "Lightning: Long",},
		Flies       = {"Flies: Off", "Flies: Light", "Flies: Medium", "Flies: Heavy", "Flies: Extreme"},
		Autumn      = {"Autumn: Off", "Autumn: Light", "Autumn: Medium", "Autumn: Heavy", "Autumn: Extreme"},
		Duststorm   = {"Duststorm: Off", "Duststorm: Light", "Duststorm: Medium", "Duststorm: Heavy", "Duststorm: Extreme"},
		Butterflies = {"Butterflies: Off", "Butterflies: Light", "Butterflies: Medium", "Butterflies: Heavy", "Butterflies: Extreme"},
	}

	if save_data then 
		json = JSON.decode(save_data)
		if json and json.notes and json.current then 
			data = json
			for k,v in ipairs(data.zones) do
				local o = getObjectFromGUID(v.guid)
				for kk,vv in pairs(v.states) do
					if kk ~= "version" then
						o.AssetBundle.playTriggerEffect(vv)
					end
				end
			end
		end
		if settings.debug then log("Loaded "..#data.guids.." zones from save data") end
	end
	
	xml_refresh()
	Wait.frames(checkXMLRefs, 5)
end
	
function onSave()
	if data and data.notes and #data.notes > 0 then
		return JSON.encode({data})
	end
end

function onObjectDestroy(obj)
	local g = obj.guid
	if data.guids[g] then
		table.remove(data.zones, data.guids[g])
		buildGIndex()
		if data.current > #data.zones then
			data.current = #data.zones
		end
		if settings.debug then log("Object "..g.." was destroyed, removing note") end
		updateXml()
	end
end

function onObjectTriggerEffect(obj, index)
	local g = obj.guid
	if data.guids[g] and ignore_trigger ~= g then
		if settings.debug then log("Object "..g.." had a trigger effect activated and is being controlled by this remote") end
		xml_refresh()
	end
end

--
--
--

function buildGIndex()
	data.guids = {}
	for k,v in ipairs(data.zones) do
		data.guids[v.guid] = k
	end
	if settings.debug then 
		log("Rebuilt GIndex:")
		log(data.guids)
	end
end

function playTriggerEffectByName(obj, name)
	local t = obj.AssetBundle.getTriggerEffects()
	for k,v in ipairs(t) do
		--log("Comparing "..v.name..":"..name)
		if v.name == name then
			if settings.debug then log("Activating trigger effect "..v.index..": "..v.name) end
			obj.AssetBundle.playTriggerEffect(v.index)
			return true
		end
	end
end

--
--xml ui management
--
function updateXml()
	--updates the xml ui anytime with current data. triggered anytime data changes
	--set default values for data strings

	local name, guid = "no zone", "no guid"
	local qty          = data.current..settings.lang.count_sep..#data.zones

	if data.current > 0 then
		name = data.zones[data.current].name or "no zone"
		guid = data.zones[data.current].guid or "no guid"
	end

	--update the uis
	self.UI.setAttribute("xml_obj_name", "text", name)
	self.UI.setValue("xml_obj_name", name)
	self.UI.setValue("xml_current_index", qty)
	self.UI.setAttribute("xml_obj_guid", "text", guid)

	for k,v in pairs(effects) do
		self.UI.setAttribute("slider_"..k, "maxValue", #v)
	end

	--update each slider to show its setting
	--first set them all to 1
	for k,v in pairs(effects) do
		self.UI.setAttribute("slider_"..k, "value", 1)
	end

	--then go through each state with a value and work out what it's value should be
	
	local triggers = getObjectFromGUID(data.zones[data.current].guid).AssetBundle.getTriggerEffects()

	for k,v in pairs(data.zones[data.current].states) do
		if k ~= "version" then
			local trigger_name, slider_value
			for kk,vv in ipairs(triggers) do
				if vv.index == v then
					trigger_name = vv.name
					break
				end
			end
			for kk,vv in ipairs(effects[k]) do
				if vv == trigger_name then
					slider_value = kk
					break
				end
			end
			if trigger_name and slider_value then
				self.UI.setAttribute("slider_"..k, "value", slider_value)
				self.UI.setAttribute("text_"..k, "text", trigger_name)
			end
		end
	end

end

function checkXMLRefs()
	if self.guid~="card01" then
		if settings.debug then log("XML GUID miss-match detected. Updating XML") end
		local xml = self.UI.getXml()
		xml = xml:gsub("card01", self.guid)
		self.UI.setXml(xml)
	end
	Wait.frames(updateXml, 5)
end

--
--xml ui triggers
--
function xml_refresh(player, value, id)
	--scans all objects for WeatherZones and adds them to data.zones
	data.zones = {}
	local objs = getAllObjects()
	for _,obj in pairs(objs) do
		if obj.tag and obj.tag == "Figurine" then
			if obj.getTable("weather_zone") then
				table.insert(data.zones, {
					guid     = obj.guid,
					name     = obj.getName(),
					states   = obj.getTable("weather_zone")
				})
			end
		end
	end

	--set last note as current note
	if data.current == 0 then
		data.current = #data.zones
	end

	--rebuild the guid index 
	buildGIndex()

	--show changes
	updateXml()
	if player and player.color then
		broadcastToColor(settings.lang.zones_refreshed(data.current), player.color, settings.color.success)
	end
end

function xml_sliderChanged(player, value, id)
	local effectName = id:gsub("slider_", "")
	local trigger    = effects[effectName][tonumber(value)]
	local o          = getObjectFromGUID(data.zones[data.current].guid)
	playTriggerEffectByName(o, trigger)
	if settings.debug then log(effectName.." updated to value "..trigger) end
end


function xml_next(player, value, id)
	--move through currently selected object
	if not player.admin or #data.zones < 1 then return false end
	data.current = data.current + 1
	--loop at end
	if data.current > #data.zones then 
		data.current = 1 
	end
	updateXml()
end

function xml_prev(player, value, id)
	--move through currently selected object
	if not player.admin or #data.zones < 1 then return false end
	data.current = data.current - 1
	--loop at start
	if data.current < 1 then 
		data.current = math.max(#data.zones, 1)
	end
	updateXml()
end

function xml_pingObject(player, value, id)
	--pings the currently selected object
	if not player.admin or #data.zones < 1 then return false end
	local obj = getObjectFromGUID(data.zones[data.current].guid)
	if obj then
		local b = obj.getBounds()
		b.center.y = b.center.y + (b.size.y/2) - 0.5
		player.pingTable(b.center)
	else
		broadcastToColor(settings.lang.no_object, player.color, settings.color.error)
	end	
end

function xml_cameraToObject(player, value, id)
	--moves the player camera to the currently selected object
	--offset settings are at the top in settings.look_*
	if not player.admin or #data.zones < 1 then return false end
	local obj = getObjectFromGUID(data.zones[data.current].guid)
	local pos = obj.getPosition()
	if obj then
		player.lookAt({
			position = obj.getPosition(),
			pitch    = settings.look_pitch,
			yaw      = player.getPointerRotation()+180,
			distance = settings.look_distance,
		})
	else
		broadcastToColor(settings.lang.no_object, player.color, settings.color.error)
	end	
end



require("data/updater")