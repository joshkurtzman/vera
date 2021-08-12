

local tsdbDevices = {}
  table.insert(tsdbDevices, {"urn:micasaverde-com:serviceId:EnergyMetering1", "KWH", 18 })
  table.insert(tsdbDevices,{"urn:micasaverde-com:serviceId:EnergyMetering1", "KWH", 454 })
  table.insert(tsdbDevices,{"urn:micasaverde-com:serviceId:EnergyMetering1", "KWH", 455 })
  table.insert(tsdbDevices, {"urn:micasaverde-com:serviceId:EnergyMetering1", "Watts", 454 })
  table.insert(tsdbDevices, {"urn:micasaverde-com:serviceId:EnergyMetering1", "Watts", 455 })
  table.insert(tsdbDevices, {"urn:micasaverde-com:serviceId:EnergyMetering1", "Watts", 18 })
  table.insert(tsdbDevices, {"urn:micasaverde-com:serviceId:EnergyMetering1", "Volts", 18 })
  table.insert(tsdbDevices, {"urn:micasaverde-com:serviceId:EnergyMetering1", "Amps", 18 })
  table.insert(tsdbDevices, {"urn:upnp-org:serviceId:TemperatureSensor1", "CurrentTemperature", 111 })
  table.insert(tsdbDevices, {"urn:upnp-org:serviceId:TemperatureSensor1", "CurrentTemperature", 112 })
  table.insert(tsdbDevices, {"urn:upnp-org:serviceId:TemperatureSensor1", "CurrentTemperature", 113 })
  table.insert(tsdbDevices, {"urn:upnp-org:serviceId:TemperatureSensor1", "CurrentTemperature", 449 })




function logToTsdb(lul_device, lul_service, lul_variable, lul_value_old, lul_value_new)
		luup.log("logToTsdb Call back")
		metricTable = {}
		metricTable["KWH"] = "vera.kwh"
		metricTable["Watts"] = "vera.watts"
		metricTable["Volts"] = "vera.volts"
		metricTable["Amps"] = "vera.amps"
		metricTable["CurrentTemperature"] = "vera.temp"
		
	--	local value, tstamp = luup.variable_get(each[1], each[2], each[3])
		local tbl = {}
		local device = luup.attr_get("name", lul_device)
		device = string.lower(device)
		device = device:gsub("%s+", "")
		local data	={ metric = metricTable[lul_variable],
				  tags = { device = device,
						   deviceid = lul_device},
				  timestamp = os.time(),
				  value = tonumber(lul_value_new)
				}		
		table.insert(tbl, data)
	
	local json = require ("dkjson")
	local reqbody = json.encode (tbl, { indent = true })			

	luup.log("openTsdb: " .. reqbody)
	local http = require("socket.http")
    local ltn12 = require("ltn12")

    local respbody = {} -- for the response body

    local result, respcode, respheaders, respstatus = http.request {
        method = "POST",
        url = "http://10.10.10.11:4242/api/put",
        source = ltn12.source.string(reqbody),
        headers = {
            ["content-type"] = "text/json",
            ["content-length"] = tostring(#reqbody)
        },
        sink = ltn12.sink.table(respbody)
    }
    -- get body as string by concatenating table filled by sink
    respbody = table.concat(respbody)
	
	print(respbody)
end

for i=1 , #tsdbDevices do
	luup.log("logToTsdb added " ..  tsdbDevices[i][1] .." ".. tsdbDevices[i][2].." ".. tsdbDevices[i][3])
	luup.variable_watch("logToTsdb", tsdbDevices[i][1], tsdbDevices[i][2], tsdbDevices[i][3])
	end