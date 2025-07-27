-- Integration Patterns in Lua

-- Calling C from Lua (LuaJIT FFI)
-- local ffi = require 'ffi'
-- ffi.cdef[[ int printf(const char *fmt, ...); ]]
-- ffi.C.printf('Hello from C!\n')

-- REST API call (with luasocket)
-- local http = require('socket.http')
-- local body, code = http.request('http://example.com')
-- print('Status:', code)
-- print('Body:', body)

-- Microservice communication (via Redis pub/sub)
-- os.execute('redis-cli PUBLISH mychannel "Hello"')

-- gRPC simulation (product scenario)
local function grpcCall(service, method, data)
    print('gRPC call:', service, method, data)
    -- Simulate response
    return { status = 'OK', data = 'response' }
end
local resp = grpcCall('UserService', 'GetUser', { id = 123 })
print('gRPC response:', resp.status, resp.data)

-- Event-driven integration (enterprise scenario)
local eventBus = { listeners = {} }
function eventBus:on(event, fn)
    self.listeners[event] = self.listeners[event] or {}
    table.insert(self.listeners[event], fn)
end
function eventBus:emit(event, data)
    for _, fn in ipairs(self.listeners[event] or {}) do fn(data) end
end
eventBus:on('user.created', function(user) print('User created:', user.name) end)
eventBus:emit('user.created', { name = 'Alice' })

-- Webhook handler (product scenario)
local function handleWebhook(payload)
    local event = payload.type
    if event == 'payment.success' then
        print('Payment successful:', payload.amount)
    elseif event == 'user.signup' then
        print('New user:', payload.email)
    else
        print('Unknown webhook event:', event)
    end
end
handleWebhook({ type = 'payment.success', amount = 100 })
handleWebhook({ type = 'user.signup', email = 'test@example.com' })
