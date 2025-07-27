-- Real-world Enterprise Pipeline Example (multi-module, multi-service)

-- Step 1: Load config
local config = require('config')

-- Step 2: Fetch data from API
-- local http = require('socket.http')
-- local data = http.request(config.api_url)

-- Step 3: Transform data
local function transform(data)
    return data:upper()
end

-- Step 4: Cache result in Redis
-- os.execute('redis-cli set result "' .. transform(data) .. '"')

-- Step 5: Log and notify
-- local logger = require('logger')
-- logger.log('Pipeline complete')
-- os.execute('redis-cli PUBLISH events "Pipeline complete"')
