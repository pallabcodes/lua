-- Low-level/System Programming in Lua

-- Execute shell commands
os.execute('echo Hello from shell!')

-- Read environment variables
print("PATH:", os.getenv("PATH"))

-- Interact with processes
local handle = io.popen('ls -l')
local result = handle:read("*a")
handle:close()
print(result)

-- File permissions (chmod)
os.execute('chmod 644 test.txt')

-- Memory usage (LuaJIT only)
-- print(collectgarbage('count'))

-- FFI (LuaJIT):
-- local ffi = require 'ffi'
-- ffi.cdef[[ int printf(const char *fmt, ...); ]]
-- ffi.C.printf("Hello from C!\n")
