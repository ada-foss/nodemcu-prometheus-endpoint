print('delaying...')
local flash_count = 20
local LED_PIN = 4

function flash(self)
    if flash_count % 2 == 0 then
        gpio.write(LED_PIN, gpio.LOW)
    else
        gpio.write(LED_PIN, gpio.HIGH)
    end

    if flash_count == 0 then
        self:unregister()
        print('delay period expired, executing application.lua')

        -- why is this required?
        -- nobody knows
        -- it seems to fix things
        local t = require('ds18b20')

        dofile('application.lc')
    else
        flash_count = flash_count - 1
        self:start()
    end
end

gpio.mode(LED_PIN, gpio.OUTPUT)
local tmr_on = tmr.create():alarm(250, tmr.ALARM_SEMI, flash)

do
    local SPI_CLOCKDIV = 80

    local spi = require('spi')
    local _, config = pcall(require, 'config')

    gpio.mode(config.shift_register_rclk, gpio.OUTPUT)
    gpio.write(config.shift_register_rclk, gpio.LOW)
    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 10, SPI_CLOCKDIV, spi.FULLDUPLEX)
    spi.send(1, config.shift_register or {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
    gpio.write(config.shift_register_rclk, gpio.HIGH)
    gpio.write(config.shift_register_rclk, gpio.LOW)
end
