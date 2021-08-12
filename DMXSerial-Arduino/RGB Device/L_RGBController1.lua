-- Luup constants
local JOB_RETURN_FAILURE = 2
local JOB_RETURN_ABORTED = 3
local JOB_RETURN_SUCCESS = 4

-- Plugin constants
local SID_RGBController = "urn:upnp-org:serviceId:RGBController1"
local SID_Dimming = "urn:upnp-org:serviceId:Dimming1"
local SID_ZWaveNetwork = "urn:micasaverde-com:serviceId:ZWaveNetwork1"

-------------------------------------------
-- Plugin variables
-------------------------------------------

local pluginsParams = {}

-------------------------------------------
-- Plugin functions
-------------------------------------------

function getChildDeviceId(lul_device, colorName)
	local pluginParams = pluginsParams[lul_device]

	local rgbChildDeviceId = nil
	local colorAlias = pluginParams.colorAliases[colorName]
	if (colorAlias ~= nil) then
		rgbChildDeviceId = pluginParams.rgbChildDeviceIds[colorAlias]
	end

	return rgbChildDeviceId
end

-- Get variable value and init if value is nil
function getVariableOrInit(lul_device, variableName, defaultValue)

	local value = luup.variable_get(SID_RGBController, variableName, lul_device)
	if (value == nil) then
		luup.variable_set(SID_RGBController, variableName, defaultValue, lul_device)
		value = defaultValue
	end

	return value
end

-- Get level for a specified color
function getColorLevel(lul_device, colorName)
	local colorLevel = 0

	local rgbChildDeviceId = getChildDeviceId(lul_device, colorName)
	if (rgbChildDeviceId ~= nil) then
		local colorLoadLevel = luup.variable_get(SID_Dimming, "LoadLevelStatus", rgbChildDeviceId) or 0
		colorLevel = math.ceil(tonumber(colorLoadLevel) * 2.55)
	end

	return colorLevel
end

-- Set load level for a specified color and a hex value
function setLoadLevelFromHexColor(lul_device, colorName, hexColor)
	local pluginParams = pluginsParams[lul_device]
luup.log("[RGBController.setLoadLevelFromHexColor] lul_device: " .. tostring(lul_device) .. ", colorName: " .. tostring(colorName) .. ", hexColor: " .. tostring(hexColor), 50)
	local rgbChildDeviceId = getChildDeviceId(lul_device, colorName)
	if (rgbChildDeviceId == nil) then
		luup.log("[RGBController.setLoadLevelFromHexColor] rgbChildDeviceId: " .. tostring(rgbChildDeviceId), 1)
		return false
	end

	local loadLevel = math.floor(tonumber("0x" .. hexColor) * 100/255)
	luup.call_action(SID_Dimming, "SetLoadLevelTarget", {newLoadlevelTarget = loadLevel}, rgbChildDeviceId)

	return true
end

-- Set load level for a specified color and a hex value
function getDataToSendFromHexColor(lul_device, colorName, hexColor)
	local pluginParams = pluginsParams[lul_device]
	local colorAlias = pluginParams.colorAliases[colorName]
	local data = "0x00"
	if (colorAlias == "e2") then
		data = "0x02"
	elseif (colorAlias == "e3") then
		data = "0x03"
	elseif (colorAlias == "e4") then
		data = "0x04"
	end
	return data .. " 0x" .. hexColor
end

-- Retrieve colors from controlled RGB device
function initFromSlave (lul_device)
	local pluginParams = pluginsParams[lul_device]

	-- Set color from color levels of the slave device
	local r = getColorLevel(lul_device, "red")
	local g = getColorLevel(lul_device, "green")
	local b = getColorLevel(lul_device, "blue")
	local w = getColorLevel(lul_device, "white")
	local color = toHex(r) .. toHex(g) .. toHex(b) .. toHex(w)
	luup.log("[RGBControler.initFromSlave] Get current color : rgbw(" .. tostring(r) .. "," .. tostring(g) .. "," .. tostring(b) .. "," .. tostring(w) .. ") " .. "#" .. color)
	luup.variable_set(SID_RGBController, "Color", color, lul_device)

	-- Set the status of the controller from slave status
	local loadLevelStatus = tonumber((luup.variable_get(SID_Dimming, "LoadLevelStatus", pluginParams.rgbDeviceId)))
	if (loadLevelStatus > 0) then
		luup.variable_set(SID_RGBController, "Status", "1", lul_device)
	else
		luup.variable_set(SID_RGBController, "Status", "0", lul_device)
	end
end

-- Convert num to hex
function toHex(num)
	local hexstr = '0123456789ABCDEF'
	local s = ''
	while num > 0 do
		local mod = math.fmod(num, 16)
		s = string.sub(hexstr, (mod + 1), (mod + 1)) .. s
		num = math.floor(num / 16)
	end
	if (s == '') then
		s = '0'
	end
	if (string.len(s) == 1) then
		s = '0' .. s
	end
	return s
end

-- Job - Set color
function setColorTargetJob (lul_device, newColor, lul_job)
	local pluginParams = pluginsParams[lul_device]
	local oldColor = luup.variable_get(SID_RGBController, "Color", lul_device)

	-- Compute color
	if (newColor == "") then
		newColor = oldColor
	else
		newColor = newColor:gsub("#","")
		if ((newColor:len() ~= 6) and (newColor:len() ~= 8)) then
			luup.log("[RGBController.setColor] Color '" .. tostring(newColor) .. "' has bad format. Should be '#dddddd' or '#dddddddd'", 1)
			return JOB_RETURN_FAILURE
		end
		if (newColor:len() == 6) then
			-- White not send, keep old value
			newColor = newColor .. oldColor:sub(7, 8)
		end
		luup.variable_set(SID_RGBController, "Color", newColor, lul_device)
	end

	-- Compute device status
	local status = luup.variable_get(SID_RGBController,"Status", lul_device)
	if ((newColor == "00000000") and (status == "1")) then
		luup.variable_set(SID_RGBController, "Status", "0", lul_device)
	elseif (status == "0") then
		luup.variable_set(SID_RGBController, "Status", "1", lul_device)
	end

	-- Set new color
	luup.log("[RGBController.setColor] Set color RGBW #" .. newColor)
	-- DEPRECATED : Vera FGRGB implementation is buggy
	--setLoadLevelFromHexColor(lul_device, "red",   newColor:sub(1, 2))
	--setLoadLevelFromHexColor(lul_device, "green", newColor:sub(3, 4))
	--setLoadLevelFromHexColor(lul_device, "blue",  newColor:sub(5, 6))
	--setLoadLevelFromHexColor(lul_device, "white", newColor:sub(7, 8))
	local data = "0x33 0x05 0x08"
	data = data .. " " .. getDataToSendFromHexColor(lul_device, "white", newColor:sub(7, 8))
	data = data .. " " .. getDataToSendFromHexColor(lul_device, "red",   newColor:sub(1, 2))
	data = data .. " " .. getDataToSendFromHexColor(lul_device, "green", newColor:sub(3, 4))
	data = data .. " " .. getDataToSendFromHexColor(lul_device, "blue",  newColor:sub(5, 6))
	luup.call_action(SID_ZWaveNetwork, "SendData", {Node = pluginParams.rgbZwaveNode, Data = data}, 1)
	-- ARRRRR !!! the white color is not set with the multi Zwave command !
	local newWhiteColor = newColor:sub(7, 8)
	if (newWhiteColor ~= oldColor:sub(7, 8)) then
		setLoadLevelFromHexColor(lul_device, "white", newWhiteColor)
	end

	return JOB_RETURN_SUCCESS
end

-- Job - Set status
function setTargetJob (lul_device, newTargetValue, lul_job)
	local pluginParams = pluginsParams[lul_device]

	luup.log("[RGBController.setTarget] Set device status : " .. tostring(newTargetValue))
	if (tostring(newTargetValue) == "1") then
		luup.call_action(SID_Dimming, "SetLoadLevelTarget", {newLoadlevelTarget = "100"}, pluginParams.rgbDeviceId)
		luup.variable_set(SID_RGBController, "Status", "1", lul_device)
	else
		luup.call_action(SID_Dimming, "SetLoadLevelTarget", {newLoadlevelTarget = "0"}, pluginParams.rgbDeviceId)
		luup.variable_set(SID_RGBController, "Status", "0", lul_device)
	end

	return JOB_RETURN_SUCCESS
end

-- Job - Start animation program
function startAnimationProgramJob (lul_device, programId, lul_job)
	local pluginParams = pluginsParams[lul_device]

	local programId = tonumber(programId) or 0
	if (programId > 0) then
		luup.call_action(SID_ZWaveNetwork, "SendData", {Node = pluginParams.rgbZwaveNode, Data = "0x70 0x04 0x48 0x01 0x" .. toHex(programId)}, 1)
	else
		setColorTargetJob(lul_device, "")
	end

	return JOB_RETURN_SUCCESS
end

-- Init function
function init (lul_device)
	luup.log("[RGBController.init]")

	-- Get plugin params for this device
	getVariableOrInit(lul_device, "Status", "0")
	local pluginParams = {
		deviceName = "RGBController[" .. tostring(lul_device) .. "]",
		rgbDeviceId = tonumber(getVariableOrInit(lul_device, "DeviceId", "0")),
		rgbChildDeviceIds = {},
		color = getVariableOrInit(lul_device, "Color", "000000"),
		colorAliases = {
			red   = getVariableOrInit(lul_device, "RedAlias",   "e2"),
			green = getVariableOrInit(lul_device, "GreenAlias", "e3"),
			blue  = getVariableOrInit(lul_device, "BlueAlias",  "e4"),
			white = getVariableOrInit(lul_device, "WhiteAlias", "e5")
		},
		debug = getVariableOrInit(lul_device, "Debug", "1")
	}
	pluginsParams[lul_device] = pluginParams

	if (pluginParams.rgbDeviceId == 0) then
		luup.log("[RGBController.init] - Device #" .. tostring(lul_device) .. " is not configured", 1)
		return false, "Not configured", pluginParams.deviceName
	else
		pluginParams.rgbZwaveNode = luup.devices[pluginParams.rgbDeviceId].id
		-- Find child devices of the main controller
		for deviceId, device in pairs(luup.devices) do
			if (device.device_num_parent == pluginParams.rgbDeviceId) then
				luup.log("[RGBController.init] Device #" .. tostring(lul_device) .. " - Slave device #" .. tostring(pluginParams.rgbDeviceId) .. " - Find child device '" .. tostring(device.id) .. "' #" .. tostring(deviceId) .. " '" .. device.description .. "'")
				pluginParams.rgbChildDeviceIds[device.id] = deviceId
			end
		end
		-- Get color levels and status from slave
		initFromSlave(lul_device)
	end

	return true, "OK", pluginParams.deviceName
end
