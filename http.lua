--------------------------------------------------------------------------------
-- HTTP server for my nodeMCU application with prometheus endpoint
-- largely copied from http-example.lua in node-mcu-firmware project
-- Berin Smaldon <noodels555@gmail.com>
-------------------------------------------------------------------------------
-- require metrics -> load metrics with callbacks for each metric
-- require('metrics')

require("http").createServer(555, function(req, res)
    -- analyse method and url
    print('+R', req.method, req.url, node.heap())

    -- TODO: select handlers based on url?

    -- setup handler for headers
    req.onheader = function(self, name, value)
    end

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
    res:finish()

end
