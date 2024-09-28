-- iterator = i, iterable range = 1, 10, increment/decrement after each loop
-- this will print: 1 3 5 7 9
for i = 1, 10, 2 do
	print(i)
end

-- this will print: 5 4 3 2 1
for i = 5, 1, -1 do
	print(i)
end

-- Corrected variable range and step direction
-- start at 10, end at 1, decrement by -1
local start_val, end_val, step_val = 10, 1, -1
for i = start_val, end_val, step_val do
	print(i)
end

local arr = { 2, 4, 6, 8, 10 }

-- it will print indices: 1, 2, 3, 4, 5
for i = 1, #arr do
	print(i)
end

-- Decrementing in a while loop
local peeps = 10
while peeps > 0 do
	peeps = peeps - 1
	print("people left at party: " .. peeps)
end

-- Simple while loop with boolean control
local run = true
local runtime = 0

while run do
	print("running")

	if runtime == 10 then
		run = false  -- Stop the loop after 10 iterations
	end

	runtime = runtime + 1
end

-- This loop will not run as x = 11 and the condition is x < 10
local x = 11
while x < 10 do
	print("Hey there")
	x = x + 1
end
