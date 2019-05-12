
do
    local i2c = require('i2c')
    -- sda, GPIO4, D2, pin 2
    -- scl, GPIO5, D1, pin 1
    i2c.setup(0, 2, 1, i2c.SLOW)
end

--local adc_experiment = require('adc_experiment')
local temperature = require('temperature')
local mcp3008 = require('mcp3008')
local bme280_binding = require('bme280_binding')
local metrics = { }

metrics.uptime_seconds = tmr.time
metrics.received_signal_strength_indicator = wifi.sta.getrssi
metrics.available_heap_bytes = node.heap

-- ADC metrics
--metrics.nodemcu_experimental_adc_reading_microseconds = adc_experiment.get_last_reading
--metrics.nodemcu_experimental_adc_mean_microseconds = adc_experiment.get_mean_reading
--metrics.nodemcu_experimental_adc_high_microseconds = adc_experiment.get_high_reading
--metrics.nodemcu_experimental_adc_low_microseconds = adc_experiment.get_low_reading
--metrics.nodemcu_experimental_adc_reading_count = adc_experiment.get_adc_reading_count
--
---- temperature metrics
--metrics.nodemcu_experimental_temperature_reading_microseconds = adc_experiment.get_last_temperature_reading
--metrics.nodemcu_experimental_temperature_reading_count = adc_experiment.get_temperature_reading_count

-- ds18b20 metrics
temperature.self_register(metrics)

---- pin 2, GPIO4, D2
--local adc_pin = 2
-- pin 8, GPIO15, D8
local adc_pin = 8
for i=0,7 do
    metrics[('mcp3008_reading{chip="%s",pin="%s"}'):format(adc_pin, i)] = mcp3008.bind_to_adc(adc_pin, i)
end

metrics.bme280_temperature_celsius = bme280_binding.temperature
metrics.bme280_pressure_hectopascals = bme280_binding.pressure
metrics.bme280_humidity_percentage = bme280_binding.humidity

return metrics
