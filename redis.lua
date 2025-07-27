-- Redis usage with Lua (using redis-cli or Lua bindings)
-- Example: EVAL script from redis-cli
-- redis-cli EVAL "return redis.call('set', 'foo', 'bar')" 0

-- Using lua-resty-redis (OpenResty)
-- local redis = require "resty.redis"
-- local red = redis:new()
-- red:set_timeout(1000)
-- red:connect("127.0.0.1", 6379)
-- red:set("key", "value")
-- local val = red:get("key")
-- print(val)

-- For standalone Lua, use os.execute or io.popen to call redis-cli
os.execute('redis-cli set mykey 123')
os.execute('redis-cli get mykey')

--[[
Advanced Redis Usage for Big Tech/Product Companies
]]

-- Lua scripting with redis-cli (atomic operations)
-- redis-cli EVAL "local v = redis.call('incr', 'counter'); if v > 10 then redis.call('set', 'counter', 0) end; return v" 0

-- Transactions (MULTI/EXEC)
os.execute('redis-cli MULTI')
os.execute('redis-cli set transkey 1')
os.execute('redis-cli incr transkey')
os.execute('redis-cli EXEC')

-- Pub/Sub example (requires two terminals)
-- Terminal 1: redis-cli SUBSCRIBE mychannel
-- Terminal 2: redis-cli PUBLISH mychannel "Hello from Lua!"

-- Error handling (standalone Lua)
local function safeRedis(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    local success = handle:close()
    if not success then
        print("Redis command failed:", cmd)
    end
    return result
end
print("Safe get:", safeRedis('redis-cli get mykey'))

-- Product scenario: caching API responses
local function cacheApiResponse(key, value)
    os.execute('redis-cli set ' .. key .. ' "' .. value .. '"')
end
local function getApiResponse(key)
    local handle = io.popen('redis-cli get ' .. key)
    local result = handle:read("*a")
    handle:close()
    return result
end
cacheApiResponse('user:123', '{"name":"Alice","age":30}')
print("Cached user:", getApiResponse('user:123'))

-- Expiry (TTL)
os.execute('redis-cli set tempkey "temp" EX 10') -- Key expires in 10 seconds

-- List operations
os.execute('redis-cli rpush mylist "item1" "item2" "item3"')
print("List items:", safeRedis('redis-cli lrange mylist 0 -1'))

-- Set operations
os.execute('redis-cli sadd myset "a" "b" "c"')
print("Set members:", safeRedis('redis-cli smembers myset'))

os.execute('redis-cli hset user:1 name "Bob" age 25')
print("User hash:", safeRedis('redis-cli hgetall user:1'))

-- Distributed locking (product scenario)
local function acquireLock(lockKey)
    local res = safeRedis('redis-cli set ' .. lockKey .. ' 1 NX EX 5')
    if res:find('OK') then print('Lock acquired:', lockKey) return true end
    print('Lock failed:', lockKey) return false
end
acquireLock('mylock')

-- Rate limiting (product scenario)
local function rateLimit(key, limit)
    local count = tonumber(safeRedis('redis-cli incr ' .. key))
    if count == 1 then safeRedis('redis-cli expire ' .. key .. ' 10') end
    if count > limit then print('Rate limit exceeded for', key) return false end
    print('Rate limit ok for', key, 'count:', count) return true
end
rateLimit('user:rate', 5)

-- Leaderboard scenario
local function updateLeaderboard(user, score)
    safeRedis('redis-cli zadd leaderboard ' .. score .. ' ' .. user)
end
local function getTopLeaderboard(n)
    local res = safeRedis('redis-cli zrevrange leaderboard 0 ' .. (n-1) .. ' WITHSCORES')
    print('Top leaderboard:', res)
end
updateLeaderboard('Alice', 100)
updateLeaderboard('Bob', 150)
getTopLeaderboard(2)
