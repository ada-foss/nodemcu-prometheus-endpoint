local metrics = { }

metrics.nodemcu_uptime_seconds = tmr.time
metrics.nodemcu_received_signal_strength_indicator = wifi.sta.getrssi

return metrics
