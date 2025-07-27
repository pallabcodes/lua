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

-- Workflow orchestration (enterprise scenario)
local function createWorkflow()
    local steps = {}
    local workflow = {}
    
    function workflow.step(name, fn)
        table.insert(steps, { name = name, fn = fn })
        return workflow
    end
    
    function workflow.run(data)
        local result = data
        for _, step in ipairs(steps) do
            print('Executing step:', step.name)
            result = step.fn(result)
        end
        return result
    end
    
    return workflow
end

local wf = createWorkflow()
    :step('validate', function(x) print('Validating:', x); return x end)
    :step('transform', function(x) return x * 2 end)
    :step('save', function(x) print('Saving:', x); return x end)
print('Workflow result:', wf.run(10))

-- Error recovery (product scenario)
local function withRecovery(fn, recovery)
    local ok, result = pcall(fn)
    if ok then return result else return recovery() end
end
local result = withRecovery(
    function() error('Operation failed') end,
    function() print('Recovering...'); return 'default' end
)
print('Recovery result:', result)

-- Multi-service chaining (enterprise scenario)
local services = {
    auth = function(token) print('Auth service:', token); return { valid = true } end,
    user = function(auth) print('User service'); return { id = 123, name = 'Alice' } end,
    log = function(user) print('Log service:', user.name); return true end
}
local function chainServices(token)
    local auth = services.auth(token)
    if not auth.valid then return nil, 'Auth failed' end
    local user = services.user(auth)
    services.log(user)
    return user
end
local user, err = chainServices('abc123')
print('Chain result:', user and user.name or err)
