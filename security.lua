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

-- Secrets management (enterprise scenario)
local secrets = {}
local function storeSecret(key, value)
    secrets[key] = value
    print('Secret stored:', key)
end
local function getSecret(key)
    return secrets[key]
end
storeSecret('api_key', 'secret123')
print('Retrieved secret:', getSecret('api_key'))

-- Permission check (product scenario)
local function hasPermission(user, action)
    local perms = user.permissions or {}
    for _, perm in ipairs(perms) do
        if perm == action then return true end
    end
    return false
end
local user = { permissions = { 'read', 'write' } }
print('Can delete:', hasPermission(user, 'delete'))

-- Audit logging (enterprise scenario)
local function auditLog(user, action, resource)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    print('[AUDIT]', timestamp, user, action, resource)
end
auditLog('alice', 'login', 'system')
auditLog('bob', 'delete', 'file.txt')
