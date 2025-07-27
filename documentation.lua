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

-- Code annotation patterns (enterprise scenario)
local function annotate(fn, meta)
    fn._meta = meta
    return fn
end
local multiply = annotate(function(a, b) return a * b end, {
    author = 'team-backend',
    version = '1.0.0',
    deprecated = false
})
print('Function meta:', multiply._meta.author)

-- API documentation generator (product scenario)
local function generateApiDoc(module)
    local doc = { name = module.name, endpoints = {} }
    for name, fn in pairs(module) do
        if type(fn) == 'function' and fn._meta then
            table.insert(doc.endpoints, {
                name = name,
                description = fn._meta.description or 'No description'
            })
        end
    end
    return doc
end
local api = {
    name = 'UserAPI',
    getUser = annotate(function() end, { description = 'Get user by ID' }),
    createUser = annotate(function() end, { description = 'Create new user' })
}
local apiDoc = generateApiDoc(api)
print('API doc generated for:', apiDoc.name)
for _, endpoint in ipairs(apiDoc.endpoints) do
    print('  -', endpoint.name, ':', endpoint.description)
end
