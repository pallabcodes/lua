-- Local vs Global Variables in Lua

-- Global variable (avoid in production)
globalVar = "I am global"

-- Local variable (preferred)
local localVar = "I am local"

function showVars()
    print("Global:", globalVar)
    print("Local:", localVar)
end
showVars()

-- Local inside function
function testLocal()
    local inner = "Inner local"
    print(inner)
end
testLocal()
-- print(inner) -- Error: not visible here

-- Block scope
do
    local blockScoped = "Block scope"
    print(blockScoped)
end
-- print(blockScoped) -- Error: not visible here
