
print('initializing ADC network module..')
local adc_network = { }

local PIN_SENSOR = 10 -- GPIO1
adc_network.rest_period = 1000 -- milliseconds
local adcs = {
adc1 = {
  pin = 5, -- GPIO14
  off = gpio.HIGH,
  on = gpio.LOW,
}
adc2 = {
  pin = 6 -- GPIO12
  off = gpio.HIGH,
  on = gpio.LOW,
}
adc3 = {
  pin = 7 -- GPIO13
  off = gpio.HIGH,
  on = gpio.LOW,
}
res1 = {
  pin = 8 -- GPIO15
  off = gpio.LOW,
  on = gpio.HIGH,
}
res2 = {
  pin = 9 -- GPIO3
  off = gpio.LOW,
  on = gpio.HIGH,
}
}
adc_network.adcs = adcs

local sequence = { adcs.adc1, adcs.adc1, adcs.adc1, adcs.adc1, adcs.adc1, adcs.adc1, adcs.adc1, adcs.adc1, adcs.adc1, adcs.adc1, adcs.res1 }
local sequence_position = 0
local reading_inhibit = true
local this_reading_start_time

local alarm_trigger_reading = tmr.create()
local alarm_trigger_timeout = tmr.create()

local function await_next_reading()
    sequence_position = sequence_position + 1
    if sequence_position > #sequence then
        sequence_position = 1
    end

    alarm_trigger_reading:start()
end

local function trigger_reading()
    local adc = sequence[sequence_position]

    alarm_trigger_timeout:interval(adc.timeout)
    reading_inhibit = false

    alarm_trigger_timeout:start()
    this_reading_start_time = tmr.now()
    gpio.write(adc.pin, adc.on)
end

local function handle_reading(level, when)
    if not reading_inhibit then
        alarm_trigger_timeout:stop()
        reading_inhibit = true
        local adc = sequence[sequence_position]
        gpio.write(adc.pin, adc.off)

        adc.readings[#adc.readings+1] = when - this_reading_start_time
        if #adc.readings > 10 then
            table.remove(adc.readings, 1)
        end

        await_next_reading()
    end
end

local function timeout_reading()
    reading_inhibit = true
    local adc = sequence[sequence_position]
    gpio.write(adc.pin, adc.off)
    adc.readings[#adc.readings+1] = time.now() - this_reading_start_time

    -- next reading
    await_next_reading()
end

adc_network.init = function()
    gpio.mode(PIN_SENSOR, gpio.INT, gpio.PULLUP)
    for _, adc in pairs(adcs) do
        gpio.mode(adc.pin, gpio.OUTPUT)
        gpio.write(adc.pin, adc.off)

        adc.timeout = adc.timeout or 100 -- 100ms default
        adc.readings = { (adc.timeout * 1000) + 1 }
    end

    alarm_trigger_reading:register(adc_network.rest_period, tmr.ALARM_SEMI, trigger_reading)
    alarm_trigger_timeout:register(10000, tmr.ALARM_SEMI, timeout_reading)

    gpio.trig(PIN_SENSOR, 'down', handle_reading)
    await_next_reading()
end

return adc_network
