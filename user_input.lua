local num1, num2 = 10, 5
local localAns = num1 + num2  -- Correct variable name

print("Input " .. num1 .. " + " .. num2 .. ": ")
local ans = io.read()

if tonumber(ans) == localAns then
	print("Correct")
else
	print("\nYour answer is " .. ans .. ", which is incorrect! Try again.")
end


--[[
Advanced User Input for Big Tech/Game Companies
]]

-- String input (e.g., player name)
print("Enter your player name:")
local playerName = io.read()
print("Welcome, " .. playerName)

-- Number input with error handling
local function getNumber(prompt)
	while true do
		print(prompt)
		local input = io.read()
		local num = tonumber(input)
		if num then
			return num
		else
			print("Invalid number, try again.")
		end
	end
end
local age = getNumber("Enter your age:")
print("Your age is " .. age)

local options = { "Start Game", "Load Game", "Exit" }
for i, v in ipairs(options) do
	print(i .. ". " .. v)
end

local choice = getNumber("Enter option number:")
if options[choice] then
	print("You selected: " .. options[choice])
else
	print("Invalid selection.")
end



--[[
More Advanced User Input Scenarios
]]

-- Password input (simulated, since Lua can't hide input in CLI natively)
print("Enter your password (input not hidden):")
local password = io.read()
if #password < 6 then
	print("Password too short!")
else
	print("Password accepted.")
end
-- Confirmation prompt (yes/no)
local function confirm(prompt)
	print(prompt .. " (y/n):")
	local resp = io.read()
	return resp == "y" or resp == "Y"
end
if confirm("Do you want to continue?") then
	print("Continuing...")
else
	print("Operation cancelled.")
end

-- Multi-step form (collecting multiple fields)
local function getUserInfo()
	print("Enter username:")
	local username = io.read()
	print("Enter email:")
	local email = io.read()
	print("Enter age:")
	local age = getNumber("")
	return { username = username, email = email, age = age }
end

-- Example usage of getUserInfo
local info = getUserInfo()
print("User info:", info.username, info.email, info.age)

-- Read environment variable (if available)
local home = os.getenv("HOME")
if home then
	print("Your HOME directory is: " .. home)
else
	print("HOME environment variable not found.")
end

--[[
Even More Advanced User Input Scenarios
]]

-- Reading command-line arguments
if arg then
	print("Command-line arguments:")
	for i, v in ipairs(arg) do
		print(i, v)
	end
end

-- Input validation (email format)
local function isValidEmail(email)
	return email:match("^[%w%.%-_]+@[%w%.%-_]+%.%a%a+$") ~= nil
end
print("Enter your email for validation:")
local emailInput = io.read()
if isValidEmail(emailInput) then
	print("Valid email!")
else
	print("Invalid email format.")
end

-- Interactive loop (e.g., REPL)
print("Type 'exit' to quit.")
while true do
	io.write("> ")
	local line = io.read()
	if line == "exit" then break end
	print("You typed:", line)
end


--[[
File and Piped Input, JSON Parsing
]]

-- Reading input from a file
local function readFileInput(filename)
	local f = io.open(filename, "r")
	if not f then
		print("File not found: " .. filename)
		return nil
	end
	local content = f:read("*all")
	f:close()
	return content
end
-- Example usage (uncomment to use):
-- local fileContent = readFileInput("input.txt")
-- if fileContent then print("File content:", fileContent) end

-- Reading piped input (from stdin)
-- Run: echo "hello world" | lua user_input.lua
if not arg or #arg == 0 then
	local piped = io.read("*a")
	if piped and #piped > 0 then
		print("Piped input:", piped)
	end
end

-- JSON parsing (requires dkjson or similar library)
-- local json = require "dkjson"
-- local jsonString = '{"name":"Alice","age":30}'
-- local obj, pos, err = json.decode(jsonString)
-- if obj then print("Parsed JSON:", obj.name, obj.age) end


--[[
CSV Parsing, Reading from URLs, Interactive Menu Loop
]]

-- Simple CSV parsing (split by comma)
local function parseCSV(line)
    local t = {}
    for value in string.gmatch(line, "[^,]+") do
        table.insert(t, value)
    end
    return t
end
-- Example usage:
local csv = "apple,banana,cherry"
local items = parseCSV(csv)
for i, v in ipairs(items) do 
    print("CSV item " .. i .. ":", v) 
end

-- Reading from a URL (requires LuaSocket)
-- local http = require("socket.http")
-- local body, code = http.request("http://example.com")
-- print("Status:", code)
-- print("Body:", body)

-- Interactive menu loop with date/time functionality
local menuOptions = { "Show Date", "Show Time", "Exit" }
print("\nInteractive Menu Demo:")
while true do
    print("\nMenu:")
    for i, v in ipairs(menuOptions) do
        print(i .. ". " .. v)
    end
    local sel = getNumber("Choose option:")
    if sel == 1 then
        print("Date:", os.date("%Y-%m-%d"))
    elseif sel == 2 then
        print("Time:", os.date("%H:%M:%S"))
    elseif sel == 3 then
        print("Exiting menu loop.")
        break
    else
        print("Invalid option.")
    end
end
