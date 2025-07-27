-- Other Cool Lua Use Cases (Non-game)

-- HTTP server (with luasocket)
-- local socket = require('socket')
-- local server = socket.bind('*', 8080)
-- while true do
--     local client = server:accept()
--     client:send('HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nHello World!')
--     client:close()
-- end

-- Data transformation pipeline
local function pipe(value, ...)
    for _, fn in ipairs({...}) do value = fn(value) end
    return value
end
print(pipe(5, function(x) return x * 2 end, function(x) return x + 1 end))

-- CLI tool pattern
local args = {...}
if #args > 0 then print('Args:', table.concat(args, ', ')) end

-- Plugin loader
local plugins = { 'pluginA', 'pluginB' }
for _, p in ipairs(plugins) do print('Loading:', p) end
