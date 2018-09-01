
print('initializing experimental ADC..')

local PIN_TRIGGER = 9
local PIN_SENSOR = 1

-- configure pins for the experimental ADC
gpio.mode(PIN_SENSOR, gpio.INT, gpio.PULLUP)

gpio.mode(PIN_TRIGGER, gpio.OUTPUT)
gpio.write(PIN_TRIGGER, gpio.HIGH)

print('- pins configured, building alarms')

-- build alarms
local alarm_trigger_reading = tmr.create()
local reading_timer_start
local last_reading = 0
local readings = { }
local reading_inhibit = true

local function trigger_reading()
    -- print('+A trigger!')
    reading_inhibit = false
    reading_timer_start = tmr.now()
    gpio.write(PIN_TRIGGER, gpio.LOW)
end

local function handle_reading(level, when)
    if not reading_inhibit then
        -- print('+A interrupt')
        reading_inhibit = true
        gpio.write(PIN_TRIGGER, gpio.HIGH)

        last_reading = when - reading_timer_start
        readings[#readings+1] = last_reading
        if #readings > 10 then -- don't keep more than ten
            table.remove(readings, 1)
        end
        -- print('+A '..last_reading)
        alarm_trigger_reading:start()
    end
end
print('- setting pin interrupt')
gpio.trig(PIN_SENSOR, "down", handle_reading)

local function get_last_reading()
    return last_reading
end

local function get_mean_reading()
    local total = 0
    for _, v in ipairs(readings) do
        total = total + v
    end
    return total / 10
end

local function get_sorted_copy(t)
    local new = { }
    for i, v in ipairs(t) do
        new[i] = v
    end
    table.sort(new)
    return new
end

local function get_low_reading()
    local sorted = get_sorted_copy(readings)
    return (sorted[2] or -1)
end

local function get_high_reading()
    local sorted = get_sorted_copy(readings)
    return (sorted[#sorted-1] or -1)
end

alarm_trigger_reading:alarm(1000, tmr.ALARM_SEMI, trigger_reading)

print('- created alarm')

local adc = { }
adc.get_last_reading = get_last_reading
adc.get_mean_reading = get_mean_reading
adc.get_low_reading = get_low_reading
adc.get_high_reading = get_high_reading
return adc
