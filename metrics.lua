local metrics = { }

metrics.nodemcu_uptime_seconds = tmr.time
metrics.nodemcu_received_signal_strength_indicator = wifi.sta.getrssi
metrics.nodemcu_available_heap_bytes = node.heap

return metrics
