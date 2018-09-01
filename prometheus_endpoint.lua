--------------------------------------------------------------------------------
-- HTTP server for my nodeMCU application with prometheus endpoint
-- largely copied from http-example.lua in node-mcu-firmware project
-- Berin Smaldon <noodels555@gmail.com>
-------------------------------------------------------------------------------
-- require metrics -> load metrics with callbacks for each metric
local metrics = require('metrics')

print('loaded metric callbacks, building http server..')

require('http_server2').createServer(555, function(state)
    -- analyse method and url
    print('+R', state.method, state.url, node.heap())

    -- TODO: select handlers based on url?

    -- setup handler for headers
    -- req.onheader = function(self, name, value)
    -- end

    -- setup handler for body
    -- commented out because prometheus endpoints don't care about the body(?)
    -- req.ondata = function(self, chunk)
    --     print("+B", chunk and #chunk, node.heap())
    --     -- request ended?
    --     if not chunk then
    --         -- respond
    --         res:send(nil, 200)
    --         res:send_header('Connection', 'close')
    --         res:send('Hello, world!')
    --         res:finish()
    --     end
    -- end

    -- TODO: send metrics individually with res:send
    -- res:send("# Hello, world!\n")
    -- for name, callback in pairs(metrics) do
    --     res:send(name..' '..callback().."\n")
    -- end
    -- res:finish()

    -- defines callback to generate body
    local send_queue = { }

    for k, _ in pairs(metrics) do
        send_queue[#send_queue+1] = k
    end

    local function main_loop(connection)
        local k = table.remove(send_queue, 1)
        if k then
            connection:send(k..' '..metrics[k]().."\r\n", main_loop)
        else
            connection:close()
            collectgarbage()
        end
    end

    return main_loop
end )

print('READY!')
