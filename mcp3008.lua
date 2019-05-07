local spi = require('spi')

local SPI_BUS = 1
local SPI_CLOCKDIV = 80

local function read_adc(ce_pin, adc_id)
    spi.setup(SPI_BUS, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 10, SPI_CLOCKDIV, spi.FULLDUPLEX)
    gpio.write(ce_pin, gpio.LOW)
    local sent, returned = spi.send(SPI_BUS, {adc_id*4+96, 0})
    gpio.write(ce_pin, gpio.HIGH)

    if sent < 1 then
        return -1
    end

    return returned[2]
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
