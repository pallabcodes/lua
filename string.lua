-- Concatenating strings
local str = "Hello " .. "World"
print("Hello\nWorld")
print(str)

-- Reassigning 'str' and concatenating it again
str = "Hello "
print(str .. "World")

-- Converting a number to a string
local x = 22
local y = tostring(x)  -- Corrected: use 'x' not 'y' here

-- Print types of x and y
print(type(x), type(y))

-- Substring of 'str'
print(string.sub(str, 1, 5)) -- Prints 'Hello'

-- string.char expects numbers representing ASCII values
-- Corrected: Removed invalid usage of 'str' and 7
print(string.char(97)) -- Prints 'a' (ASCII value of 97)

-- byte values of 'str'
print(string.byte(str, 1, 5)) -- Corrected: Prints byte values of 'Hello'

-- Getting the byte value of the letter 'a'
print(string.byte("a")) -- Prints ASCII value of 'a'

-- Repeat "Hello!" 10 times, separated by commas
print(string.rep("Hello!", 10, ","))

-- Finding "orl" in the concatenated "Hello World"
str = "Hello World" -- To ensure we are searching in the correct string
print(string.find(str, "orl"))

-- Replacing 'o' with '!' in the string
print(string.gsub(str, 'o', '!')) -- Replaces 'o' in "Hello World" with '!'

--[[
Advanced String Manipulation for Big Tech/Game Companies
]]

-- Multi-line string and escaping
local multi = [[Line 1
Line 2
Line 3]]
print(multi)
local escaped = "He said: \"Hello!\""
print(escaped)

-- String formatting (using string.format)
local player = "Alice"
local score = 150
local formatted = string.format("Player %s has score %d", player, score)
print(formatted)

-- Pattern matching (find numbers in a string)
local s = "User123 scored 456 points"
for num in string.gmatch(s, "%d+") do
    print("Found number:", num)
end

-- Splitting a string (using pattern)
local function split(input, sep)
    local t = {}
    for str in string.gmatch(input, "[^" .. sep .. "]+") do
        table.insert(t, str)
    end
    return t
end
local words = split("apple,banana,cherry", ",")
for i, word in ipairs(words) do
    print("Word:", word)
end

-- Trimming whitespace
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end
print("Trimmed:", trim("   hello world   "))

-- Product/Game scenario: parsing player chat
local chat = "[Alice]: Hello! [Bob]: Hi!"
for name, msg in string.gmatch(chat, "%[(%w+)%]: ([^%[]+)") do
    print("Player:", name, "said:", trim(msg))
end

--[ [
More Advanced String Handling for Big Tech/Product Companies
]]

-- Base64 encoding/decoding (requires external lib, e.g. mime)
-- local mime = require("mime")
-- local encoded = mime.b64("hello world")
-- local decoded = mime.unb64(encoded)
-- print("Base64 encoded:", encoded)
-- print("Base64 decoded:", decoded)

-- Regex-like pattern: extract email addresses
local text = "Contact: alice@example.com, bob@work.org"
for email in string.gmatch(text, "[%w%.%-_]+@[%w%.%-_]+%.%a%a+") do
    print("Found email:", email)
end

-- Table to string conversion (for logging)
local function tableToString(tbl)
    local result = "{ "
    for k, v in pairs(tbl) do
        result = result .. tostring(k) .. ": " .. tostring(v) .. ", "
    end
    return result .. "}"
end
local user = { name = "Alice", age = 30, active = true }
print("User as string:", tableToString(user))

local function escapeHTML(s)
    s = s:gsub("&", "&amp;")
    s = s:gsub("<", "&lt;")
    s = s:gsub(">", "&gt;")
    s = s:gsub('"', "&quot;")
    s = s:gsub("'", "&#39;")
    return s
end
print("Escaped HTML:", escapeHTML('<div class="user">Alice & Bob</div>'))
-- Advanced escaping (product scenario)
local function escapeLog(s)
    s = s:gsub('[\n\r]', ' ')
    s = s:gsub('[%c]', '?')
    return s
end
print('Escaped log:', escapeLog('User\ninput\r: bad\0data'))

local logMsg = "User input: <script>alert('hack')</script>"
print("Sanitized log:", escapeHTML(logMsg))
-- Product scenario: log formatting
local function formatLog(level, msg)
    return string.format('[%s] %s', level:upper(), escapeLog(msg))
end
print(formatLog('info', 'User logged in'))
print(formatLog('error', 'Bad\ndata!'))

-- String reversal
local function reverse(s)
    return s:reverse()
end
print("Reversed:", reverse("Lua is cool!"))

-- Count occurrences of substring
local function countSub(str, sub)
    local count = 0
    local start = 1
    while true do
        local i = string.find(str, sub, start, true)
        if not i then break end
        count = count + 1
        start = i + #sub
    end
    return count
end
print("Count 'l' in 'Hello World':", countSub("Hello World", "l"))

-- String join (table to string with separator)
local function join(tbl, sep)
    return table.concat(tbl, sep)
end
local fruits = {"apple", "banana", "cherry"}
print("Joined fruits:", join(fruits, ", "))

local function startsWith(str, start)
    return str:sub(1, #start) == start
end
local function endsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end
print("Starts with 'Hello':", startsWith("Hello World", "Hello"))
print("Ends with 'World':", endsWith("Hello World", "World"))
-- String interpolation utility (enterprise scenario)
local function interpolate(str, vars)
    return (str:gsub('{$([%w_]+)}', function(k) return tostring(vars[k]) or '' end))
end
local template = 'Hello, {$name}! Your score is {$score}.'
print(interpolate(template, { name = 'Alice', score = 99 }))
