-- Concurrency and Parallelism in Lua

-- Coroutine basics
local co = coroutine.create(function()
    for i = 1, 3 do
        print("Coroutine step", i)
        coroutine.yield()
    end
end)
while coroutine.status(co) ~= "dead" do
    coroutine.resume(co)
end

-- Producer-consumer with coroutines
local queue = {}
local function producer()
    for i = 1, 5 do
        table.insert(queue, i)
        print("Produced", i)
        coroutine.yield()
    end
end
local function consumer()
    while #queue > 0 do
        local item = table.remove(queue, 1)
        print("Consumed", item)
        coroutine.yield()
    end
end
local p = coroutine.create(producer)
local c = coroutine.create(consumer)
for _ = 1, 5 do coroutine.resume(p); coroutine.resume(c) end

-- Parallelism (using Lua Lanes or os.execute for multi-process)
-- Example: os.execute('lua worker.lua &')

-- Thread pool simulation (enterprise scenario)
local function createThreadPool(size)
    local pool = { tasks = {}, workers = {} }
    for i = 1, size do
        pool.workers[i] = coroutine.create(function()
            while true do
                if #pool.tasks > 0 then
                    local task = table.remove(pool.tasks, 1)
                    task()
                end
                coroutine.yield()
            end
        end)
    end
    return pool
end
local pool = createThreadPool(3)
table.insert(pool.tasks, function() print('Task 1 executed') end)
table.insert(pool.tasks, function() print('Task 2 executed') end)
for _, worker in ipairs(pool.workers) do coroutine.resume(worker) end

-- Async pipeline (product scenario)
local function asyncPipeline(steps, data)
    local co = coroutine.create(function()
        local result = data
        for _, step in ipairs(steps) do
            result = step(result)
            coroutine.yield(result)
        end
        return result
    end)
    return co
end
local pipeline = asyncPipeline({
    function(x) print('Step 1:', x); return x + 1 end,
    function(x) print('Step 2:', x); return x * 2 end
}, 5)
while coroutine.status(pipeline) ~= 'dead' do
    local ok, res = coroutine.resume(pipeline)
    if res then print('Pipeline result:', res) end
end

-- Error propagation in coroutines (enterprise scenario)
local function safeCoroutine(fn)
    return coroutine.create(function(...)
        local ok, res = pcall(fn, ...)
        if not ok then print('Coroutine error:', res) end
        return res
    end)
end
local safeCo = safeCoroutine(function() error('Test error') end)
coroutine.resume(safeCo)
