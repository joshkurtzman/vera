--  variables
local BaseTemp = 71
local outsideTemp = luup.variable_get("urn:upnp-org:serviceId:TemperatureSensor1","CurrentTemperature", 165 ) * 1
local overrideTime = luup.variable_get("urn:jkurtzman-com:serviceId:OverrideTime","overrideTime", 363 )  or 0 
local lastSet = luup.variable_get("urn:jkurtzman-com:serviceId:LastSet","lastSet", 363 )  or luup.variable_get("urn:upnp-org:serviceId:TemperatureSetpoint1", "CurrentSetpoint", 363 )  
local currentSet = luup.variable_get("urn:upnp-org:serviceId:TemperatureSetpoint1", "CurrentSetpoint", 363 )  
local mode = luup.variable_get("urn:upnp-org:serviceId:HVAC_UserOperatingMode1","ModeStatus", 363 )
local offset = 0

local currentTime = os.date("*t", os.time())	-- print(currentTime.hour, currentTime.min)

local isNight = false --= luup.is_night()
	if (currentTime.hour < 8) or (currentTime.hour > 20) then
        isNight = true
    end

local setBack = false
	if (currentTime.hour > 10) and (currentTime.hour < 5 ) then
        setBack = true
    end
	
local insideHumidity = 20 --luup.variable_get("urn:upnp-org:serviceId:TemperatureSensor1","CurrentTemperature", X )
local occupied = true

local downStairsTemp = luup.variable_get("urn:upnp-org:serviceId:TemperatureSensor1","CurrentTemperature", 363)

local upStairsTemp = luup.variable_get("urn:upnp-org:serviceId:TemperatureSensor1","CurrentTemperature", 363)  

local windowsOpen = 0 --global incremement for each



if ( tonumber(lastSet) ~= tonumber(currentSet) ) then
	overrideTime = os.time()  + (60 * 60 * 2)
	luup.variable_set("urn:jkurtzman-com:serviceId:OverrideTime", "overrideTime", overrideTime, 363 )
	luup.variable_set("urn:jkurtzman-com:serviceId:LastSet","lastSet", currentSet, 363 )
end
if tonumber(overrideTime) > ( os.time() ) then 
    luup.log("Temp overRide Active until " .. overrideTime  .. " Last Set:" .. lastSet)
    return false
end	
 
if (mode == "HeatOn") then
	if tonumber(outsideTemp) < 25 then
		offset = offset + 1
	end
	if isNight == true then
		offset = offset - 4
	end
	if setBack == true then
		offset = offset - 2
	end
elseif (mode == "CoolOn") then
	if tonumber(outsideTemp) > 85 then
		offset = offset - 1
	end
	if isNight == true then
		offset = offset - 1
	end
	if setBack == true then
		offset = offset + 1
	end
	if tonumber(insideHumidity) > 60 then
		offset = offset - 1
	end
end 	



local setpoint = (BaseTemp + offset)
if (tonumber(currentSet) ~= setpoint) then
    local resultCode, resultString, job, returnArguments = luup.call_action("urn:upnp-org:serviceId:TemperatureSetpoint1", "SetCurrentSetpoint", {["NewCurrentSetpoint"] = setpoint }, 363)
	lastSet = luup.variable_set("urn:jkurtzman-com:serviceId:LastSet","lastSet", setpoint , 363 )
end	

--Circulate fan when temp difference
local fan
if math.abs(upStairsTemp - downStairsTemp) > 4 then
	  fan = "On"
	else 
	  fan = "Auto"
	end
	
	
luup.log("Target Temp:" ..  setpoint .. " FAN:" ..  fan )
	
