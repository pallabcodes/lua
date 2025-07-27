-- Useful Lua tricks and idioms

-- Ternary-like pattern
local a, b = 10, 20
local max = (a > b) and a or b
print("Max:", max)

-- Multiple assignment
local x, y, z = 1, 2, 3
print(x, y, z)

-- Table unpacking
local t = { "a", "b", "c" }
print(table.unpack(t))

-- Protect against nil
local val = nil
print(val or "default")

-- Function chaining
local function step1(x) return x + 1 end
local function step2(x) return x * 2 end
print(step2(step1(5)))


--[[
Advanced Lua Tricks for Big Tech/Product Companies
]]

-- Memoization (caching function results)
local function memoize(fn)
    local cache = {}
    return function(...)
        local key = table.concat({...}, ",")
        if cache[key] == nil then
            cache[key] = fn(...)
        end
        return cache[key]
    end
end

local expensiveFunction = memoize(function(n)
    print("Computing for", n)
    return n * n * n
end)
print("Result:", expensiveFunction(5)) -- Computes
print("Result:", expensiveFunction(5)) -- Uses cache

-- Safe navigation (nil-safe property access)
local function safeGet(obj, ...)
    local keys = {...}
    local current = obj
    for _, key in ipairs(keys) do
        if type(current) ~= "table" then
            return nil
        end
        current = current[key]
    end
    return current
end

local user = { profile = { settings = { theme = "dark" } } }
print("Theme:", safeGet(user, "profile", "settings", "theme"))
print("Missing:", safeGet(user, "profile", "missing", "key"))

-- Object factory pattern
local function createUser(name, email)
    return {
        name = name,
        email = email,
        isActive = true,
        login = function(self)
            print(self.name .. " logged in")
        end,
        logout = function(self)
            print(self.name .. " logged out")
        end
    }
end

local alice = createUser("Alice", "alice@example.com")
alice:login()

-- Partial function application
local function partial(fn, ...)
    local args = {...}
    return function(...)
        local newArgs = {}
        for _, v in ipairs(args) do
            table.insert(newArgs, v)
        end
        for _, v in ipairs({...}) do
            table.insert(newArgs, v)
        end
        return fn(table.unpack(newArgs))
    end
end

local function multiply(a, b, c)
    return a * b * c
end
local double = partial(multiply, 2)
print("Partial result:", double(3, 4)) -- 2 * 3 * 4 = 24

-- Event emitter pattern
local function createEventEmitter()
    local listeners = {}
    
    return {
        on = function(event, callback)
            if not listeners[event] then
                listeners[event] = {}
            end
            table.insert(listeners[event], callback)
        end,
        
        emit = function(event, ...)
            if listeners[event] then
                for _, callback in ipairs(listeners[event]) do
                    callback(...)
                end
            end
        end
    }
end

local emitter = createEventEmitter()
emitter.on("user_login", function(user) print("User logged in:", user) end)
emitter.emit("user_login", "Alice")

-- Lazy evaluation
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

local expensiveComputation = lazy(function()
    print("Doing expensive computation...")
    return 42
end)
print("First call:", expensiveComputation())
print("Second call:", expensiveComputation()) -- No recomputation

-- Table deep copy
local function deepCopy(obj)
    if type(obj) ~= "table" then
        return obj
    end
    local copy = {}
    for k, v in pairs(obj) do
        copy[deepCopy(k)] = deepCopy(v)
    end
    return copy
end

local original = { a = 1, b = { c = 2 } }
local copied = deepCopy(original)
copied.b.c = 3
print("Original:", original.b.c, "Copied:", copied.b.c)

-- String interpolation
local function interpolate(template, vars)
    return template:gsub("{(%w+)}", vars)
end

local template = "Hello {name}, you have {count} messages"
local message = interpolate(template, { name = "Alice", count = "5" })
print("Interpolated:", message)

-- Functional programming helpers
local function map(t, fn)
    local result = {}
    for i, v in ipairs(t) do
        result[i] = fn(v)
    end
    return result
end

local function filter(t, predicate)
    local result = {}
    for _, v in ipairs(t) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

local function reduce(t, fn, initial)
    local acc = initial
    for _, v in ipairs(t) do
        acc = fn(acc, v)
    end
    return acc
end

local numbers = {1, 2, 3, 4, 5}
local doubled = map(numbers, function(x) return x * 2 end)
local evens = filter(numbers, function(x) return x % 2 == 0 end)
local sum = reduce(numbers, function(acc, x) return acc + x end, 0)
print("Doubled:", table.concat(doubled, ", "))
print("Evens:", table.concat(evens, ", "))
print("Sum:", sum)

-- Retry mechanism with exponential backoff
local function withRetry(fn, maxRetries, baseDelay)
    maxRetries = maxRetries or 3
    baseDelay = baseDelay or 1
    
    for attempt = 1, maxRetries do
        local success, result = pcall(fn)
        if success then
            return result
        end
        
        if attempt < maxRetries then
            local delay = baseDelay * (2 ^ (attempt - 1))
            print("Attempt", attempt, "failed, retrying in", delay, "seconds")
            -- In real code: os.execute("sleep " .. delay)
        end
    end
    error("All retry attempts failed")
end

-- Pipeline pattern
local function pipe(value, ...)
    local functions = {...}
    for _, fn in ipairs(functions) do
        value = fn(value)
    end
    return value
end

local result = pipe(
    5,
    function(x) return x * 2 end,
    function(x) return x + 1 end,
    function(x) return x ^ 2 end
)
print("Pipeline result:", result) -- ((5*2)+1)^2 = 121

-- Singleton pattern
local function createSingleton(constructor)
    local instance
    return function(...)
        if not instance then
            instance = constructor(...)
        end
        return instance
    end
end

local Database = createSingleton(function()
    return { connection = "db://localhost:5432" }
end)

local db1 = Database()
local db2 = Database()
print("Same instance:", db1 == db2) -- true
