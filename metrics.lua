
print('loading all metrics..')

do
    local i2c = require('i2c')
    -- sda, GPIO4, D2, pin 2
    -- scl, GPIO5, D1, pin 1
    i2c.setup(0, 2, 1, i2c.SLOW)
end

print('before loading any modules:', node.heap())
local temperature = require('temperature')
print('after temperature:', node.heap())
local mcp3008 = require('mcp3008')
--local bme280_binding = require('bme280_binding')
print('after mcp3008:', node.heap())
local ccs811 = require('ccs811')
print('after ccs811:', node.heap())
local metrics = { }

metrics.uptime_seconds = tmr.time
metrics.received_signal_strength_indicator = wifi.sta.getrssi
metrics.available_heap_bytes = node.heap

-- ds18b20 metrics
temperature.self_register(metrics)

---- pin 2, GPIO4, D2
--local adc_pin = 2
-- pin 8, GPIO15, D8
local adc_pin = 8
for i=0,7 do
    metrics[('mcp3008_reading{chip="%s",pin="%s"}'):format(adc_pin, i)] = mcp3008.bind_to_adc(adc_pin, i)
end

--metrics.bme280_temperature_celsius = bme280_binding.temperature
--metrics.bme280_pressure_hectopascals = bme280_binding.pressure
--metrics.bme280_humidity_percentage = bme280_binding.humidity

metrics.ccs811_co2_ppm = ccs811.read_co2
metrics.ccs811_tvoc_ppb = ccs811.read_tvoc
metrics.ccs811_status = ccs811.read_status

return metrics
