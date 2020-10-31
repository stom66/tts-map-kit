function onLoad(save_data)
	fan = {
		speed        = 3, -- 3*inc
		max          = 8,
		inc          = 0.04,
		running      = false,
		repo_name    = "boxfan",
		repo_version = "20201015a",
		repo_url     = "https://raw.githubusercontent.com/stom66/tts-map-kit/master/data/",
		debug        = false
	}
	checkForUpdates(fan.repo_name, fan.repo_version, fan.repo_url)
	if save_data and save_data ~= "" then
		local speed = tonumber(JSON.decode(save_data)[1])
		if not speed then return false end
		log("restoring fan to speed "..speed)
		fan.running = false
		Wait.frames(toggleFan, 1)
		Wait.frames(function() setSpeed(speed) end, 2)
	end
end
function onSave()
	if fan.running then
		if fan.debug then log("Saved fan at speed "..fan.speed) end
		return JSON.encode({fan.speed})
	else return false end
end
function toggleFan()
	--toggles the fan on or off
	if fan.debug then log("Toggling fan: "..tostring(not fan.running)) end
	if fan.running then
		self.AssetBundle.playTriggerEffect(1)
	else
		self.AssetBundle.playTriggerEffect(0)
	end
	fan.running = not fan.running
	Wait.frames(updateBtnColors, 1)
end
function setSpeed(val)
	--sets the fan speed to be val * faninc. 
	if checkComponentAccess() then
		--test for proper component access to avoid errors with assets that didn't load properly
		fan.speed = tonumber(val)	
		local actual_strength = fan.speed*fan.inc
		local anim_speed      = 0.5 + (fan.speed*0.15)
		local windZone        = self.getChildren()[1].getChildren()[7].getComponents()[2]
		local animSpeed       = self.getChildren()[1].getComponents()[2]
		windZone.set("windMain", actual_strength)
		animSpeed.set("speed", anim_speed)
		if fan.debug then log("Setting fan speed to "..fan.speed.." ("..actual_strength.."), animation speed: "..anim_speed) end
		updateBtnColors()
	end
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

function checkComponentAccess(n)
	---checks that all components required for operation are accessible. 
	local n = n or 0
	if n > 5 then
		if fan.debug then log("Failed checking for component access, reloading asset") end
		self.reload()
		return false
	end
	local okay = true
	if #self.getChildren() == 0 then 
		okay = false 
	elseif #self.getChildren()[1].getChildren() < 7 then 
		okay = false 
	elseif #self.getChildren()[1].getComponents() < 2 then 
		okay = false 
	elseif not self.getChildren()[1].getChildren()[7] then 
		okay = false 
	elseif #self.getChildren()[1].getChildren()[7].getComponents() < 2 then 
		okay = false 
	end
	if okay then 
		return true
	else
		Wait.time(function()
			return checkComponentAccess(n+1)
		end, 0.2)
	end
end
function updateBtnColors()
	--updated xml interface buttons colors according to on/off and strength settings
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

--updater script
function checkForUpdates(a,b,c,d)local e={asset=a,version=b,repo=c,timeout=d or 20,cache={xml,lua,json},loading={xml=true,lua=true,json=true}}local f="?"..math.floor(os.time())local g=e.repo..e.asset.."/"e.url={version=g.."version"..f,lua=g..e.asset..".lua"..f,xml=g..e.asset..".xml"..f,json=g..e.asset..".json"..f}local function h(i)local j=e.version;local k=e.asset;if i==j then log("Asset "..k.." is up-to-date: "..i)return false end;local l=string.match(i,"%d+")local m=string.match(j,"%d+")if l>m then log("Asset "..k.." needs to be updated from "..j.." to "..i)return true end;if l==m then local n=string.match(i,"%a+")or 0;local o=string.match(j,"%a+")or 0;if string.byte(n)>string.byte(o)then log("Asset "..k.." needs to be patched from "..j.." to "..i)return true end end;log("!#! Warning! asset "..k.." is a higher version than the repo")return false end;WebRequest.get(e.url.version,function(p)if h(p.text)then log("Updating "..e.asset.." to version "..p.text)for q,r in pairs(e.loading)do log("   ...fetching new "..q.." from repo")WebRequest.get(e.url[q],function(s)e.cache[q]=s.text;e.loading[q]=false end)end;Wait.condition(function()log("   ...new assets data loaded from repo")local t=JSON.decode(self.getJSON())t.XmlUI=e.cache.xml;t.LuaScript=e.cache.lua;for q,u in pairs(JSON.decode(e.cache.json))do if t[q]then for v,w in pairs(u)do t[q][v]=w end end end;log("   ...destroying self and creating a replacement")spawnObjectJSON({json=JSON.encode(t)})self.destruct()end,function()return not e.loading.lua and not e.loading.xml and not e.loading.json end,d,function()log("Unable to update asset "..a..", update timed out after "..d.." seconds")end)end end)end