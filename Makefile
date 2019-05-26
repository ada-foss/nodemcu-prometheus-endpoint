cross-compiler = ${HOME}/project/nodemcu-firmware/luac.cross
uploader = sudo nodemcu-uploader --port /dev/ttyUSB3

%.lc: %.lua
	${cross-compiler} -o $@ $<

upload_%: %.lc
	${uploader} upload $<

file_list:
	${uploader} file list


.PHONY: file_list
