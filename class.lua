-- Lua Class System (OOP)
-- Usage: MyClass = class('MyClass', BaseClass)
--         function MyClass:method() ... end

local function class(name, base)
    local cls = {}
    cls.__name = name
    cls.__index = cls

    -- Inheritance
    if base then
        setmetatable(cls, { __index = base })
        cls.__base = base
    end

    -- Constructor
    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then
            instance:init(...)
        end
        return instance
    end

    return cls
end

return class

--[[
Advanced OOP Patterns for Big Tech/Product Companies
]]

-- Example: static method
-- MyClass.staticMethod = function() print('Static!') end

-- Example: type checking
-- function MyClass:isInstance(obj)
--     return getmetatable(obj) == MyClass
-- end

-- Example: mixin pattern
-- function class.mixin(cls, mixin)
--     for k, v in pairs(mixin) do
--         if k ~= '__index' then
--             cls[k] = v
--         end
--     end
-- end
-- local Logger = { log = function(self, msg) print('[LOG]', msg) end }
-- class.mixin(MyClass, Logger)

-- Product scenario: model base class
-- local Model = class('Model')
-- function Model:init(data)
--     for k, v in pairs(data) do self[k] = v end
-- end
-- local User = class('User', Model)
-- local u = User:new({ name = 'Alice', age = 30 })
-- print(u.name, u.age)

--[[
More Advanced OOP Patterns
]]

-- Abstract class pattern (by convention)
-- local Abstract = class('Abstract')
-- function Abstract:init()
--     error('Cannot instantiate abstract class!')
-- end
-- local Concrete = class('Concrete', Abstract)
-- -- Concrete:new() -- will error

-- Interface simulation (duck typing)
-- local function implements(obj, methods)
--     for _, m in ipairs(methods) do
--         if type(obj[m]) ~= 'function' then return false end
--     end
--     return true
-- end
-- local user = { save = function() end, load = function() end }
-- print('Implements:', implements(user, {'save', 'load'}))

-- Singleton pattern
-- local function singleton(constructor)
--     local instance
--     return function(...)
--         if not instance then instance = constructor(...) end
--         return instance
--     end
-- end
-- local Config = singleton(function() return { debug = true } end)
-- local c1 = Config(); local c2 = Config(); print(c1 == c2)

-- Product scenario: service registry
-- local ServiceRegistry = class('ServiceRegistry')
-- function ServiceRegistry:init()
--     self.services = {}
-- end
-- function ServiceRegistry:register(name, service)
--     self.services[name] = service
-- end
-- function ServiceRegistry:get(name)
--     return self.services[name]
-- end
-- local registry = ServiceRegistry:new()
-- registry:register('db', { host = 'localhost' })
-- print(registry:get('db').host)

--[[
OOP Pipeline/Composition Pattern for Big Tech/Product Companies
]]

-- Compose multiple behaviors/services into a class (pipeline)
-- local function composePipeline(...)
--     local classes = {...}
--     local Pipeline = class('Pipeline')
--     function Pipeline:init(data)
--         for _, cls in ipairs(classes) do
--             if cls.init then cls.init(self, data) end
--         end
--     end
--     return Pipeline
-- end
-- local Logger = { log = function(self, msg) print('[LOG]', msg) end }
-- local Auth = { authenticate = function(self, user) print('Auth:', user) end }
-- local Pipeline = composePipeline(Logger, Auth)
-- local p = Pipeline:new({})
-- p:log('Starting pipeline')
-- p:authenticate('Alice')

-- Real-world product scenario: request processing chain
-- local Request = class('Request')
-- function Request:init(data) self.data = data end
-- function Request:validate() print('Validating', self.data) end
-- function Request:transform() print('Transforming', self.data) end
-- function Request:save() print('Saving', self.data) end
-- local req = Request:new('payload')
-- req:validate(); req:transform(); req:save()
