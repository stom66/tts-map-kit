function onLoad(save_data)
    weather_zone = {
        version = 20201104,
        Outlines = 0,
	}
	debug = true
    if save_data and save_data ~= "" then
        if debug then log("Zone: attempting to load save data: "..save_data.."<<") end
		
        local data = JSON.decode(save_data)
        if data and data.version and data.version == weather_zone.version then
            weather_zone = data
        else
           if debug then log("There was a version missmatch when loading the saved data for WeatherZone "..self.guid) end
        end
    end
end

function onSave()
   return JSON.encode({weather_zone})
end

function onObjectTriggerEffect(obj, index)
    if obj == self then
        local e = self.AssetBundle.getTriggerEffects()
        for k,v in ipairs(e) do
            if v.index == index then
                local cat = v.name:match("(.*):")
                weather_zone[cat] = index
            end
        end
    end
    if debug then log("Updated weather_zone state data:") end
    if debug then log(weather_zone) end
end