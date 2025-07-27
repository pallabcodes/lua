-- File I/O and OS interaction

-- Write to a file
local f = io.open("test.txt", "w")
f:write("Hello, Lua file!\n")
f:close()

-- Read from a file
local f = io.open("test.txt", "r")
local content = f:read("*all")
print(content)
f:close()

-- List files in current directory
for file in io.popen('ls'):lines() do
    print(file)
end

--[[
Advanced File I/O and OS Interaction for Big Tech/Product Companies
]]

-- Error handling for file operations
local function safeOpen(filename, mode)
    local f, err = io.open(filename, mode)
    if not f then
        print("File error:", err)
        return nil
    end
    return f
end
local f = safeOpen("missing.txt", "r")
if f then f:close() end

-- Read/write JSON (requires dkjson)
-- local json = require "dkjson"
-- local data = { name = "Alice", age = 30 }
-- local f = io.open("data.json", "w")
-- f:write(json.encode(data))
-- f:close()
-- local f = io.open("data.json", "r")
-- local content = f:read("*all")
-- local obj = json.decode(content)
-- print(obj.name, obj.age)

-- Read/write CSV
local function writeCSV(filename, rows)
    local f = io.open(filename, "w")
    for _, row in ipairs(rows) do
        f:write(table.concat(row, ","), "\n")
    end
    f:close()
end
local function readCSV(filename)
    local f = io.open(filename, "r")
    local result = {}
    for line in f:lines() do
        local row = {}
        for value in string.gmatch(line, "[^,]+") do
            table.insert(row, value)
        end
        table.insert(result, row)
    end
    f:close()
    return result
end
writeCSV("test.csv", { {"name", "age"}, {"Alice", "30"}, {"Bob", "25"} })
local csvData = readCSV("test.csv")
for i, row in ipairs(csvData) do print("CSV row", i, table.concat(row, ", ")) end

local function createTempFile()
    local fname = os.tmpname()
    local f = io.open(fname, "w")
    f:write("Temporary data\n")
    f:close()
    return fname
end
local tempFile = createTempFile()
print("Temp file created:", tempFile)

-- Permission check (enterprise scenario)
local function hasPermission(file, mode)
    local f = io.open(file, mode)
    if f then f:close(); return true else return false end
end
print('Can read test.txt:', hasPermission('test.txt', 'r'))
print('Can write test.txt:', hasPermission('test.txt', 'w'))

-- FFI integration stub (system programming)
-- local ffi = require('ffi')
-- ffi.cdef[[ int getpid(void); ]]
-- print('Process ID:', ffi.C.getpid())

-- System health check (product scenario)
local function systemHealth()
    local ok = os.execute('ls') == 0
    print('System health:', ok and 'OK' or 'FAIL')
end
systemHealth()

-- Read environment variable
local home = os.getenv("HOME")
print("HOME dir:", home)

-- Product scenario: log file rotation
local function rotateLog(logfile)
    local timestamp = os.date("%Y%m%d%H%M%S")
    local newname = logfile .. "." .. timestamp
    os.rename(logfile, newname)
    print("Log rotated to:", newname)
end
-- rotateLog("app.log")

local files = { "test.txt", "test.csv" }
for _, fname in ipairs(files) do
    local f = safeOpen(fname, "r")
    if f then
        print("Processing file:", fname)
        f:close()
    end
end
-- Batch error recovery (enterprise scenario)
local function batchSafe(files, fn)
    for _, fname in ipairs(files) do
        local ok, err = pcall(fn, fname)
        if not ok then print('Error processing', fname, ':', err) end
    end
end
batchSafe(files, function(f)
    local h = safeOpen(f, 'r')
    if h then h:close() else error('Cannot open ' .. f) end
end)
