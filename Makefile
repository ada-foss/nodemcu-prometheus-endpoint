cross-compiler = ${HOME}/project/nodemcu-firmware/luac.cross
uploader = sudo nodemcu-uploader --port /dev/ttyUSB3
targets = .uploaded/init.lua .uploaded/application.lc .uploaded/bme280_binding.lc .uploaded/ccs811.lc .uploaded/config.lc .uploaded/ds18b20.lc .uploaded/http_server.lc .uploaded/mcp3008.lc .uploaded/metrics.lc .uploaded/prometheus_endpoint.lc .uploaded/shift_register.lc .uploaded/temperature.lc

%.lc: %.lua
	${cross-compiler} -o $@ $<

.uploaded/init.lua:
	${uploader} upload init.lua
	mkdir -p .uploaded
	touch .uploaded/init.lua

.uploaded/%.lc: %.lc
	${uploader} upload $<
	mkdir -p .uploaded
	touch .uploaded/$<

file_list:
	${uploader} file list

upload: $(targets)

.PHONY: file_list upload
