--------------------------------------------------------------------------------
-- HTTP server for my nodeMCU application with prometheus endpoint
-- largely copied from http-example.lua in node-mcu-firmware project
-- Berin Smaldon <noodels555@gmail.com>
-------------------------------------------------------------------------------
-- require metrics -> load metrics with callbacks for each metric
local metrics = require('metrics')
local shift_register = require('shift_register')

print('loaded metric callbacks, building http server..')
collectgarbage()

local get_metrics = function(state)
    state.send_headers['content-type'] = 'text/plain; version=0.0.1; charset=utf-8'

    -- defines callback to generate body
    local send_queue = { }

    for k, _ in pairs(metrics) do
        send_queue[#send_queue+1] = k
    end

    local function main_loop(connection)
        local k = table.remove(send_queue, 1)
        if k then
            connection:send('nodemcu_'..k..' '..metrics[k]().."\n", main_loop)
        else
            connection:close()
            collectgarbage()
        end
    end

    return main_loop
end

local put_sreg = function(state)
    local i, _, f, pin_s, level_s, duration_s = state.buffer:find('^(%a)%a+ (%d+) (%d) *(%d*)')

    local pin = tonumber(pin_s)
    local duration = tonumber(duration_s)
    local level = tonumber(level_s)

    --print('pulse:', pin, duration, level)
    if level == nil or level < 0 or level > 1 or (f == 'p' and duration == nil) then
        state.response_code = 400
        state.response = 'Bad Request'
    end

    if f == 'p' then
        shift_register.pulse(pin, duration, level)
    else
        print('+S', 'set', pin, level)
        shift_register.set(pin, level)
    end

    return function(connection)
        connection:close()
        collectgarbage()
    end
end

local give_404 = function(state)
    state.response_code = 404
    state.response = 'Not Found'

    return function(connection)
        connection:close()
        collectgarbage()
    end
end

local uris = {
    metrics = get_metrics,
    sreg = put_sreg
}

require('http_server').createServer(555, function(state)
    -- analyse method and url
    print('+R', state.method, state.url)

    local _, _, uri_key = state.url:find('^/([^/]+)')
    local to_call = uris[uri_key] or give_404
    return to_call(state)
end )

print('READY!')
