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


--[[
Advanced Loop Patterns for Big Tech/Game Companies
]]

-- repeat-until loop (runs at least once)
local tries = 0
repeat
	print("Repeat-until tries:", tries)
	tries = tries + 1
until tries > 2

-- Iterating over table values (unordered)
local scores = { alice = 10, bob = 15, carol = 8 }
for k, v in pairs(scores) do
	print(k .. " scored " .. v)
end

-- Iterating over table values (ordered)
local values = { 100, 200, 300 }
for i, v in ipairs(values) do
	print("Index " .. i .. ": " .. v)
end

-- Loop control: break
for i = 1, 10 do
	if i == 5 then
		print("Breaking at " .. i)
		break
	end
end

-- Loop control: goto (rare, but sometimes used)
for i = 1, 5 do
	if i == 3 then
		goto skip
	end
	print("Goto loop:", i)
	::skip::
end

-- Game/Product scenario: entity update loop
local entities = {
	{ name = "Enemy", hp = 100 },
	{ name = "Player", hp = 150 },
	{ name = "NPC", hp = 80 }
}
for _, entity in ipairs(entities) do
	entity.hp = entity.hp - 10 -- Simulate damage
	print(entity.name .. " HP:", entity.hp)
end

--[ [
More Advanced Loop Patterns for Big Tech/Product Companies
]]

-- Custom iterator function
local function range(start, stop, step)
	step = step or 1
	local i = start - step
	return function()
		i = i + step
		if (step > 0 and i > stop) or (step < 0 and i < stop) then return nil end
		return i
	end
end
for i in range(1, 5) do
	print("Custom iterator:", i)
end

-- Coroutine-based loop (for async/batch processing)
local function asyncLoop(tbl, fn)
	local co = coroutine.create(function()
		for i, v in ipairs(tbl) do
			fn(v)
			coroutine.yield()
		end
	end)
	while coroutine.status(co) ~= "dead" do
		coroutine.resume(co)
	end
end
asyncLoop({"A", "B", "C"}, function(x) print("Async item:", x) end)

local function batchProcess(tbl, fn)
	for i, v in ipairs(tbl) do
		local ok, err = pcall(fn, v)
		if not ok then
			print("Error processing item", i, ":", err)
		end
	end
end
-- Paginated processing
local function paginate(tbl, size)
	local pages = {}
	for i = 1, #tbl, size do
		local page = {}
		for j = i, math.min(i+size-1, #tbl) do
			table.insert(page, tbl[j])
		end
		table.insert(pages, page)
	end
	return pages
end
local data = {1,2,3,4,5,6,7,8,9}
for i, page in ipairs(paginate(data, 3)) do
	print('Page', i, table.concat(page, ','))
end

-- Error handling in loops
for i = 1, 5 do
	local ok, err = pcall(function()
		if i == 3 then error('Loop error!') end
		print('Loop item:', i)
	end)
	if not ok then print('Caught error:', err) end
end

-- Parallel batch execution (simulated)
local function parallelBatch(tasks)
	local results = {}
	for _, task in ipairs(tasks) do
		local co = coroutine.create(task)
		local ok, res = coroutine.resume(co)
		table.insert(results, res)
	end
	return results
end
local jobs = {
	function() print('Job 1'); return 1 end,
	function() print('Job 2'); return 2 end,
	function() print('Job 3'); return 3 end,
}
parallelBatch(jobs)
batchProcess({1, 2, "bad", 4}, function(x) print(x * 2) end)

local function fetchPage(page)
	return { "item" .. page * 1, "item" .. page * 2 }
end
for page = 1, 3 do
	local items = fetchPage(page)
	for _, item in ipairs(items) do
		print("Page", page, "Item:", item)
	end
end

-- Workflow orchestration loop (enterprise scenario)
local steps = {
	function(x) print('Step 1:', x); return x + 1 end,
	function(x) print('Step 2:', x); return x * 2 end,
	function(x) print('Step 3:', x); return x - 3 end,
}
local function runWorkflow(val)
	for _, step in ipairs(steps) do
		val = step(val)
	end
	print('Workflow result:', val)
end
runWorkflow(5)

-- Error recovery in batch loop (product scenario)
local function robustBatch(tbl, fn)
	for i, v in ipairs(tbl) do
		local ok, res = pcall(fn, v)
		if not ok then
			print('Recovering from error at item', i, ':', res)
		else
			print('Processed:', res)
		end
	end
end
robustBatch({1, 'bad', 3}, function(x) if type(x) ~= 'number' then error('Not a number') end return x * 10 end)

-- Multi-service chaining in loop (enterprise pipeline)
local services = {
	function(x) print('Service A:', x); return x .. '-A' end,
	function(x) print('Service B:', x); return x .. '-B' end,
	function(x) print('Service C:', x); return x .. '-C' end,
}
local items = {'foo', 'bar'}
for _, item in ipairs(items) do
	local result = item
	for _, svc in ipairs(services) do
		result = svc(result)
	end
	print('Final result:', result)
end
