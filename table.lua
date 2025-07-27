-- table / array

local arr = { 10, 15, 20, true, "Hello World", 2.2 }
-- This will print the memory address e.g. 0x55a6c9a56600
print(arr)

-- to access a specific element
print(arr[2])

-- to access the last element i.e. here 2.2
print(arr[#arr])

table.insert(arr, 2, "lol")

for i = 1, #arr do
    print(arr[i])
end    

arr = { "hello", "world", "I", "am john" }
-- so it will go to each element and suffix (except the last element) it e.g. hello!, world!, I!, 
print(table.concat(arr, "!"))

-- Matrix/2D array

arr = {
    {1, 2, 3},
    {6, 8, 0},
    {9, 99, 989}
}

print(arr[2][2]) -- 8

for i = 1, #arr do
    for j = 1, #arr[i] do
        print(arr[i][j])
    end -- Close the inner loop
end -- Close the outer loop


--[[
Advanced Table Patterns for Big Tech/Game Companies
]]

-- Table as dictionary (key-value)
local user = { name = "Alice", age = 30, active = true }
for k, v in pairs(user) do
    print("User property:", k, "value:", v)
end

-- Table manipulation: insert, remove, update
local t = { 1, 2, 3 }
table.insert(t, 4)
print("After insert:", table.concat(t, ", "))
table.remove(t, 2)
print("After remove:", table.concat(t, ", "))
t[1] = 10
print("After update:", table.concat(t, ", "))

local nums = { 5, 2, 8, 1 }
table.sort(nums)
print("Sorted:", table.concat(nums, ", "))
-- Table merging (enterprise scenario)
local function mergeTables(t1, t2)
    local res = {}
    for k, v in pairs(t1) do res[k] = v end
    for k, v in pairs(t2) do res[k] = v end
    return res
end
local a = { x = 1, y = 2 }
local b = { y = 3, z = 4 }
local merged = mergeTables(a, b)
for k, v in pairs(merged) do print('Merged:', k, v) end

-- Table filtering and mapping (product scenario)
local function filter(tbl, fn)
    local res = {}
    for _, v in ipairs(tbl) do if fn(v) then table.insert(res, v) end end
    return res
end
local function map(tbl, fn)
    local res = {}
    for _, v in ipairs(tbl) do table.insert(res, fn(v)) end
    return res
end
local filtered = filter({1,2,3,4,5}, function(x) return x % 2 == 0 end)
print('Filtered:', table.concat(filtered, ', '))
local mapped = map({1,2,3}, function(x) return x * 10 end)
print('Mapped:', table.concat(mapped, ', '))

-- Iteration with ipairs (ordered)
for i, v in ipairs(nums) do
    print("Index:", i, "Value:", v)
end

local Inventory = {}
Inventory.__index = Inventory
function Inventory:new()
    local obj = setmetatable({ items = {} }, self)
    return obj
end
function Inventory:add(item)
    table.insert(self.items, item)
end
function Inventory:list()
    for i, v in ipairs(self.items) do
        print("Item:", v)
    end
end
local inv = Inventory:new()
inv:add("Sword")
inv:add("Shield")
inv:list()
-- Proxy metatable for validation (advanced)
local function newValidatedTable(validator)
    return setmetatable({}, {
        __newindex = function(t, k, v)
            if not validator(v) then error('Invalid value: ' .. tostring(v)) end
            rawset(t, k, v)
        end
    })
end
local vt = newValidatedTable(function(v) return type(v) == 'number' end)
vt.a = 10 -- ok
-- vt.b = 'bad' -- will error

local playerInventory = { "Potion", "Bow", "Arrow" }
for i, item in ipairs(playerInventory) do
    print("Player has:", item)
end
-- Product scenario: batch update
local function batchUpdate(tbl, fn)
    for k, v in pairs(tbl) do tbl[k] = fn(v) end
end
local prices = { apple = 1, banana = 2 }
batchUpdate(prices, function(p) return p * 1.1 end)
for k, v in pairs(prices) do print('Updated price:', k, v) end
