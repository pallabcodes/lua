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


--[[
Advanced Data Types, Scope, and Product/Game Patterns
]]

-- Table (array)
local numbers = {1, 2, 3, 4, 5}
[...existing code...]

local Status = { ACTIVE = 1, INACTIVE = 0, PENDING = 2 }
print('Status.ACTIVE:', Status.ACTIVE)
-- Enum with metatable (advanced)
local function createEnum(tbl)
    return setmetatable(tbl, {
        __index = function(_, k)
            error('Invalid enum key: ' .. tostring(k))
        end
    })
end
local Role = createEnum({ ADMIN = 1, USER = 2, GUEST = 3 })
print('Role.ADMIN:', Role.ADMIN)
-- print(Role.UNKNOWN) -- will error

-- Deep copy pattern
local function deepCopy(obj)
    if type(obj) ~= 'table' then return obj end
    local copy = {}
    for k, v in pairs(obj) do copy[k] = deepCopy(v) end
    return copy
end
local orig = { a = 1, b = { c = 2 } }
local cp = deepCopy(orig)
cp.b.c = 3
print('Original:', orig.b.c, 'Copy:', cp.b.c)

local config = {
    env = os.getenv('ENV') or 'dev',
    debug = true,
    api_url = 'http://localhost:8000'
}
print('Config env:', config.env)
-- Environment config loader (enterprise scenario)
local function loadConfig(env)
    local configs = {
        dev = { db = 'localhost', debug = true },
        prod = { db = 'prod-db', debug = false }
    }
    return configs[env] or configs['dev']
end
local currentConfig = loadConfig(config.env)
print('Loaded config:', currentConfig.db, currentConfig.debug)
for i, v in ipairs(numbers) do
    print("Array index:", i, "value:", v)
end

-- Table (dictionary)
local user = { name = "Alice", age = 30, active = true }
for k, v in pairs(user) do
    print("User property:", k, "value:", v)
end

-- Table manipulation
user.level = 5
user["score"] = 100
print("User level:", user.level, "score:", user.score)

-- Type checking
print("Type of user:", type(user))
print("Type of numbers:", type(numbers))
print("Type of nil:", type(nil))

-- Boolean logic
local isActive = true
if isActive then
    print("User is active")
else
    print("User is not active")
end

--[ [
More Advanced Data Types, Scope, and Product Patterns
]]

-- Enum pattern (using tables)
local Status = { ACTIVE = 1, INACTIVE = 0, PENDING = 2 }
local userStatus = Status.ACTIVE
print("User status:", userStatus == Status.ACTIVE and "Active" or "Not Active")

-- Deep copy utility
local function deepCopy(obj)
    if type(obj) ~= "table" then return obj end
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

-- Environment-specific configuration
local ENV = os.getenv("ENV") or "development"
local config = {
    development = { db = "localhost", debug = true },
    production = { db = "prod-db", debug = false }
}
print("Current config:", config[ENV].db, config[ENV].debug)

local featureFlags = {
    newUI = true,
    betaFeature = false,
    logging = true
}
if featureFlags.newUI then
    print("New UI enabled!")
end
-- Feature flag toggling (product scenario)
local function toggleFlag(flags, name)
    flags[name] = not flags[name]
    print('Feature', name, 'is now', flags[name])
end
toggleFlag(featureFlags, 'betaFeature')

local function logAction(user, action)
    print("[LOG]", os.date("%Y-%m-%d %H:%M:%S"), user, action)
end
logAction("Alice", "login")
logAction("Bob", "purchase")
-- Product scenario: config validation
local function validateConfig(cfg)
    if not cfg.db then return false, 'Missing db' end
    if type(cfg.debug) ~= 'boolean' then return false, 'Debug must be boolean' end
    return true
end
local ok, err = validateConfig(currentConfig)
print('Config valid:', ok, err or '')

-- Product scenario: batch processing users
local users = {
    { name = "Alice", active = true },
    { name = "Bob", active = false },
    { name = "Carol", active = true }
}
for _, u in ipairs(users) do
    if u.active then
        print(u.name .. " is active")
    else
        print(u.name .. " is not active")
    end
end
