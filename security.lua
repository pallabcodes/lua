-- Security Best Practices in Lua

-- Input validation
local function isSafeString(s)
    return not s:find('[^%w%p%s]')
end
print('Safe:', isSafeString('hello123!'))
print('Unsafe:', isSafeString('hello\0'))

-- Sandboxing (using setfenv in Lua 5.1 or debug.setupvalue in LuaJIT)
-- local env = {}
-- setfenv(loadstring('print("sandboxed")'), env)()

-- Safe eval (never eval untrusted code)
-- local code = 'return 2+2'
-- local f = loadstring(code)
-- if f then print(f()) end
