local adc_experiment = require('adc_experiment')
local metrics = { }

metrics.nodemcu_uptime_seconds = tmr.time
metrics.nodemcu_received_signal_strength_indicator = wifi.sta.getrssi
metrics.nodemcu_available_heap_bytes = node.heap

-- ADC metrics
metrics.nodemcu_experimental_adc_reading_microseconds = adc_experiment.get_last_reading
metrics.nodemcu_experimental_adc_mean_microseconds = adc_experiment.get_mean_reading
metrics.nodemcu_experimental_adc_high_microseconds = adc_experiment.get_high_reading
metrics.nodemcu_experimental_adc_low_microseconds = adc_experiment.get_low_reading
metrics.nodemcu_experimental_adc_reading_count = adc_experiment.get_adc_reading_count

-- temperature metrics
metrics.nodemcu_experimental_temperature_reading_microseconds = adc_experiment.get_last_temperature_reading
metrics.nodemcu_experimental_temperature_reading_count = adc_experiment.get_temp_reading_count

return metrics
