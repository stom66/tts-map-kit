function onLoad()
	controller = {
		guid = "1623b1",
		assigned = false,
		weather = {}
	}
	Wait.condition(
		function()
			targetObject(controller.guid)
		end,
		function()
			local g = self.getDescription()
			if g and g ~= "" and #g == 6 then 
				controller.guid = g
				return true 
			end
			if controller.guid and controller.guid ~= "" and #controller.guid == 6 then 
				return true 
			end
			return false
		end
	)
end

function targetObject(obj)
	if type(obj)=="string" then
		obj = getObjectFromGUID(obj)
	end
	if obj.getGUID() then
		controller.assigned = true
		controller.weather = obj.getTable("weather")
		log("Controller assigned to object "..obj.guid)
		updateGUI()
	else
		log("Invalid target GUID specified")
		return false
	end
end

function updateGUI()
	log("Updating GUI, assigned is:"..tostring(not controller.assigned))

	local xml = self.UI.getXmlTable()

	xml[2].attributes.active = controller.assigned
	xml[3].attributes.active = not controller.assigned
	if table.count(controller.weather) > 0 then
		xml[2].children[1].children = {}
		local tableLayout = xml[2].children[1].children

		for k,v in pairs(controller.weather) do
			log("Adding entry for "..k)
			table.insert(tableLayout, newRow({
				newCell(3, xmlText(k.." - "..v[1].name, "label_"..k)),
				newCell(3, xmlSlider("slider_"..k, 1, #v))
			}))
		end
		Wait.frames(function() self.UI.setXmlTable(xml) end,1)
	end
end

function xml_input_slider(player, option, id)
	--log(player.color.."-"..option.."-"..id)
	local key    = id:gsub("slider_", "")
	local index  = tonumber(option)
	local states = controller.weather[key]
	local state  = states[tonumber(option)]
	log("looking for controller.weather."..key.."."..option)
	self.UI.setAttribute("label_"..key, "Text", key.." - "..state.name)

	--loop through all states and toggle them off, except current
	for k,v in ipairs(states) do
		if v.component and v.path then
			if k==index then
				v.path.set(v.property, v.value_on)
			else
				v.path.set(v.property, v.value_off)
			end
		end
	end
end


function newRow(cells)
	return {
		tag = "Row",
		attributes = {

		},
		children = cells
	}
end
function newCell(colspan, value, class)
	return {
		tag = "Cell", 
		attributes = {
			--columnSpan = colspan or 6,
		},
		children = {value}
	}
end
function xmlText(text, id, class)
	local t = {
		tag = "Text",
		attributes = {
			text = text or "nil",
		},
		value = text or "nil"
	}
	if id then t.attributes.id = id end
	if class then t.attributes.class = class end
	return t
end
function xmlSlider(id, min, max, value)
	return {
		tag = "Slider",
		attributes = {
			id             = id,
			maxValue       = max or 10,
			value          = value or 1
		}
	}
end
function table.count(t)
	local c = 0
	for k,_ in pairs(t) do
		c = c + 1
	end
	return c
end