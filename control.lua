-- Check if true
if true then
    print("Statement true")
end

-- Check if false (will not print anything)
if false then
    print("Statement true")
end

-- Check if nil (will not print anything)
if nil then
    print("State is nil")
end

local age = 16
local name = "John"

-- Check if age is greater than 16 (will not print anything)
if age > 16 then
    print("You may enter")
end    

-- Check if age is between 12 and 18
if age > 12 and age < 18 then
    print("You may enter")
end

-- Commented out code, not executed
-- if (age > 14) and (age < 16) then
--     print("You may enter")
-- end

-- Incorrect syntax for not equal in Lua (using !== instead of ~=)
if age ~= 16 then
    print("You are not 16 years old")
end

-- This check is correct and will not print anything since age is 16
if age ~= 16 then
    print("You are not allowed to enter")
end

-- Check if age is 16 and name is "John"
if age == 16 and name == "John" then
    print("You are allowed to enter")
end

-- Check if age is 16 or name is "John"
if age == 16 or name == "John" then
    print("You are allowed to enter")
end

-- Check if age is not less than 18
if not (age < 18) then
    print("You may enter")
end

-- Use elseif for multi-condition checking
if age > 20 then
    print("allowed")
elseif age > 10 then
    print("You are " .. age .. " years old") -- Fixed string concatenation
else
    print("disallowed")
end
