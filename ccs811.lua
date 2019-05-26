local i2c = require('i2c')
local bit = require('bit')
local tmr = require('tmr')
local ccs811 = { }

local cache = { }
local cache_expiry = 10
local cache_age = -1 - cache_expiry

local function i2c_read_reg(addr, reg, len)
    i2c.start(0)
    i2c.address(0, addr, i2c.TRANSMITTER)
    i2c.write(0, reg)
    i2c.stop(0)

    i2c.start(0)
    i2c.address(0, addr, i2c.RECEIVER)
    local r = i2c.read(0, len)
    i2c.stop(0)
    return r
end

local function update_cache()
    if tmr.time() - cache_age > cache_expiry then
        local r = i2c_read_reg(90, 0x02, 6)

        cache.co2 = r:byte(0,1)*256 + r:byte(1,2)
        cache.tvoc = r:byte(2,3)*256 + r:byte(3,4)
        cache.status = r:byte(5,6)
        cache.error_id = r:byte(4,5)

        cache_age = tmr.time()
    end
end

ccs811.read_co2 = function()
    update_cache()
    return cache.co2
end

ccs811.read_tvoc = function()
    update_cache()
    return cache.tvoc
end

ccs811.read_status = function()
    update_cache()
    return cache.status
end

ccs811.read_error_id = function()
    update_cache()
    return cache.error_id
end

ccs811.read_meas_mode = function()
    return i2c_read_reg(90, 0x01, 1):byte(0,1)
end

ccs811.read_error_code = function()
    return i2c_read_reg(90, 0xE0, 1):byte(0,1)
end

print("initializing ccs811...")

local status = i2c_read_reg(90, 0x00, 1):byte(0,1)
print(string.format("     status register: 0x%.2x", status))

local app_valid = bit.band(status, 0x10)

if not app_valid then
    print('ERROR: CCS811 firmware not valid, not starting CCS811')
else
    print("starting ccs811...")
    -- application start register
    i2c.start(0)
    i2c.address(0, 90, i2c.TRANSMITTER)
    i2c.write(0, 0xF4)
    i2c.stop(0)

    -- measurement mode register
    i2c.start(0)
    i2c.address(0, 90, i2c.TRANSMITTER)
    i2c.write(0, 0x01, 0x10)
    i2c.stop(0)

    -- re-read status
    status = i2c_read_reg(90, 0x00, 1):byte(0,1)
end

print(string.format("     status register: 0x%.2x", status))
print(string.format("   error id register: 0x%.2x", i2c_read_reg(90, 0xE0, 1):byte(0,1)))

return ccs811
