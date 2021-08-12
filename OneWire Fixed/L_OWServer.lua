-- Embedded Data Systems One-Wire Server plugin
-- (c) Chris Jackson

local OWSERVER_LOG_NAME    = "OW-Server: "

local OWSERVER_SERVICE        = "urn:upnp-org:serviceId:OWServer1"
local HADEVICE_SERVICE        = "urn:micasaverde-com:serviceId:HaDevice1"

local TEMPERATURE_DEVICE      = "urn:schemas-micasaverde-com:device:TemperatureSensor:1"
local TEMPERATURE_SERVICE      = "urn:upnp-org:serviceId:TemperatureSensor1"
local TEMPERATURE_DEVICE_FILE    = "D_TemperatureSensor1.xml"
local TEMPERATURE_SERVICE_FILE    = "S_TemperatureSensor1.xml"
local TEMPERATURE_VARIABLE      = "CurrentTemperature"

local DOORSENSOR_DEVICE        = "urn:schemas-micasaverde-com:device:DoorSensor:1"
local DOORSENSOR_SERVICE      = "urn:micasaverde-com:serviceId:SecuritySensor1"
local DOORSENSOR_DEVICE_FILE    = "D_DoorSensor1.xml"
local DOORSENSOR_SERVICE_FILE    = "S_SecuritySensor1.xml"
local DOORSENSOR_VARIABLE      = "Tripped"

local HUMIDITY_DEVICE        = "urn:schemas-micasaverde-com:device:HumiditySensor:1"
local HUMIDITY_SERVICE        = "urn:micasaverde-com:serviceId:HumiditySensor1"
local HUMIDITY_DEVICE_FILE      = "D_HumiditySensor1.xml"
local HUMIDITY_SERVICE_FILE      = "S_HumiditySensor1.xml"
local HUMIDITY_VARIABLE        = "CurrentLevel"

local BINARYLIGHT_DEVICE      = "urn:schemas-upnp-org:device:BinaryLight:1"
local BINARYLIGHT_SERVICE      = "urn:upnp-org:serviceId:SwitchPower1"
local BINARYLIGHT_DEVICE_FILE    = "D_BinaryLight1.xml"
local BINARYLIGHT_SERVICE_FILE    = "S_SwitchPower1.xml"
local BINARYLIGHT_VARIABLE      = "Status"

local LIGHTSENSOR_DEVICE      = "urn:schemas-micasaverde-com:device:LightSensor:1"
local LIGHTSENSOR_SERVICE      = "urn:micasaverde-com:serviceId:LightSensor1"
local LIGHTSENSOR_DEVICE_FILE    = "D_LightSensor1.xml"
local LIGHTSENSOR_SERVICE_FILE    = "S_LightSensor1.xml"
local LIGHTSENSOR_VARIABLE      = "CurrentLevel"

local PRESSURESENSOR_DEVICE      = "urn:schemas-cd-jackson-com:device:OWPressureSensor:1"
local PRESSURESENSOR_SERVICE    = "urn:cd-jackson-com:serviceId:OWPressureSensor1"
local PRESSURESENSOR_DEVICE_FILE  = "D_OWPressureSensor.xml"
local PRESSURESENSOR_SERVICE_FILE  = "S_OWPressureSensor.xml"
local PRESSURESENSOR_VARIABLE    = "CurrentPressure"

local COUNTER_DEVICE        = "urn:schemas-cd-jackson-com:device:OWCounter:1"
local COUNTER_SERVICE        = "urn:cd-jackson-com:serviceId:OWCounter1"
local COUNTER_FILE          = "D_OWCounter.xml"
local COUNTER_FILE          = "S_OWCounter.xml"
local COUNTER_VARIABLE        = ""

local ENERGY_SERVICE        = "urn:micasaverde-com:serviceId:EnergyMetering1"
local ENERGY_VARIABLE        = "Watts"

local PollFastCounter = 0
local SamplingPeriod  = 60
local POLL_FAST = 3



local  TYPE_UNDEFINED          =  0
local  TYPE_IGNORE            =  1
local  TYPE_TEMP_C            =  2
local  TYPE_TEMP_F            =  3
local  TYPE_HUMIDITY          =  4
local  TYPE_LIGHTSWITCH        =  5
local  TYPE_LIGHTSWITCH_ENERGY      =  6
local  TYPE_DEWPOINT_C          =  7
local  TYPE_DEWPOINT_F          =  8
local  TYPE_HEATINDEX_C        =  9
local  TYPE_HEATINDEX_F        =  10
local  TYPE_HUMINDEX          =  11
local  TYPE_LIGHTSENSOR        =  12
local  TYPE_LIGHTSENSOR_ENERGY      =  13
local  TYPE_PRESSURESENSOR        =  14
local  TYPE_COUNTER          =  15
local  TYPE_DOORSENSOR          =  16


local TypeTable = {}

TypeTable[TYPE_UNDEFINED] = {}
TypeTable[TYPE_UNDEFINED].Name           = "Undefined"

TypeTable[TYPE_IGNORE] = {}
TypeTable[TYPE_IGNORE].Name           = "Ignore"

TypeTable[TYPE_COUNTER] = {}
TypeTable[TYPE_COUNTER].Name          = "Counter"
TypeTable[TYPE_COUNTER].Average          = 1
TypeTable[TYPE_COUNTER].Device          = COUNTER_DEVICE
TypeTable[TYPE_COUNTER].Service          = COUNTER_SERVICE
TypeTable[TYPE_COUNTER].DeviceFile        = COUNTER_DEVICE_FILE
TypeTable[TYPE_COUNTER].ServiceFile        = COUNTER_SERVICE_FILE
TypeTable[TYPE_COUNTER].Variable        = COUNTER_VARIABLE
TypeTable[TYPE_COUNTER].Parameters        = OWSERVER_SERVICE..",CountMultiplier=1\n"

TypeTable[TYPE_PRESSURESENSOR] = {}
TypeTable[TYPE_PRESSURESENSOR].Name        = "Pressure"
TypeTable[TYPE_PRESSURESENSOR].Average      = 10
TypeTable[TYPE_PRESSURESENSOR].Device      = PRESSURESENSOR_DEVICE
TypeTable[TYPE_PRESSURESENSOR].Service      = PRESSURESENSOR_SERVICE
TypeTable[TYPE_PRESSURESENSOR].DeviceFile    = PRESSURESENSOR_DEVICE_FILE
TypeTable[TYPE_PRESSURESENSOR].ServiceFile    = PRESSURESENSOR_SERVICE_FILE
TypeTable[TYPE_PRESSURESENSOR].Variable      = PRESSURESENSOR_VARIABLE
TypeTable[TYPE_PRESSURESENSOR].Parameters    = ""

TypeTable[TYPE_TEMP_C] = {}
TypeTable[TYPE_TEMP_C].Name            = "Temperature (degC)"
TypeTable[TYPE_TEMP_C].Average          = 3
TypeTable[TYPE_TEMP_C].Device               = TEMPERATURE_DEVICE
TypeTable[TYPE_TEMP_C].Service          = TEMPERATURE_SERVICE
TypeTable[TYPE_TEMP_C].DeviceFile        = TEMPERATURE_DEVICE_FILE
TypeTable[TYPE_TEMP_C].ServiceFile        = TEMPERATURE_SERVICE_FILE
TypeTable[TYPE_TEMP_C].Variable          = TEMPERATURE_VARIABLE
TypeTable[TYPE_TEMP_C].Parameters        = OWSERVER_SERVICE..",Units=C\n"

TypeTable[TYPE_TEMP_F] = {}
TypeTable[TYPE_TEMP_F].Name            = "Temperature (degF)"
TypeTable[TYPE_TEMP_F].Average          = 3
TypeTable[TYPE_TEMP_F].Device               = TEMPERATURE_DEVICE
TypeTable[TYPE_TEMP_F].Service          = TEMPERATURE_SERVICE
TypeTable[TYPE_TEMP_F].DeviceFile        = TEMPERATURE_DEVICE_FILE
TypeTable[TYPE_TEMP_F].ServiceFile        = TEMPERATURE_SERVICE_FILE
TypeTable[TYPE_TEMP_F].Variable          = TEMPERATURE_VARIABLE
TypeTable[TYPE_TEMP_F].Parameters        = OWSERVER_SERVICE..",Units=F\n"

TypeTable[TYPE_HUMIDITY] = {}
TypeTable[TYPE_HUMIDITY].Name          = "Humidity"
TypeTable[TYPE_HUMIDITY].Average        = 10
TypeTable[TYPE_HUMIDITY].Device          = HUMIDITY_DEVICE
TypeTable[TYPE_HUMIDITY].Service        = HUMIDITY_SERVICE
TypeTable[TYPE_HUMIDITY].DeviceFile        = HUMIDITY_DEVICE_FILE
TypeTable[TYPE_HUMIDITY].ServiceFile      = HUMIDITY_SERVICE_FILE
TypeTable[TYPE_HUMIDITY].Variable        = HUMIDITY_VARIABLE
TypeTable[TYPE_HUMIDITY].Parameters        = ""

TypeTable[TYPE_LIGHTSWITCH] = {}
TypeTable[TYPE_LIGHTSWITCH].Name        = "Light Switch"
TypeTable[TYPE_LIGHTSWITCH].Average        = 1
TypeTable[TYPE_LIGHTSWITCH].Device        = BINARYLIGHT_DEVICE
TypeTable[TYPE_LIGHTSWITCH].Service        = BINARYLIGHT_SERVICE
TypeTable[TYPE_LIGHTSWITCH].DeviceFile      = BINARYLIGHT_DEVICE_FILE
TypeTable[TYPE_LIGHTSWITCH].ServiceFile      = BINARYLIGHT_SERVICE_FILE
TypeTable[TYPE_LIGHTSWITCH].Variable      = BINARYLIGHT_VARIABLE
TypeTable[TYPE_LIGHTSWITCH].Parameters      = ""

TypeTable[TYPE_LIGHTSWITCH_ENERGY] = {}
TypeTable[TYPE_LIGHTSWITCH_ENERGY].Name      = "Light Switch + Energy";
TypeTable[TYPE_LIGHTSWITCH_ENERGY].Average    = 1
TypeTable[TYPE_LIGHTSWITCH_ENERGY].Device    = BINARYLIGHT_DEVICE
TypeTable[TYPE_LIGHTSWITCH_ENERGY].Service    = BINARYLIGHT_SERVICE
TypeTable[TYPE_LIGHTSWITCH_ENERGY].DeviceFile  = BINARYLIGHT_DEVICE_FILE
TypeTable[TYPE_LIGHTSWITCH_ENERGY].ServiceFile  = BINARYLIGHT_SERVICE_FILE
TypeTable[TYPE_LIGHTSWITCH_ENERGY].Variable    = BINARYLIGHT_VARIABLE
TypeTable[TYPE_LIGHTSWITCH_ENERGY].Parameters  = OWSERVER_SERVICE..",DeviceWatts=0\n"

TypeTable[TYPE_DEWPOINT_C] = {}
TypeTable[TYPE_DEWPOINT_C].Name          = "Dew Point (degC)";
TypeTable[TYPE_DEWPOINT_C].Average        = 10
TypeTable[TYPE_DEWPOINT_C].Device        = TEMPERATURE_DEVICE
TypeTable[TYPE_DEWPOINT_C].Service        = TEMPERATURE_SERVICE
TypeTable[TYPE_DEWPOINT_C].DeviceFile          = TEMPERATURE_DEVICE_FILE
TypeTable[TYPE_DEWPOINT_C].ServiceFile      = TEMPERATURE_SERVICE_FILE
TypeTable[TYPE_DEWPOINT_C].Variable        = TEMPERATURE_VARIABLE
TypeTable[TYPE_DEWPOINT_C].Parameters      = OWSERVER_SERVICE..",Units=C\n"

TypeTable[TYPE_DEWPOINT_F] = {}
TypeTable[TYPE_DEWPOINT_F].Name          = "Dew Point (degF)";
TypeTable[TYPE_DEWPOINT_F].Average        = 10
TypeTable[TYPE_DEWPOINT_F].Device        = TEMPERATURE_DEVICE
TypeTable[TYPE_DEWPOINT_F].Service        = TEMPERATURE_SERVICE
TypeTable[TYPE_DEWPOINT_F].DeviceFile          = TEMPERATURE_DEVICE_FILE
TypeTable[TYPE_DEWPOINT_F].ServiceFile      = TEMPERATURE_SERVICE_FILE
TypeTable[TYPE_DEWPOINT_F].Variable        = TEMPERATURE_VARIABLE
TypeTable[TYPE_DEWPOINT_F].Parameters      = OWSERVER_SERVICE..",Units=F\n"

TypeTable[TYPE_HEATINDEX_C] = {}
TypeTable[TYPE_HEATINDEX_C].Name        = "Heat Index (degC)";
TypeTable[TYPE_HEATINDEX_C].Average        = 10
TypeTable[TYPE_HEATINDEX_C].Device             = TEMPERATURE_DEVICE
TypeTable[TYPE_HEATINDEX_C].Service        = TEMPERATURE_SERVICE
TypeTable[TYPE_HEATINDEX_C].DeviceFile      = TEMPERATURE_DEVICE_FILE
TypeTable[TYPE_HEATINDEX_C].ServiceFile      = TEMPERATURE_SERVICE_FILE
TypeTable[TYPE_HEATINDEX_C].Variable      = TEMPERATURE_VARIABLE
TypeTable[TYPE_HEATINDEX_C].Parameters      = OWSERVER_SERVICE..",Units=C\n"

TypeTable[TYPE_HEATINDEX_F] = {}
TypeTable[TYPE_HEATINDEX_F].Name        = "Heat Index (degF)";
TypeTable[TYPE_HEATINDEX_F].Average        = 10
TypeTable[TYPE_HEATINDEX_F].Device             = TEMPERATURE_DEVICE
TypeTable[TYPE_HEATINDEX_F].Service        = TEMPERATURE_SERVICE
TypeTable[TYPE_HEATINDEX_F].DeviceFile      = TEMPERATURE_DEVICE_FILE
TypeTable[TYPE_HEATINDEX_F].ServiceFile      = TEMPERATURE_SERVICE_FILE
TypeTable[TYPE_HEATINDEX_F].Variable      = TEMPERATURE_VARIABLE
TypeTable[TYPE_HEATINDEX_F].Parameters      = OWSERVER_SERVICE..",Units=F\n"

TypeTable[TYPE_HUMINDEX] = {}
TypeTable[TYPE_HUMINDEX].Name          = "Humidity Index";
TypeTable[TYPE_HUMINDEX].Average        = 10
TypeTable[TYPE_HUMINDEX].Device          = HUMIDITY_DEVICE
TypeTable[TYPE_HUMINDEX].Service        = HUMIDITY_SERVICE
TypeTable[TYPE_HUMINDEX].DeviceFile        = HUMIDITY_DEVICE_FILE
TypeTable[TYPE_HUMINDEX].ServiceFile      = HUMIDITY_SERVICE_FILE
TypeTable[TYPE_HUMINDEX].Variable        = HUMIDITY_VARIABLE
TypeTable[TYPE_HUMINDEX].Parameters        = "";

TypeTable[TYPE_LIGHTSENSOR] = {}
TypeTable[TYPE_LIGHTSENSOR].Name        = "Light Sensor";
TypeTable[TYPE_LIGHTSENSOR].Average        = 1
TypeTable[TYPE_LIGHTSENSOR].Device          = LIGHTSENSOR_DEVICE
TypeTable[TYPE_LIGHTSENSOR].Service        = LIGHTSENSOR_SERVICE
TypeTable[TYPE_LIGHTSENSOR].DeviceFile        = LIGHTSENSOR_DEVICE_FILE
TypeTable[TYPE_LIGHTSENSOR].ServiceFile      = LIGHTSENSOR_SERVICE_FILE
TypeTable[TYPE_LIGHTSENSOR].Variable      = LIGHTSENSOR_VARIABLE
TypeTable[TYPE_LIGHTSENSOR].Parameters      = ""

TypeTable[TYPE_LIGHTSENSOR_ENERGY] = {}
TypeTable[TYPE_LIGHTSENSOR_ENERGY].Name      = "Light Sensor + Energy";
TypeTable[TYPE_LIGHTSENSOR_ENERGY].Average    = 1
TypeTable[TYPE_LIGHTSENSOR_ENERGY].Device    = LIGHTSENSOR_DEVICE
TypeTable[TYPE_LIGHTSENSOR_ENERGY].Service    = LIGHTSENSOR_SERVICE
TypeTable[TYPE_LIGHTSENSOR_ENERGY].DeviceFile   = LIGHTSENSOR_DEVICE_FILE
TypeTable[TYPE_LIGHTSENSOR_ENERGY].ServiceFile  = LIGHTSENSOR_SERVICE_FILE
TypeTable[TYPE_LIGHTSENSOR_ENERGY].Variable    = LIGHTSENSOR_VARIABLE
TypeTable[TYPE_LIGHTSENSOR_ENERGY].Parameters  = OWSERVER_SERVICE..",DeviceWatts=0\n"

TypeTable[TYPE_DOORSENSOR] = {}
TypeTable[TYPE_DOORSENSOR].Name          = "Door Sensor";
TypeTable[TYPE_DOORSENSOR].Average        = 1
TypeTable[TYPE_DOORSENSOR].Device          = DOORSENSOR_DEVICE
TypeTable[TYPE_DOORSENSOR].Service        = DOORSENSOR_SERVICE
TypeTable[TYPE_DOORSENSOR].DeviceFile          = DOORSENSOR_DEVICE_FILE
TypeTable[TYPE_DOORSENSOR].ServiceFile      = DOORSENSOR_SERVICE_FILE
TypeTable[TYPE_DOORSENSOR].Variable        = DOORSENSOR_VARIABLE
TypeTable[TYPE_DOORSENSOR].Parameters      = ""


local  DEVICE_DS18B20_TEMP      =  0

local  DEVICE_EDS0065_TEMP      =  1
local  DEVICE_EDS0065_HUMIDITY    =  2
local  DEVICE_EDS0065_DEWPOINT    =  3
local  DEVICE_EDS0065_HUMINDEX    =  4
local  DEVICE_EDS0065_HEATINDEX  =  5
local  DEVICE_EDS0065_COUNTER1    =  6
local  DEVICE_EDS0065_COUNTER2    =  7
local  DEVICE_EDS0065_LED      =  8
local  DEVICE_EDS0065_RELAY    =  9

local  DEVICE_EDS0068_TEMP      =  10
local  DEVICE_EDS0068_HUMIDITY    =  11
local  DEVICE_EDS0068_DEWPOINT    =  12
local  DEVICE_EDS0068_HUMINDEX    =  13
local  DEVICE_EDS0068_HEATINDEX  =  14
local  DEVICE_EDS0068_PRESSUREMB  =  15
local  DEVICE_EDS0068_PRESSUREHG  =  16
local  DEVICE_EDS0068_LIGHT    =  17
local  DEVICE_EDS0068_COUNTER1    =  18
local  DEVICE_EDS0068_COUNTER2    =  19
local  DEVICE_EDS0068_LED      =  20
local  DEVICE_EDS0068_RELAY    =  21

local  DEVICE_DS2406_INPUTA    =  22
local  DEVICE_DS2406_INPUTB    =  23

local  DEVICE_DS2423_COUNTERA    =  24
local  DEVICE_DS2423_COUNTERB    =  25

local  DEVICE_EDS0067_TEMP      =  26
local  DEVICE_EDS0067_LIGHT    =  27
local  DEVICE_EDS0067_COUNTER1    =  28
local  DEVICE_EDS0067_COUNTER2    =  29
local  DEVICE_EDS0067_LED      =  30
local  DEVICE_EDS0067_RELAY    =  31

local  DEVICE_DS18S20_TEMP      =  32



local DeviceTable = {}

DeviceTable[DEVICE_DS2423_COUNTERA] = {}
DeviceTable[DEVICE_DS2423_COUNTERA].Device    = "DS2423"
DeviceTable[DEVICE_DS2423_COUNTERA].Name    = "Counter A"
DeviceTable[DEVICE_DS2423_COUNTERA].Parameter  = "Counter_A"
DeviceTable[DEVICE_DS2423_COUNTERA].Command    = ""
DeviceTable[DEVICE_DS2423_COUNTERA].Services  = {TYPE_COUNTER, TYPE_IGNORE}

DeviceTable[DEVICE_DS2423_COUNTERB] = {}
DeviceTable[DEVICE_DS2423_COUNTERB].Device    = "DS2423"
DeviceTable[DEVICE_DS2423_COUNTERB].Name    = "Counter B"
DeviceTable[DEVICE_DS2423_COUNTERB].Parameter  = "Counter_B"
DeviceTable[DEVICE_DS2423_COUNTERB].Command    = ""
DeviceTable[DEVICE_DS2423_COUNTERB].Services  = {TYPE_IGNORE, TYPE_COUNTER}

DeviceTable[DEVICE_DS2406_INPUTA] = {}
DeviceTable[DEVICE_DS2406_INPUTA].Device    = "DS2406"
DeviceTable[DEVICE_DS2406_INPUTA].Name      = "Input A"
DeviceTable[DEVICE_DS2406_INPUTA].Parameter    = "InputLevel_A"
DeviceTable[DEVICE_DS2406_INPUTA].Command    = ""
DeviceTable[DEVICE_DS2406_INPUTA].Services    = {TYPE_LIGHTSENSOR, TYPE_LIGHTSENSOR_ENERGY, TYPE_DOORSENSOR, TYPE_IGNORE}

DeviceTable[DEVICE_DS2406_INPUTB] = {}
DeviceTable[DEVICE_DS2406_INPUTB].Device    = "DS2406"
DeviceTable[DEVICE_DS2406_INPUTB].Name      = "Input B"
DeviceTable[DEVICE_DS2406_INPUTB].Parameter    = "InputLevel_B"
DeviceTable[DEVICE_DS2406_INPUTB].Command    = ""
DeviceTable[DEVICE_DS2406_INPUTB].Services    = {TYPE_IGNORE, TYPE_LIGHTSENSOR, TYPE_LIGHTSENSOR_ENERGY, TYPE_DOORSENSOR}

DeviceTable[DEVICE_DS18B20_TEMP] = {}
DeviceTable[DEVICE_DS18B20_TEMP].Device      = "DS18S20"
DeviceTable[DEVICE_DS18B20_TEMP].Name      = "Temperature"
DeviceTable[DEVICE_DS18B20_TEMP].Parameter    = "Temperature"
DeviceTable[DEVICE_DS18B20_TEMP].Command    = ""
DeviceTable[DEVICE_DS18B20_TEMP].Services    = {TYPE_TEMP_C, TYPE_TEMP_F, TYPE_IGNORE}

DeviceTable[DEVICE_DS18S20_TEMP] = {}
DeviceTable[DEVICE_DS18S20_TEMP].Device      = "DS18B20"
DeviceTable[DEVICE_DS18S20_TEMP].Name      = "Temperature"
DeviceTable[DEVICE_DS18S20_TEMP].Parameter    = "Temperature"
DeviceTable[DEVICE_DS18S20_TEMP].Command    = ""
DeviceTable[DEVICE_DS18S20_TEMP].Services    = {TYPE_TEMP_C, TYPE_TEMP_F, TYPE_IGNORE}


DeviceTable[DEVICE_EDS0065_TEMP] = {}
DeviceTable[DEVICE_EDS0065_TEMP].Device      = "EDS0065"
DeviceTable[DEVICE_EDS0065_TEMP].Name      = "Temperature"
DeviceTable[DEVICE_EDS0065_TEMP].Parameter    = "Temperature"
DeviceTable[DEVICE_EDS0065_TEMP].Command    = ""
DeviceTable[DEVICE_EDS0065_TEMP].Services    = {TYPE_TEMP_C, TYPE_TEMP_F, TYPE_IGNORE}

DeviceTable[DEVICE_EDS0065_HUMIDITY] = {}
DeviceTable[DEVICE_EDS0065_HUMIDITY].Device    = "EDS0065"
DeviceTable[DEVICE_EDS0065_HUMIDITY].Name    = "Humidity"
DeviceTable[DEVICE_EDS0065_HUMIDITY].Parameter  = "Humidity"
DeviceTable[DEVICE_EDS0065_HUMIDITY].Command  = ""
DeviceTable[DEVICE_EDS0065_HUMIDITY].Services  = {TYPE_HUMIDITY, TYPE_IGNORE}

DeviceTable[DEVICE_EDS0065_DEWPOINT] = {}
DeviceTable[DEVICE_EDS0065_DEWPOINT].Device    = "EDS0065"
DeviceTable[DEVICE_EDS0065_DEWPOINT].Name    = "Dew Point"
DeviceTable[DEVICE_EDS0065_DEWPOINT].Parameter  = "Dewpoint"
DeviceTable[DEVICE_EDS0065_DEWPOINT].Command  = ""
DeviceTable[DEVICE_EDS0065_DEWPOINT].Services  = {TYPE_IGNORE, TYPE_DEWPOINT_C, TYPE_DEWPOINT_F}

DeviceTable[DEVICE_EDS0065_HUMINDEX] = {}
DeviceTable[DEVICE_EDS0065_HUMINDEX].Device    = "EDS0065"
DeviceTable[DEVICE_EDS0065_HUMINDEX].Name    = "Humidity Index"
DeviceTable[DEVICE_EDS0065_HUMINDEX].Parameter  = "Humindex"
DeviceTable[DEVICE_EDS0065_HUMINDEX].Command  = ""
DeviceTable[DEVICE_EDS0065_HUMINDEX].Services  = {TYPE_IGNORE, TYPE_HUMINDEX}

DeviceTable[DEVICE_EDS0065_HEATINDEX] = {}
DeviceTable[DEVICE_EDS0065_HEATINDEX].Device  = "EDS0065"
DeviceTable[DEVICE_EDS0065_HEATINDEX].Name    = "Heat Index"
DeviceTable[DEVICE_EDS0065_HEATINDEX].Parameter  = "HeatIndex"
DeviceTable[DEVICE_EDS0065_HEATINDEX].Command  = ""
DeviceTable[DEVICE_EDS0065_HEATINDEX].Services  = {TYPE_IGNORE, TYPE_HEATINDEX_C, TYPE_HEATINDEX_F}

DeviceTable[DEVICE_EDS0065_COUNTER1] = {}
DeviceTable[DEVICE_EDS0065_COUNTER1].Device    = "EDS0065"
DeviceTable[DEVICE_EDS0065_COUNTER1].Name    = "Counter 1"
DeviceTable[DEVICE_EDS0065_COUNTER1].Parameter  = "Counter1"
DeviceTable[DEVICE_EDS0065_COUNTER1].Command  = ""
DeviceTable[DEVICE_EDS0065_COUNTER1].Services  = {TYPE_IGNORE, TYPE_COUNTER}

DeviceTable[DEVICE_EDS0065_COUNTER2] = {}
DeviceTable[DEVICE_EDS0065_COUNTER2].Device    = "EDS0065"
DeviceTable[DEVICE_EDS0065_COUNTER2].Name    = "Counter 2"
DeviceTable[DEVICE_EDS0065_COUNTER2].Parameter  = "Counter2"
DeviceTable[DEVICE_EDS0065_COUNTER2].Command  = ""
DeviceTable[DEVICE_EDS0065_COUNTER2].Services  = {TYPE_IGNORE, TYPE_COUNTER}

DeviceTable[DEVICE_EDS0065_LED] = {}
DeviceTable[DEVICE_EDS0065_LED].Device      = "EDS0065"
DeviceTable[DEVICE_EDS0065_LED].Name      = "LED"
DeviceTable[DEVICE_EDS0065_LED].Parameter    = "LEDState"
DeviceTable[DEVICE_EDS0065_LED].Command      = "LEDState"
DeviceTable[DEVICE_EDS0065_LED].Services    = {TYPE_IGNORE, TYPE_LIGHTSWITCH}

DeviceTable[DEVICE_EDS0065_RELAY] = {}
DeviceTable[DEVICE_EDS0065_RELAY].Device    = "EDS0065"
DeviceTable[DEVICE_EDS0065_RELAY].Name      = "Relay"
DeviceTable[DEVICE_EDS0065_RELAY].Parameter    = "RelayState"
DeviceTable[DEVICE_EDS0065_RELAY].Command    = "RelayState"
DeviceTable[DEVICE_EDS0065_RELAY].Services    = {TYPE_IGNORE, TYPE_LIGHTSWITCH, TYPE_LIGHTSWITCH_ENERGY}

DeviceTable[DEVICE_EDS0068_TEMP] = {}
DeviceTable[DEVICE_EDS0068_TEMP].Device      = "EDS0068"
DeviceTable[DEVICE_EDS0068_TEMP].Name      = "Temperature"
DeviceTable[DEVICE_EDS0068_TEMP].Parameter    = "Temperature"
DeviceTable[DEVICE_EDS0068_TEMP].Command    = ""
DeviceTable[DEVICE_EDS0068_TEMP].Services    = {TYPE_TEMP_C, TYPE_TEMP_F, TYPE_IGNORE}

DeviceTable[DEVICE_EDS0068_HUMIDITY] = {}
DeviceTable[DEVICE_EDS0068_HUMIDITY].Device    = "EDS0068"
DeviceTable[DEVICE_EDS0068_HUMIDITY].Name    = "Humidity"
DeviceTable[DEVICE_EDS0068_HUMIDITY].Parameter  = "Humidity"
DeviceTable[DEVICE_EDS0068_HUMIDITY].Command  = ""
DeviceTable[DEVICE_EDS0068_HUMIDITY].Services  = {TYPE_HUMIDITY, TYPE_IGNORE}

DeviceTable[DEVICE_EDS0068_DEWPOINT] = {}
DeviceTable[DEVICE_EDS0068_DEWPOINT].Device    = "EDS0068"
DeviceTable[DEVICE_EDS0068_DEWPOINT].Name    = "Dew Point"
DeviceTable[DEVICE_EDS0068_DEWPOINT].Parameter  = "Dewpoint"
DeviceTable[DEVICE_EDS0068_DEWPOINT].Command  = ""
DeviceTable[DEVICE_EDS0068_DEWPOINT].Services  = {TYPE_IGNORE, TYPE_DEWPOINT_C, TYPE_DEWPOINT_F}

DeviceTable[DEVICE_EDS0068_HUMINDEX] = {}
DeviceTable[DEVICE_EDS0068_HUMINDEX].Device    = "EDS0068"
DeviceTable[DEVICE_EDS0068_HUMINDEX].Name    = "Humidity Index"
DeviceTable[DEVICE_EDS0068_HUMINDEX].Parameter  = "Humindex"
DeviceTable[DEVICE_EDS0068_HUMINDEX].Command  = ""
DeviceTable[DEVICE_EDS0068_HUMINDEX].Services  = {TYPE_IGNORE, TYPE_HUMINDEX}

DeviceTable[DEVICE_EDS0068_HEATINDEX] = {}
DeviceTable[DEVICE_EDS0068_HEATINDEX].Device  = "EDS0068"
DeviceTable[DEVICE_EDS0068_HEATINDEX].Name    = "Heat Index"
DeviceTable[DEVICE_EDS0068_HEATINDEX].Parameter  = "HeatIndex"
DeviceTable[DEVICE_EDS0068_HEATINDEX].Command  = ""
DeviceTable[DEVICE_EDS0068_HEATINDEX].Services  = {TYPE_IGNORE, TYPE_HEATINDEX_C, TYPE_HEATINDEX_F}

DeviceTable[DEVICE_EDS0068_PRESSUREMB] = {}
DeviceTable[DEVICE_EDS0068_PRESSUREMB].Device  = "EDS0068"
DeviceTable[DEVICE_EDS0068_PRESSUREMB].Name    = "Pressure (Mb)"
DeviceTable[DEVICE_EDS0068_PRESSUREMB].Parameter= "BarometricPressureMb"
DeviceTable[DEVICE_EDS0068_PRESSUREMB].Command  = ""
DeviceTable[DEVICE_EDS0068_PRESSUREMB].Services  = {TYPE_PRESSURESENSOR, TYPE_IGNORE}

DeviceTable[DEVICE_EDS0068_PRESSUREHG] = {}
DeviceTable[DEVICE_EDS0068_PRESSUREHG].Device  = "EDS0068"
DeviceTable[DEVICE_EDS0068_PRESSUREHG].Name    = "Pressure (Hg)"
DeviceTable[DEVICE_EDS0068_PRESSUREHG].Parameter= "BarometricPressureHg"
DeviceTable[DEVICE_EDS0068_PRESSUREHG].Command  = ""
DeviceTable[DEVICE_EDS0068_PRESSUREHG].Services  = {TYPE_IGNORE, TYPE_PRESSURESENSOR}

DeviceTable[DEVICE_EDS0068_LIGHT] = {}
DeviceTable[DEVICE_EDS0068_LIGHT].Device    = "EDS0068"
DeviceTable[DEVICE_EDS0068_LIGHT].Name      = "Light"
DeviceTable[DEVICE_EDS0068_LIGHT].Parameter    = "Light"
DeviceTable[DEVICE_EDS0068_LIGHT].Command    = ""
DeviceTable[DEVICE_EDS0068_LIGHT].Services    = {TYPE_IGNORE, TYPE_LIGHTSENSOR, TYPE_LIGHTSENSOR_ENERGY}

DeviceTable[DEVICE_EDS0068_COUNTER1] = {}
DeviceTable[DEVICE_EDS0068_COUNTER1].Device    = "EDS0068"
DeviceTable[DEVICE_EDS0068_COUNTER1].Name    = "Counter 1"
DeviceTable[DEVICE_EDS0068_COUNTER1].Parameter  = "Counter1"
DeviceTable[DEVICE_EDS0068_COUNTER1].Command  = ""
DeviceTable[DEVICE_EDS0068_COUNTER1].Services  = {TYPE_IGNORE, TYPE_COUNTER}

DeviceTable[DEVICE_EDS0068_COUNTER2] = {}
DeviceTable[DEVICE_EDS0068_COUNTER2].Device    = "EDS0068"
DeviceTable[DEVICE_EDS0068_COUNTER2].Name    = "Counter 2"
DeviceTable[DEVICE_EDS0068_COUNTER2].Parameter  = "Counter2"
DeviceTable[DEVICE_EDS0068_COUNTER2].Command  = ""
DeviceTable[DEVICE_EDS0068_COUNTER2].Services  = {TYPE_IGNORE, TYPE_COUNTER}

DeviceTable[DEVICE_EDS0068_LED] = {}
DeviceTable[DEVICE_EDS0068_LED].Device      = "EDS0068"
DeviceTable[DEVICE_EDS0068_LED].Name      = "LED"
DeviceTable[DEVICE_EDS0068_LED].Parameter    = "LEDState"
DeviceTable[DEVICE_EDS0068_LED].Command      = "LEDState"
DeviceTable[DEVICE_EDS0068_LED].Services    = {TYPE_IGNORE, TYPE_LIGHTSWITCH}

DeviceTable[DEVICE_EDS0068_RELAY] = {}
DeviceTable[DEVICE_EDS0068_RELAY].Device    = "EDS0068"
DeviceTable[DEVICE_EDS0068_RELAY].Name      = "Relay"
DeviceTable[DEVICE_EDS0068_RELAY].Parameter    = "RelayState"
DeviceTable[DEVICE_EDS0068_RELAY].Command    = "RelayState"
DeviceTable[DEVICE_EDS0068_RELAY].Services    = {TYPE_IGNORE, TYPE_LIGHTSWITCH, TYPE_LIGHTSWITCH_ENERGY}

DeviceTable[DEVICE_EDS0067_TEMP] = {}
DeviceTable[DEVICE_EDS0067_TEMP].Device      = "EDS0067"
DeviceTable[DEVICE_EDS0067_TEMP].Name      = "Temperature"
DeviceTable[DEVICE_EDS0067_TEMP].Parameter    = "Temperature"
DeviceTable[DEVICE_EDS0067_TEMP].Command    = ""
DeviceTable[DEVICE_EDS0067_TEMP].Services    = {TYPE_TEMP_C, TYPE_TEMP_F, TYPE_IGNORE}

DeviceTable[DEVICE_EDS0067_LIGHT] = {}
DeviceTable[DEVICE_EDS0067_LIGHT].Device    = "EDS0067"
DeviceTable[DEVICE_EDS0067_LIGHT].Name      = "Light"
DeviceTable[DEVICE_EDS0067_LIGHT].Parameter    = "Light"
DeviceTable[DEVICE_EDS0067_LIGHT].Command    = ""
DeviceTable[DEVICE_EDS0067_LIGHT].Services    = {TYPE_LIGHTSENSOR, TYPE_LIGHTSENSOR_ENERGY, TYPE_IGNORE}

DeviceTable[DEVICE_EDS0067_COUNTER1] = {}
DeviceTable[DEVICE_EDS0067_COUNTER1].Device    = "EDS0067"
DeviceTable[DEVICE_EDS0067_COUNTER1].Name    = "Counter 1"
DeviceTable[DEVICE_EDS0067_COUNTER1].Parameter  = "Counter1"
DeviceTable[DEVICE_EDS0067_COUNTER1].Command  = ""
DeviceTable[DEVICE_EDS0067_COUNTER1].Services  = {TYPE_IGNORE, TYPE_COUNTER}

DeviceTable[DEVICE_EDS0067_COUNTER2] = {}
DeviceTable[DEVICE_EDS0067_COUNTER2].Device    = "EDS0067"
DeviceTable[DEVICE_EDS0067_COUNTER2].Name    = "Counter 2"
DeviceTable[DEVICE_EDS0067_COUNTER2].Parameter  = "Counter2"
DeviceTable[DEVICE_EDS0067_COUNTER2].Command  = ""
DeviceTable[DEVICE_EDS0067_COUNTER2].Services  = {TYPE_IGNORE, TYPE_COUNTER}

DeviceTable[DEVICE_EDS0067_LED] = {}
DeviceTable[DEVICE_EDS0067_LED].Device      = "EDS0067"
DeviceTable[DEVICE_EDS0067_LED].Name      = "LED"
DeviceTable[DEVICE_EDS0067_LED].Parameter    = "LEDState"
DeviceTable[DEVICE_EDS0067_LED].Command      = "LEDState"
DeviceTable[DEVICE_EDS0067_LED].Services    = {TYPE_IGNORE, TYPE_LIGHTSWITCH}

DeviceTable[DEVICE_EDS0067_RELAY] = {}
DeviceTable[DEVICE_EDS0067_RELAY].Device    = "EDS0067"
DeviceTable[DEVICE_EDS0067_RELAY].Name      = "Relay"
DeviceTable[DEVICE_EDS0067_RELAY].Parameter    = "RelayState"
DeviceTable[DEVICE_EDS0067_RELAY].Command    = "RelayState"
DeviceTable[DEVICE_EDS0067_RELAY].Services    = {TYPE_IGNORE, TYPE_LIGHTSWITCH, TYPE_LIGHTSWITCH_ENERGY}


local DEBUG_MODE      = false
local OWServerTimeout = 10

local function debug(text)
  if (DEBUG_MODE == true) then
    luup.log("debug: " .. text)
  end
end

local ChildDevices = {}
local NewDevices = {}
local ParentDevice = nil
local LastUpdate = nil


-- Run once at Luup engine startup.
function initialise(lul_device)
  luup.log("Initialising One Wire Server")

  -- Help prevent race condition
  luup.io.intercept()


  local f=io.open("/usr/lib/lua/json.lua","r")
  if f~=nil then
    io.close(f)
  else
    luup.log("OWSERVER: json.lua library not installed")
    luup.task("json.lua library not installed", 2, string.format("%s[%d]", luup.devices[lul_device].description, lul_device), -1)
	luup.set_failure(true)
    return false
  end

  -- Keep local copy of device
  ParentDevice = lul_device

  -- Allow the user to change the sampling period
  SamplingPeriod = luup.variable_get( OWSERVER_SERVICE, "SamplingPeriod", lul_device )
  if(SamplingPeriod == nil) then
    SamplingPeriod = 20
    luup.variable_set(OWSERVER_SERVICE, "SamplingPeriod", SamplingPeriod, lul_device)
  end
  SamplingPeriod = tonumber(SamplingPeriod)

  -- Build the child list
  for k, v in pairs(luup.devices) do
    if (v.device_num_parent == lul_device) then
      ChildDevices[k] = {}
      ChildDevices[k].Id       = k
      ChildDevices[k].ROMId    = luup.variable_get( OWSERVER_SERVICE, "ROMId",       k )
      ChildDevices[k].Device   = luup.variable_get( OWSERVER_SERVICE, "DeviceId",    k )
      ChildDevices[k].Service  = luup.variable_get( OWSERVER_SERVICE, "ServiceId",   k )
      ChildDevices[k].Variable = luup.variable_get( OWSERVER_SERVICE, "Variable",    k )
      ChildDevices[k].Param    = luup.variable_get( OWSERVER_SERVICE, "Param",       k )
      ChildDevices[k].Command  = luup.variable_get( OWSERVER_SERVICE, "Command",     k )
      ChildDevices[k].Watts    = luup.variable_get( OWSERVER_SERVICE, "DeviceWatts", k )
      ChildDevices[k].Average  = luup.variable_get( OWSERVER_SERVICE, "Average",     k )
      ChildDevices[k].Units    = luup.variable_get( OWSERVER_SERVICE, "Units",       k )
      ChildDevices[k].History  = {}
      ChildDevices[k].Counter  = 1
      ChildDevices[k].Record   = 0
      if(ChildDevices[k].Average == nil) then
        ChildDevices[k].Average = 5
      end
      ChildDevices[k].Average = tonumber(ChildDevices[k].Average)
    end
  end

  -- Register handlers to serve the JSON data
  luup.register_handler("incomingCtrl", "owCtrl")

  -- Set the timer to go off in 5 seconds to get an initial update
  pollRate = POLL_RATE_SLOW
  PollFastCounter = 10
  luup.call_timer('pollCycle', 1, "5", "")

  LastUpdate  = os.time(os.date('*t'))

  luup.set_failure(false)

  -- Startup is done.
  return true
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function celciusToF(Celcius)
  return (Celcius * 9 / 5) + 32
end

function pollCycle()
--  luup.log("OWSERVER: poll start")
  local OWServer  = {}
  local OWDevices = {}

--  local dlTime    = 0
--  local startTime = 0

--  dlTime = os.clock()
--  luup.log(OWSERVER_LOG_NAME.."STARTDL: "..dlTime)

  -- Poll the OW-SERVER and get details.xml
  local code, res = luup.inet.wget("http://"..luup.devices[ParentDevice].ip.."/details.xml", OWServerTimeout, "", "")

  if(code ~= 0) then
    luup.call_timer('pollCycle', 1, tostring(SamplingPeriod), "")
    luup.log("OWSERVER: poll err1")
    return
  end

--  startTime = os.clock()
--  luup.log(OWSERVER_LOG_NAME.."START: "..startTime)

  -- Process the XML file into a table
  local Count = 0
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(res, "<(%/?)([%w:_]+)(.-)(%/?)>", i)
    if not ni then
      break
    end
    local text = string.sub(res, i, ni-1)

    if not string.find(text, "^%s*$") then
      if(Count == 0) then
        OWServer[label] = text
      else
        OWDevices[Count][label] = text
      end
    end
    if c == "" then   -- start tag
      if(string.sub(label, 1, 3) == "owd") then
        Count = Count + 1
        OWDevices[Count] = {}
      end
    end
    i = j+1
  end
	
	--add dataerrors together
	OWServer['DataErrors'] = tostring(OWServer.DataErrorsChannel1 + OWServer.DataErrorsChannel2 + OWServer.DataErrorsChannel3)
  
  --set variables only if they've changed
	if(luup.variable_get(OWSERVER_SERVICE, "Devices", ParentDevice) ~= OWServer.DevicesConnected) then
		luup.variable_set(OWSERVER_SERVICE, "Devices",    OWServer.DevicesConnected, ParentDevice)
	  end
	  
	if(luup.variable_get(OWSERVER_SERVICE, "DataErrors", ParentDevice) ~= OWServer.DataErrors) then
		luup.variable_set(OWSERVER_SERVICE, "DataErrors", OWServer.DataErrors,       ParentDevice)
	end

	
	
  -- Loop through all the One-Wire devices in the XML-file table
  local found
  local Value
  for Count = 1, #OWDevices do
    found = 0
    -- Search all child devices to find any with the ROMId
    for k, v in pairs(ChildDevices) do
      if(v.ROMId == OWDevices[Count]["ROMId"]) then
--luup.log(OWSERVER_LOG_NAME.."Processing: "..OWDevices[Count]["ROMId"].."::"..v.Param.." == "..OWDevices[Count][v.Param])
        found = 1

        -- Process some special parameters here....
        if(v.Service == TEMPERATURE_SERVICE) then
          -- Celcius to Farhenheit conversion?
          if(v.Units == "F") then
            OWDevices[Count][v.Param] = celciusToF(OWDevices[Count][v.Param])
          end
        elseif(v.ServiceId == COUNTER_SERVICE) then
          -- Store the raw counter value
          luup.variable_set(v.Service, v.Variable, Average, v.Device)

          -- Counters...
          -- Calculate the counts per second and average this out.
          -- This allows the system to accommodate different sampling rates
          if(v.LastTime ~= nil) then

          end
        end

        -- Keep a loop buffer to allow rolling average filter
        v.History[v.Counter] = round(OWDevices[Count][v.Param],1)
        v.Counter = v.Counter + 1
        if(v.Counter > v.Average) then
          v.Counter = 1
          v.Record  = 1
        else
          v.Record  = 0
        end

        -- Store the current data
        if(v.Record == 1) then
          local AvCnt
          local Average
          Average = 0
          for AvCnt=1,v.Average do
            Average = Average + v.History[AvCnt]
          end
          Average = round(Average / v.Average, 1)

          luup.variable_set(v.Service, v.Variable, Average, v.Id)

          -- Power - Update watts
          if(v.Watts ~= nil) then
            if(Average == 0) then
              luup.variable_set(ENERGY_SERVICE, ENERGY_VARIABLE,       0, v.Id)
            else
              luup.variable_set(ENERGY_SERVICE, ENERGY_VARIABLE, v.Watts, v.Id)
            end
          end
        end

        -- Remember the last data
        v.LastData = OWDevices[Count][v.Param]
        v.LastTime = startTime
      end
    end

    -- Did we find a new device?
    if(found == 0) then
      if(NewDevices[OWDevices[Count]["ROMId"]] == nil) then
        NewDevices[OWDevices[Count]["ROMId"]] = OWDevices[Count]["Name"]
        luup.log("OWSERVER::: New device found "..OWDevices[Count]["ROMId"] .. " " ..OWDevices[Count]["Name"])
      end
    end
  end

--  luup.log(OWSERVER_LOG_NAME.."FINISH: "..os.clock())
--  luup.log(OWSERVER_LOG_NAME.."RunTime: "..(os.clock()-startTime))


  if(PollFastCounter > 0) then
    PollFastCounter = PollFastCounter - 1
    luup.call_timer('pollCycle', 1, tostring(POLL_FAST), "")
--    luup.log("OWSERVER: set timer "..tostring(POLL_FAST))
  else
    luup.call_timer('pollCycle', 1, tostring(SamplingPeriod), "")
--    luup.log("OWSERVER: set timer "..tostring(SamplingPeriod))
  end
--  luup.log("OWSERVER: poll end")
end

-- Get a list of channels that can be graphed
function incomingCtrl(lul_request, lul_parameters, lul_outputformat)
  luup.log(OWSERVER_LOG_NAME .. "incomingCtrl")

  local funct    = lul_parameters.funct
--  local service  = lul_parameters.service

  if(funct == "create") then
    local devices  = lul_parameters.cnt
    local  createDev = {}

    -- Receive the data from the UI and create the child devices
    for cnt = 1,devices do
      createDev[cnt] = {}
      createDev[cnt].ROMId   = lul_parameters["Rom"..cnt]
      createDev[cnt].Device  = tonumber(lul_parameters["Dev"..cnt])
      createDev[cnt].Service = tonumber(lul_parameters["Typ"..cnt])
--      luup.log(OWSERVER_LOG_NAME .. "Loop "..cnt)
--      luup.log(OWSERVER_LOG_NAME .. "Dev"..cnt..": " .. lul_parameters["Dev"..cnt])
--      luup.log(OWSERVER_LOG_NAME .. "Typ"..cnt..": " .. lul_parameters["Typ"..cnt])
--      luup.log(OWSERVER_LOG_NAME .. "ROM"..cnt..": " .. lul_parameters["Rom"..cnt])
    end

    CreateNewDevices(createDev)

    return "OK"
  elseif(funct == "getnew") then
    local DevList = {}
    local Cnt = 0

    for kNew, vNew in pairs(NewDevices) do
      for kDev, vDev in pairs(DeviceTable) do
        if(vDev.Device == vNew) then
          DevList[Cnt] = {}
          DevList[Cnt].ROMId  = kNew
          DevList[Cnt].Device = kDev
          Cnt = Cnt + 1
        end
      end
    end

    json = require("json")
    return json.encode(DevList)
  elseif(funct == "gettypes") then
    json = require("json")

    return json.encode(TypeTable)
  elseif(funct == "getdevcap") then
    json = require("json")

    return json.encode(DeviceTable)
  end
end



      -- function:  append
      -- parameters:  parent device (string or number),
      --        child ptr (binary object),
      --        id (string),
      --        description (string),
      --        device_type (string),
      --        device_filename (string),
      --        implementation_filename (string),
      --        parameters (string),
      --        embedded (boolean)
      --        [, invisible (boolean)]

function CreateNewDevices(createDev)

  local parameters = ""
  local children = luup.chdev.start(ParentDevice)

  -- Add in the existing children so we don't loose any when we sync!
  for k, v in pairs(ChildDevices) do
    parameters = OWSERVER_SERVICE..",ROMId="..v.ROMId.."\n"..OWSERVER_SERVICE..",Param="..v.Param.."\n"

    luup.chdev.append(ParentDevice, children,
      v.ROMId..":"..v.Param, "",
      v.Device, "", "", "", false)
  end

  for k, v in pairs(createDev) do
    if(v.Service > TYPE_IGNORE) then
      parameters = ""
      parameters = parameters..OWSERVER_SERVICE..",DeviceFile="..TypeTable[v.Service].DeviceFile.."\n"
      parameters = parameters..OWSERVER_SERVICE..",ROMId="     ..v.ROMId.."\n"
      parameters = parameters..OWSERVER_SERVICE..",Param="     ..DeviceTable[v.Device].Parameter.."\n"
      parameters = parameters..OWSERVER_SERVICE..",Average="   ..TypeTable[v.Service].Average.."\n"
      parameters = parameters..OWSERVER_SERVICE..",ServiceId=" ..TypeTable[v.Service].Service.."\n"
      parameters = parameters..OWSERVER_SERVICE..",Variable="  ..TypeTable[v.Service].Variable.."\n"
      parameters = parameters..OWSERVER_SERVICE..",Command="   ..DeviceTable[v.Device].Command.."\n"
      parameters = parameters..TypeTable[v.Service].Parameters
--luup.log(parameters)

      luup.chdev.append(ParentDevice, children,
        v.ROMId..":"..DeviceTable[v.Device].Parameter, DeviceTable[v.Device].Name.."["..v.ROMId.."]",
        TypeTable[v.Service].Device, TypeTable[v.Service].DeviceFile,
        "", parameters, false)
    end
  end

  luup.chdev.sync(ParentDevice, children)
end



----------------------------------------------
-- Helper functions, return what the swich is switching to
----------------------------------------------
function getPowerState( lul_device, lul_settings )
  local reverse = luup.variable_get("urn:micasaverde-com:serviceId:HaDevice1","ReverseOnOff",lul_device)
  local power = "0"

  -- If the new state is ON, or reverse logic and OFF
  if( lul_settings.newTargetValue=="1" or (lul_settings.newTargetValue=="0" and reverse=="1") ) then
    power = "1"
  end

  return power
end

function togglePowerState( lul_device, lul_settings )
  local reverse = luup.variable_get("urn:micasaverde-com:serviceId:HaDevice1","ReverseOnOff",lul_device)
  local power = "0"

  local value = luup.variable_get( "urn:upnp-org:serviceId:SwitchPower1", "Status", lul_device )

  -- If the current state is OFF, or reverse logic and ON
  if( value=="0" or (value=="1" and reverse=="1") ) then
    power = "1"
  end

  return power
end

-- devices.htm?rom=4300000200AD1928&variable=UserByte1&value=75
function sendCommand(Device, Value)
--  luup.log( OWSERVER_LOG_NAME .. "sendCommand: Device " .. Device .. " to "..Value)
  local lul_cmd = 'http://' .. luup.devices[ParentDevice].ip .. '/devices.htm?rom=' .. ChildDevices[Device].ROMId .. "&variable=" .. ChildDevices[Device].Command .. "&value=".. Value
--  luup.log( OWSERVER_LOG_NAME .. "sendCommand --> " .. lul_cmd)
  local code, res = luup.inet.wget(lul_cmd, OWServerTimeout, "", "")

  PollFastCounter = 6
  luup.call_timer('pollCycle', 1, tostring(POLL_FAST), "")
end

function setTarget(lul_device, lul_settings)
  sendCommand(lul_device, togglePowerState(lul_device, lul_settings))

  -- Return 5-job_WaitingForCallback, x second timeout
  return 4, 0
  -- 0 Waiting to start
  -- 2 Error (red in UI)
  -- 3 Job abborted (red in UI)
  -- 4 Job done (green in UI)
  -- 5 Waiting for callback (blue in UI)
end

function toggleState(lul_device, lul_settings)
  sendCommand(lul_device, togglePowerState(lul_device, lul_settings))

  return 4, 0
  -- 0 Waiting to start
  -- 2 Error (red in UI)
  -- 3 Job abborted (red in UI)
  -- 4 Job done (green in UI)
  -- 5 Waiting for callback (blue in UI)
end
