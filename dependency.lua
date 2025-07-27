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
