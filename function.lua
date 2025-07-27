-- Function to sum numbers
local function sum(...)
    local sums = 0
    local x = { 3, 5, 10, 99, 87, 45 }

    for _, value in pairs(x) do
        sums = sums + value
    end

    return sums
end    

print("Sum of predefined numbers: " .. sum(3, 5, 10, 99, 87, 45))

local z = 10.10
local ten = 10

-- Function declaration
local function addition(num1, num2)
    local y = num1 + num2
    return y -- Return the sum
end

local result = addition(2, 4)
print("Addition result: " .. result)

-- Function expression
local add10 = function(number)
    local result = number + ten
    return result -- Return the result
end

print("Add 10 to 2: " .. add10(2)) -- Outputs: 12

-- Storing the output of add10
local stored = add10(20) 
print(stored .. " had 10 added to it") -- Outputs: 30 had 10 added to it

-- Safe handling of nil
local output = add10(20) -- `output` will hold the result
print("Had 10 added to it: " .. tostring(output)) -- Safely handle nil using `tostring`

-- Higher Order function
local function counter()
    local count = 0

    return function()
        count = count + 1
        return count
    end    
end

local cl = counter()
print("Counter output:")
print(cl()) -- 1
print(cl()) -- 2
print(cl()) -- 3
print(cl()) -- 4
print(cl()) -- 5

-- Recursion
local function recursiveCounter(number, end_num)
    local count = number + 1

    if count < end_num then
        print(count)
        return recursiveCounter(count, end_num)
    end

    return count
end

print("Recursive count from 10 to 15:")
print(recursiveCounter(10, 15))

-- Rest parameter
local function sumRest(...)
    local sums = 0

    for key, value in pairs({...}) do
        print("Key: " .. key .. ", Value: " .. value)
        sums = sums + value
    end

    return "Total sum: " .. sums
end

print(sumRest(10, 5, 9, 0, 14)) -- Outputs the sum of provided numbers


--[[
Advanced Function Patterns for Big Tech/Game Companies
]]

-- Closure example (function remembers its environment)
local function makeMultiplier(factor)
    return function(x)
        return x * factor
    end
end

local double = makeMultiplier(2)
local triple = makeMultiplier(3)
print("Double 5:", double(5)) -- 10
print("Triple 5:", triple(5)) -- 15

-- Callback example (passing functions as arguments)
local function processData(data, callback)
    for _, v in ipairs(data) do
        callback(v)
    end
end

processData({1,2,3}, function(x) print("Callback value:", x) end)

-- Table-based method (OOP style)
local Player = {}
Player.__index = Player

function Player:new(name)
    local obj = setmetatable({}, self)
    obj.name = name
    obj.score = 0
    return obj
end

function Player:addScore(points)
    self.score = self.score + points
    print(self.name .. " score:", self.score)
end

local p1 = Player:new("Alice")
p1:addScore(10)
p1:addScore(5)

-- Error handling in functions
local function safeDivide(a, b)
    if b == 0 then
        return nil, "Division by zero!"
    end
    return a / b
end
local result, err = safeDivide(10, 0)
if err then
    print("Error:", err)
else
    print("Division result:", result)
end

--[ [
More Advanced Function Patterns for Big Tech/Product Companies

-- Currying (partial application)
local function curry(fn, ...)
    local args = {...}
    return function(...)
        local newArgs = {}
        for _, v in ipairs(args) do table.insert(newArgs, v) end
        for _, v in ipairs({...}) do table.insert(newArgs, v) end
        return fn(table.unpack(newArgs))
    end
end
local function add(a, b, c) return a + b + c end
local add5 = curry(add, 5)
print("Curried add:", add5(10, 15)) -- 5 + 10 + 15 = 30

local function logDecorator(fn)
    return function(...)
        print("Calling function with args:", ...)
        return fn(...)
    end
end
local function multiply(a, b) return a * b end
local loggedMultiply = logDecorator(multiply)
print("Logged multiply:", loggedMultiply(3, 4))

-- Advanced memoization (multi-arg, product scenario)
local function memoize(fn)
    local cache = {}
    return function(...)
        local key = table.concat({ ... }, ":")
        if cache[key] == nil then
            cache[key] = fn(...)
        end
        return cache[key]
    end
end
local function slowSum(a, b)
    print("Calculating sum for", a, b)
    return a + b
end
local fastSum = memoize(slowSum)
print("Memoized sum:", fastSum(2, 3))
print("Memoized sum:", fastSum(2, 3)) -- Uses cache

local function async(fn)
    local co = coroutine.create(fn)
    return function(...)
        local ok, res = coroutine.resume(co, ...)
        return res
    end
end
local function backgroundTask()
    for i = 1, 3 do
        print("Async step", i)
        coroutine.yield(i)
    end
end
local runAsync = async(backgroundTask)
print("Async result:", runAsync())
print("Async result:", runAsync())
print("Async result:", runAsync())
-- Async wrapper for product scenario (API call)
local function asyncApi(fn)
    return function(...)
        local co = coroutine.create(fn)
        local ok, res = coroutine.resume(co, ...)
        if not ok then print('Async error:', res) end
        return res
    end
end
local function apiTask()
    for i = 1, 2 do
        print('API async step', i)
        coroutine.yield('step ' .. i)
    end
    return 'done'
end
local runApiAsync = asyncApi(apiTask)
print('API async result:', runApiAsync())
print('API async result:', runApiAsync())

local function apiRequest(endpoint, params)
    print("Requesting", endpoint, "with", params)
    -- Simulate API call
    return { status = 200, data = "OK" }
end
local response = apiRequest("/users", { id = 123 })
print("API response:", response.status, response.data)
-- API wrapper with error handling (enterprise scenario)
local function safeApiRequest(endpoint, params)
    local ok, res = pcall(apiRequest, endpoint, params)
    if ok then return res else return { status = 500, error = res } end
end
local safeResp = safeApiRequest('/fail', {})
print('Safe API response:', safeResp.status, safeResp.error)

local function withRetry(fn, maxRetries)
    maxRetries = maxRetries or 3
    for attempt = 1, maxRetries do
        local ok, res = pcall(fn)
        if ok then return res end
        print("Attempt", attempt, "failed")
    end
    error("All attempts failed")
end
local function unreliable()
    if math.random() < 0.5 then error("Fail!") end
    return "Success!"
end
print("Retry result:", withRetry(unreliable, 5))
-- Function composition (pipeline, product scenario)
local function compose(...)
    local fns = {...}
    return function(arg)
        local result = arg
        for _, fn in ipairs(fns) do
            result = fn(result)
        end
        return result
    end
end
local function step1(x) print('Step1', x); return x + 1 end
local function step2(x) print('Step2', x); return x * 2 end
local pipeline = compose(step1, step2)
print('Pipeline result:', pipeline(5))