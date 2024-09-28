-- DATA TYPES, SCOPES AND VARIABLES

-- integer
local t = 2
-- Removed undefined variable 'a'
print(t)  -- Prints the value of 't'
local t1 = 4
-- Removed undefined variable 'b'
print(type(t1))  -- Prints the type of 't1', which is a number

-- Fixed: converting an invalid string with `tostring` (not `string`)
local t2 = "12a"
print(type(tostring(t2)))  -- Converts t2 to a string and prints the type

-- string
local name = "John"
local surname = "Wick"
print(name .. " " .. surname)  -- Correct concatenation of strings
local fullName = name .. " " .. surname
print(fullName)
print(type(fullName))

-- Removed the commented broken print statement; fixing syntax:
-- Fixed string concatenation inside the print statement
-- Uncommented the corrected statement:
print("Name is " .. name .. ". He is 12 years old " .. name)

print(name)  -- Prints "John"
name = 20  -- name is now a number
print(name)  -- Prints 20
name = false  -- name is now a boolean
print(name)  -- Prints false
name = nil  -- name is now nil
print(name)  -- Prints nil (which means nothing will be printed)

-- String block with multi-line support using `[[ ]]` syntax
local description = [[greeting
   Hello, JavaScript
done
]]
print(description)

-- globally scoped
isWorking = false  -- This is global because it is not defined with `local`

-- locally scoped
local isWorkingLocal = false

-- MATH
print(5 ^ 5)  -- Exponentiation
print(5 * 5)  -- Multiplication
math.randomseed(2)  -- Sets a fixed seed for random numbers
print(math.random(10,50))  -- Random number between 10 and 50
print(math.random(10))  -- Random number between 1 and 10
print(os.time())  -- Prints the current timestamp
print(math.min(10, 1, 50, 12))  -- Finds the minimum of the given numbers
print(math.max(10, 1, 50, 12))  -- Finds the maximum of the given numbers
print(math.sin(20))  -- Sine of 20 (in radians)
print(math.cos(20))  -- Cosine of 20 (in radians)
