-- Performance Profiling and Optimization in Lua

-- Timing code execution
local start = os.clock()
for i = 1, 1e6 do end
local elapsed = os.clock() - start
print('Elapsed:', elapsed)

-- Memory usage
print('Memory (KB):', collectgarbage('count'))

-- Profiling with LuaProfiler (external)
-- require('profiler').start()
-- ... code ...
-- require('profiler').stop()

-- Optimization: localize frequently used globals
local print = print
for i = 1, 10 do print(i) end
