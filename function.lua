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