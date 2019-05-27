local spi = require('spi')
local gpio = require('gpio')
local bit = require('bit')
local tmr = require('tmr')
local config = require('config')

function index_pin(pin)
    local n = 1
    while pin > 9 do
        n = n + 1
        pin = pin - 10
    end
    return pin, n
end

local shift_register = { }
shift_register.cache = config.shift_register or { 0x00, 0x00 }
shift_register.timers = { }

shift_register.flush = function()
    spi.send(1, shift_register.cache)
    gpio.write(config.shift_register_rclk, gpio.HIGH)
    gpio.write(config.shift_register_rclk, gpio.LOW)
end

shift_register.set = function(pin, level)
    local p, n = index_pin(pin)

    if shift_register.timers[pin] then
        shift_register.timers[pin]:stop()
        shift_register.timers[pin]:unregister()
        shift_register.timers[pin] = nil
    end

    if level == 1 then
        shift_register.cache[n] = bit.set(shift_register.cache[n], p)
    else
        shift_register.cache[n] = bit.clear(shift_register.cache[n], p)
    end

    shift_register.flush()
end

shift_register.pulse = function(pin, duration, level)
    local end_level = bit.bxor(level, 1)

    print('+S', 'start', pin, duration, level)
    shift_register.set(pin, level)

    shift_register.timers[pin] = tmr.create()
    shift_register.timers[pin]:alarm(duration, tmr.ALARM_SINGLE, function()
        print('+S', 'end', pin, duration, end_level)
        shift_register.set(pin, end_level)
    end)

end

--gpio.mode(config.shift_register_rclk, gpio.OUTPUT)

return shift_register
