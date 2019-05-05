--------------------------------------------------------------------------------
-- HTTP server for my nodeMCU application with prometheus endpoint
-- largely copied from http-example.lua in node-mcu-firmware project
-- Berin Smaldon <noodels555@gmail.com>
-------------------------------------------------------------------------------
-- require metrics -> load metrics with callbacks for each metric
local metrics = require('metrics')

print('loaded metric callbacks, building http server..')

require('http_server').createServer(555, function(state)
    -- analyse method and url
    print('+R', state.method, state.url)

    state.send_headers['content-type'] = 'text/plain; version=0.0.1; charset=utf-8'

    -- defines callback to generate body
    local send_queue = { }

    for k, _ in pairs(metrics) do
        send_queue[#send_queue+1] = k
    end

    local function main_loop(connection)
        local k = table.remove(send_queue, 1)
        if k then
            connection:send(k..' '..metrics[k]().."\n", main_loop)
        else
            connection:close()
            collectgarbage()
        end
    end

    return main_loop
end )

print('READY!')
