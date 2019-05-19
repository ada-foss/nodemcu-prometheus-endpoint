local i2c = require('i2c')
local ccs811 = { }

ccs811.read_co2 = function()
    i2c.start(0)
    i2c.address(0, 91, i2c.TRANSMITTER)
    i2c.write(0, 0x02)
    i2c.stop(0)
    i2c.start(0)
    i2c.address(0, 91, i2c.RECEIVER)
    local r = i2c.read(0, 2)
    i2c.stop(0)
    return r:byte(0,1)*256 + r:byte(1,2)
end

i2c.start(0)
i2c.address(0, 91, i2c.TRANSMITTER)
i2c.write(0, 0x01, 0x10)
i2c.stop(0)

return ccs811
