local CRLF = "\r\n"

local http = { }
do
    -- received header callbacks
    http.recv_header_callbacks = { }

    http.recv_header_callbacks['content-length'] = function(state, content_length)
        state.content_length = content_length
    end

    --
    local respond = function(connection, state)
        -- pass collected information back to the handler
        -- allow it to register headers and returns a function that
        -- shall generate a response
        state.send_headers = { }
        local sent_callback = state.handler(state)

        -- generate response header
        local header = 'HTTP/1.1 '..(state.response_code or 200)..' '..(state.response or 'OK')..CRLF
        for k, v in pairs(state.send_headers) do
            header = header..k..': '..v..CRLF
        end

        -- send response headers with callback to generate body
        connection:send(header..CRLF, sent_callback)
    end

    -- receive handler
    local receive = function(connection, state)
        if state.awaiting_bytes > 0 then
            state.awaiting_bytes = state.content_length - #state.buffer

            if state.awaiting_bytes < 1 then
                respond(connection, state)
            end
        end

        local nl_index = state.buffer:find("\r\n")
        while nl_index do
            local line = state.buffer:sub(1, nl_index - 1)
            state.buffer = state.buffer:sub(nl_index + 2)

            if not state.method then
                _, _, state.method, state.url = line:find("^([A-Z]+) (.-) HTTP/1.1$")
            elseif #line > 0 then
                -- parse header
                local _, _, k, v = line:find("^([%w-]+):%s*(.+)")
                if k and v then
                    k = k:lower()
                    if http.recv_header_callbacks[k] then
                        http.recv_header_callbacks[k](state, v)
                    else
                        -- print('unhandled header callback: '..k)
                    end
                else
                    print('warning, malformed header: '..line)
                end
            else
                -- at this point have now received a blank line
                -- for k, v in pairs(state) do
                --     print(k..':'..tostring(v))
                -- end

                if state.content_length then
                    state.awaiting_bytes = state.content_length - #state.buffer
                end

                if state.awaiting_bytes < 1 then
                    respond(connection, state)
                end
            end

            nl_index = state.buffer:find("\r\n")
        end
    end

    -- HTTP parser
    local http_handler = function(handler)
        return function(conn)

            local state = {
                buffer = '',
                handler = handler,
                awaiting_bytes = 0
            }
            local onreceive = function(c, chunk)
                state.buffer = state.buffer .. chunk
                return receive(c, state)
            end

            conn:on('receive', onreceive)
            conn:on('disconnection', ondisconnect)
        end
    end

    -- HTTP server
    local srv
    local createServer = function(port, handler)
        if srv then srv:close() end
        srv = net.createServer(net.TCP, 5)
        srv:listen(port, http_handler(handler))
    end
    http.createServer = createServer
end
return http
