-- Dependency Management and Modularization in Lua

-- Using require to import modules
local json = require('dkjson') -- Example external module

-- Custom module
-- mymodule.lua:
-- local M = {}
-- function M.hello() print('Hello!') end
-- return M
-- Usage:
-- local mymodule = require('mymodule')
-- mymodule.hello()

-- Setting package.path for custom locations
package.path = package.path .. ';./?.lua'

-- Dynamic module loading (enterprise scenario)
local function loadModule(name)
    local ok, mod = pcall(require, name)
    if ok then return mod else print('Failed to load:', name) return nil end
end
local myMod = loadModule('nonexistent')

-- Module versioning (product scenario)
local function requireVersion(name, version)
    local mod = require(name)
    if mod.version ~= version then
        error('Version mismatch: expected ' .. version .. ', got ' .. (mod.version or 'unknown'))
    end
    return mod
end
-- local myMod = requireVersion('mymodule', '1.0.0')

-- Plugin discovery (enterprise scenario)
local function discoverPlugins(dir)
    local plugins = {}
    local handle = io.popen('ls ' .. dir .. '/*.lua')
    for file in handle:lines() do
        local name = file:match('([^/]+)%.lua$')
        if name then
            local plugin = loadModule(name)
            if plugin then plugins[name] = plugin end
        end
    end
    handle:close()
    return plugins
end
-- local plugins = discoverPlugins('./plugins')
