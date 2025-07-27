-- Performance Profiling and Optimization in Lua

-- Timing code execution
local start = os.clock()
for i = 1, 1e6 do end
local elapsed = os.clock() - start
print('Elapsed:', elapsed)

-- Memory usage
print('Memory (KB):', collectgarbage('count'))

-- Profiling with LuaProfiler (external)
-- require('profiler').start()
-- ... code ...
-- require('profiler').stop()

-- Optimization: localize frequently used globals
local print = print
for i = 1, 10 do print(i) end

-- Lazy evaluation (enterprise scenario)
local function lazy(fn)
    local computed = false
    local result
    return function()
        if not computed then
            result = fn()
            computed = true
        end
        return result
    end
end
local expensiveCalc = lazy(function() print('Computing...'); return 42 end)
print('First call:', expensiveCalc())
print('Second call:', expensiveCalc()) -- No recomputation

-- Caching utility (product scenario)
local function createCache(maxSize)
    local cache = { data = {}, order = {}, size = 0 }
    return {
        get = function(key)
            return cache.data[key]
        end,
        set = function(key, value)
            if not cache.data[key] and cache.size >= maxSize then
                local oldest = table.remove(cache.order, 1)
                cache.data[oldest] = nil
                cache.size = cache.size - 1
            end
            cache.data[key] = value
            table.insert(cache.order, key)
            cache.size = cache.size + 1
        end
    }
end
local cache = createCache(2)
cache.set('a', 1); cache.set('b', 2); cache.set('c', 3)
print('Cache a:', cache.get('a')) -- nil (evicted)
print('Cache c:', cache.get('c')) -- 3

-- Rate limiter (product scenario)
local function createRateLimiter(limit, window)
    local requests = {}
    return function(key)
        local now = os.time()
        requests[key] = requests[key] or {}
        local reqs = requests[key]
        
        -- Remove old requests
        for i = #reqs, 1, -1 do
            if now - reqs[i] > window then table.remove(reqs, i) end
        end
        
        if #reqs >= limit then return false end
        table.insert(reqs, now)
        return true
    end
end
local limiter = createRateLimiter(3, 10)
print('Rate limit 1:', limiter('user1'))
print('Rate limit 2:', limiter('user1'))
print('Rate limit 3:', limiter('user1'))
print('Rate limit 4:', limiter('user1')) -- Should be false
