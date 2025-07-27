-- VARIABLES AND DATA TYPES FOR BIG TECH/PRODUCT COMPANIES

--[[
Basic Variable Declaration and Assignment
]]

-- Numbers (integer and float)
local age = 25
local price = 99.99
local temperature = -10.5
print("Age:", age, "Price:", price, "Temperature:", temperature)

-- Strings
local name = "Alice"
local product = 'iPhone'
local description = [[Multi-line string
for product descriptions
in e-commerce systems]]
print("Name:", name, "Product:", product)
print("Description:", description)

-- Booleans
local isActive = true
local isLoggedIn = false
local hasPermission = nil -- nil is falsy in Lua
print("Active:", isActive, "Logged in:", isLoggedIn, "Permission:", hasPermission)

-- Nil (absence of value)
local undefined
print("Undefined variable:", undefined) -- prints nil

--[[
Variable Scope and Lifetime
]]

-- Global variables (avoid in production code)
globalCounter = 0

-- Local variables (preferred for performance and safety)
local function demonstrateScope()
    local localVar = "I'm local to this function"
    globalCounter = globalCounter + 1
    print("Local:", localVar, "Global counter:", globalCounter)
end
demonstrateScope()

-- Block scope
do
    local blockVar = "I exist only in this block"
    print("Block variable:", blockVar)
end
-- print(blockVar) -- This would cause an error

--[[
Multiple Assignment and Swapping
]]

-- Multiple assignment
local x, y, z = 1, 2, 3
print("Multiple assignment:", x, y, z)

-- Swapping variables
local a, b = 10, 20
print("Before swap: a =", a, "b =", b)
a, b = b, a
print("After swap: a =", a, "b =", b)

-- Unpack values from function returns
local function getCoordinates()
    return 100, 200
end
local posX, posY = getCoordinates()
print("Position:", posX, posY)

--[[
Type Checking and Conversion
]]

-- Dynamic typing
local value = 42
print("Type of", value, "is", type(value))
value = "Hello"
print("Type of", value, "is", type(value))
value = true
print("Type of", value, "is", type(value))

-- Type conversion
local numStr = "123"
local num = tonumber(numStr)
print("String to number:", numStr, "->", num, type(num))

local numToStr = tostring(456)
print("Number to string:", 456, "->", numToStr, type(numToStr))

--[[
Constants and Configuration (Lua idioms)
]]

-- Constants (by convention, use UPPERCASE)
local MAX_USERS = 1000
local API_URL = "https://api.example.com"
local CONFIG = {
    timeout = 30,
    retries = 3,
    debug = true
}
print("Max users:", MAX_USERS, "API URL:", API_URL)
print("Config timeout:", CONFIG.timeout)

--[[
Variable Patterns for Product/Tech Companies
]]

-- User session data
local userSession = {
    userId = "user_123",
    isAuthenticated = true,
    permissions = {"read", "write"},
    loginTime = os.time(),
    sessionToken = "abc123xyz"
}
print("User session:", userSession.userId, userSession.isAuthenticated)

-- Feature flags (common in product development)
local featureFlags = {
    newUI = true,
    betaFeatures = false,
    analytics = true
}
if featureFlags.newUI then
    print("Using new UI")
end

-- Environment-specific variables
local environment = os.getenv("ENV") or "development"
local dbConfig = {
    development = { host = "localhost", port = 5432 },
    production = { host = "prod-db.com", port = 5432 }
}
print("Environment:", environment)

--[[
Memory Management and Performance
]]

-- Weak references (for caches)
local cache = {}
setmetatable(cache, {__mode = "v"}) -- Values can be garbage collected

-- Avoiding global pollution
local MyModule = {}
MyModule.version = "1.0.0"
MyModule.config = { debug = false }

-- Variable reuse for performance
local temp
for i = 1, 5 do
    temp = i * 2
    print("Reused variable:", temp)
end

