local bme280_binding = { }
do
    local bme280 = require('bme280')

    bme280_binding.temperature = function()
        local t, _ = bme280.temp()
        return (t or -27400) / 100
    end

    bme280_binding.pressure = function()
        local p, _ = bme280.baro()
        return (p or -1000) / 1000
    end

    bme280_binding.humidity = function()
        local h, _ = bme280.humi()
        return (h or -1000) / 1000
    end

    bme280.setup()
end
return bme280_binding
