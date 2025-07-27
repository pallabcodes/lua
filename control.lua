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

if age > 20 then
    print("allowed")
elseif age > 10 then
    print("You are " .. age .. " years old") -- Fixed string concatenation
else
    print("disallowed")
end


--[[
Advanced Control Structures & Patterns
Useful for big tech and game companies
]]

-- For loop (counting)
for i = 1, 5 do
    print("For loop iteration:", i)
end

-- While loop
local count = 3
while count > 0 do
    print("While loop, count:", count)
    count = count - 1
end

-- Repeat-until loop (runs at least once)
local tries = 0
repeat
    print("Repeat-until, tries:", tries)
    tries = tries + 1
until tries > 2

-- Break example (exit loop early)
for i = 1, 10 do
    if i == 4 then
        print("Breaking at", i)
        break
    end
end

-- Nested conditions (game state example)
local player = { health = 50, alive = true }
if player.alive then
    if player.health < 20 then
        print("Player is in danger!")
    else
        print("Player is safe.")
    end
else
    print("Player is dead.")
end

local state = "idle"
-- State machine with transitions (enterprise scenario)
local transitions = {
    idle = { run = "running", jump = "jumping" },
    running = { stop = "idle", jump = "jumping" },
    jumping = { land = "idle" }
}
local function nextState(current, action)
    local t = transitions[current]
    return t and t[action] or current
end
state = nextState(state, "run")
print("State after 'run':", state)
state = nextState(state, "jump")
print("State after 'jump':", state)
state = nextState(state, "land")
print("State after 'land':", state)

local function processUser(user)
    if not user.active then return print('Inactive user') end
    print('Processing user:', user.name)
end
processUser({ name = 'Alice', active = false })
processUser({ name = 'Bob', active = true })
-- Guard clause with error propagation (product scenario)
local function processOrder(order)
    if not order then return nil, 'Missing order' end
    if not order.valid then return nil, 'Invalid order' end
    print('Order processed:', order.id)
    return true
end
local ok, err = processOrder(nil)
if not ok then print('Error:', err) end
ok, err = processOrder({ id = 1, valid = false })
if not ok then print('Error:', err) end
ok, err = processOrder({ id = 2, valid = true })
if ok then print('Success!') end

local features = { newUI = true, betaMode = false }
if features.newUI then print('New UI enabled') end
if features.betaMode then print('Beta mode enabled') end
-- Dynamic feature flag toggling (enterprise scenario)
local function toggleFeature(features, name, value)
    features[name] = value
    print('Feature', name, 'set to', value)
end
toggleFeature(features, 'betaMode', true)
if features.betaMode then print('Beta mode now enabled') end

local function canAccess(user, resource)
    return user.role == 'admin' or resource.public
end
local user = { name = 'Alice', role = 'user' }
local resource = { public = false }
print('Access:', canAccess(user, resource))
-- Role-based access control (RBAC, product scenario)
local function hasRole(user, role)
    if not user or not user.roles then return false end
    for _, r in ipairs(user.roles) do if r == role then return true end end
    return false
end
local user2 = { name = 'Bob', roles = { 'editor', 'admin' } }
print('Is admin:', hasRole(user2, 'admin'))

local function match(val)
    if type(val) == 'number' then print('Number:', val)
    elseif type(val) == 'string' then print('String:', val)
    elseif type(val) == 'table' then print('Table:', val)
    else print('Unknown type') end
end
match(42); match('hello'); match({})
-- Product scenario: pattern matching for workflow events
local function handleEvent(event)
    if event.type == 'create' then
        print('Create event:', event.data)
    elseif event.type == 'update' then
        print('Update event:', event.data)
    elseif event.type == 'delete' then
        print('Delete event:', event.data)
    else
        print('Unknown event type:', event.type)
    end
end
handleEvent({ type = 'create', data = 'user1' })
handleEvent({ type = 'update', data = 'user2' })
handleEvent({ type = 'archive', data = 'user3' })
if state == "idle" then
    print("Player is idle.")
elseif state == "running" then
    print("Player is running.")
elseif state == "jumping" then
    print("Player is jumping.")
else
    print("Unknown state.")
end
-- Product scenario: workflow orchestration (chaining control logic)
local function workflow(user, order)
    if not user or not user.active then return 'User inactive' end
    if not order or not order.valid then return 'Order invalid' end
    if not canAccess(user, { public = true }) then return 'Access denied' end
    print('Workflow: processing order', order.id, 'for', user.name)
    return 'Success'
end
print('Workflow result:', workflow({ name = 'Alice', active = true, role = 'user' }, { id = 3, valid = true }))
print('Workflow result:', workflow({ name = 'Bob', active = false, role = 'user' }, { id = 4, valid = true }))

-- Event handling pattern (callback)
local function onEvent(event)
    if event == "hit" then
        print("Player was hit!")
    elseif event == "heal" then
        print("Player healed!")
    else
        print("Unhandled event:", event)
    end
end
onEvent("hit")
onEvent("heal")
onEvent("powerup")

--[[
More Advanced Control Flow for Big Tech/Product Companies
]]

-- Guard clause idiom
local function processUser(user)
    if not user or not user.active then
        print("Inactive or missing user")
        return
    end
    print("Processing user:", user.name)
end
processUser(nil)
processUser({ name = "Alice", active = false })
processUser({ name = "Bob", active = true })

-- Error handling with pcall
local function risky()
    error("Something went wrong!")
end
local ok, err = pcall(risky)
if not ok then
    print("Caught error:", err)
end

-- Pattern matching (simulated with if/elseif)
local function match(val)
    if val == "A" then
        print("Matched A")
    elseif val == "B" then
        print("Matched B")
    else
        print("No match")
    end
end
match("A")
match("C")

-- Product scenario: feature flag control
local featureFlags = { newUI = true, logging = false }
if featureFlags.newUI then
    print("New UI enabled!")
else
    print("Old UI in use")
end

-- Product scenario: access control
local function canAccess(user, resource)
    if not user or not user.permissions then return false end
    for _, perm in ipairs(user.permissions) do
        if perm == resource then return true end
    end
    return false
end
local user = { name = "Alice", permissions = { "read", "write" } }
print("Can access 'read':", canAccess(user, "read"))
print("Can access 'delete':", canAccess(user, "delete"))
