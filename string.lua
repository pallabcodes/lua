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
