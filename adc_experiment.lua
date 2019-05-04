
print('initializing experimental ADC..')

local PIN_TRIGGER = 9 -- GPIO3, RX
local PIN_TEMP = 2 -- GPIO4, D2
local PIN_SENSOR = 1 -- GPIO5, D1

-- configure pins for the experimental ADC
gpio.mode(PIN_SENSOR, gpio.INT, gpio.PULLUP)

gpio.mode(PIN_TRIGGER, gpio.OUTPUT)
gpio.mode(PIN_TEMP, gpio.OUTPUT)
gpio.write(PIN_TRIGGER, gpio.HIGH)
gpio.write(PIN_TEMP, gpio.LOW)

print('- pins configured, building alarms')

-- build alarms
local reading_counter = 0
local alarm_trigger_reading = tmr.create()
local reading_timer_start
local adc_last_reading = 0
local temp_reading = 0
local adc_readings = { }
local reading_inhibit = true
local adc_reading_count = 0
local temp_reading_count = 0

local function trigger_reading()
    reading_inhibit = false
    if reading_counter % 11 == 0 then
        -- read temperature sensor occasionally
        -- print('+T trigger!')
        reading_timer_start = tmr.now()
        gpio.write(PIN_TEMP, gpio.HIGH)
    else
        -- read ADC
        -- print('+A trigger!')
        reading_timer_start = tmr.now()
        gpio.write(PIN_TRIGGER, gpio.LOW)
    end
end

local function handle_reading(level, when)
    if not reading_inhibit then
        -- print('+A interrupt')
        reading_inhibit = true
        gpio.write(PIN_TRIGGER, gpio.HIGH)
        gpio.write(PIN_TEMP, gpio.LOW)

        if reading_counter % 11 == 0 then
            temp_reading = when - reading_timer_start
            reading_counter = 1
            temp_reading_count = temp_reading_count + 1
            -- print('+T '..temp_reading)
        else
            adc_last_reading = when - reading_timer_start
            adc_readings[#adc_readings+1] = adc_last_reading
            if #adc_readings > 10 then -- don't keep more than ten
                table.remove(adc_readings, 1)
            end
            reading_counter = reading_counter + 1
            adc_reading_count = adc_reading_count + 1
            -- print('+A '..adc_last_reading)
        end
        alarm_trigger_reading:start()
    end
end
print('- setting pin interrupt')
gpio.trig(PIN_SENSOR, "down", handle_reading)


-- ADC accessor functions
local function get_last_reading()
    return adc_last_reading
end

local function get_mean_reading()
    local total = 0
    for _, v in ipairs(adc_readings) do
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
    local sorted = get_sorted_copy(adc_readings)
    return (sorted[2] or -1)
end

local function get_high_reading()
    local sorted = get_sorted_copy(adc_readings)
    return (sorted[#sorted-1] or -1)
end

local function get_adc_reading_count()
    return adc_reading_count
end

-- temperature sensor accessor functions
local function get_last_temperature_reading()
    return temp_reading
end

local function get_temperature_reading_count()
    return temp_reading_count
end

alarm_trigger_reading:alarm(1000, tmr.ALARM_SEMI, trigger_reading)

print('- created alarm')

local adc = { }
adc.get_last_reading = get_last_reading
adc.get_mean_reading = get_mean_reading
adc.get_low_reading = get_low_reading
adc.get_high_reading = get_high_reading
adc.get_adc_reading_count = get_adc_reading_count

adc.get_last_temperature_reading = get_last_temperature_reading
adc.get_temperature_reading_count = get_temperature_reading_count
return adc
