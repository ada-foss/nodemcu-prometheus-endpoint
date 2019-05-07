local spi = require('spi')

local SPI_BUS = 0
local SPI_CLOCKDIV = 800

local function read_adc(ce_pin, adc_id)
    spi.setup(SPI_BUS, spi.master, spi.CPOL_LOW, spi.CPHA_LOW, 10, SPI_CLOCKDIV)
    gpio.write(ce_pin, gpio.LOW)
    tmr.delay(1) -- allow time for CE_PIN to stay low
    read_cmd = (adc_id * 4) + 96
    local wrote = spi.send(SPI_BUS, [read_cmd])
    print(wrote)
    local read = spi.recv(SPI_BUS, 1)
    gpio.write(ce_pin, gpio.HIGH)
    print(read)
end

local function bind_to_adc(ce_pin, adc_id)
    gpio.mode(ce_pin, gpio.OUTPUT)
    gpio.write(ce_pin, gpio.HIGH)
    return function()
        return read_adc(ce_pin, adc_id)
    end
end

local mcp3008 = { }
mcp3008.bind_to_adc = bind_to_adc
return mcp3008
