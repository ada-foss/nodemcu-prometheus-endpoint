--local adc_experiment = require('adc_experiment')
local temperature = require('temperature')
local mcp3008 = require('mcp3008')
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

-- pin 2, GPIO4, D2
local adc_pin = 2
for i=0,7 do
    metrics[('mcp3008_reading{chip="%s",pin="%s"}'):format(adc_pin, i)] = mcp3008.bind_to_adc(adc_pin, i)
end

return metrics
