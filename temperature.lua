print('loading ds18b20..')
local ds18b20 = require('ds18b20')
local ds18b20_pin = 3 -- GPIO0, D3

local last_reading = { }
local main_timer = tmr.create()

local function readout(temp)
    last_reading = temp
end

local function refresh_readings(my_timer)
    ds18b20:read_temp(readout, ds18b20_pin, ds18b20.C)
end

local function ensure_main_timer_running()
    local running, _ = main_timer:state()
    if not running then
        main_timer:start()
    end
end

local function self_register(metrics)

  local function first_readout(temp)
    print('ds18b20 bus scan complete:')

    print("  total number of DS18B20 sensors: ".. #ds18b20.sens)
    for i, s in ipairs(ds18b20.sens) do
      local s_addr = ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(s:byte(1,8))
      print(string.format("  sensor #%d address: %s%s",  i, s_addr, s:byte(9) == 1 and " (parasite)" or ""))
    end

    print('first ds18b20 readings:')
    for addr, temp in pairs(temp) do
      local s_addr = ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(addr:byte(1,8))
      print(string.format("  sensor %s: %s °C", s_addr, temp))

      local function temp_sensor_x()
          ensure_main_timer_running()
          return last_reading[addr]
      end
      metrics['temperature_reading_celsius{address="'..s_addr..'"}'] = temp_sensor_x
    end

    readout(temp)
  end

  ds18b20:read_temp(first_readout, ds18b20_pin, ds18b20.C, 'force_search')
end

-- 3 = GPIO0, D3
--ds18b20:enable_debug()
main_timer:register(1000, tmr.ALARM_SEMI, refresh_readings)

local temperature = { }
temperature.self_register = self_register
return temperature
