-- Documentation and Code Comments in Lua

-- Single line comment
-- This is a comment

-- Multi-line comment
--[[
This is a multi-line comment
spanning several lines
]]

-- Docstring pattern for functions
--[[
add - adds two numbers
@param a number
@param b number
@return number
]]
local function add(a, b)
    return a + b
end

-- Using ldoc for documentation
-- --- Adds two numbers
-- -- @param a number
-- -- @param b number
-- -- @return number
-- local function add(a, b) return a + b end
