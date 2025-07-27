-- Networking basics in Lua
-- Simple HTTP GET using LuaSocket
local http = require("socket.http")
local body, code = http.request("http://example.com")
print("Status:", code)
print("Body:", body)

-- TCP client example
local socket = require("socket")
local tcp = socket.tcp()
tcp:connect("127.0.0.1", 8080)
tcp:send("Hello server!\n")
tcp:close()

--[[
Advanced Networking for Big Tech/Product Companies
]]

-- UDP client example
local udp = socket.udp()
udp:setpeername("127.0.0.1", 8081)
udp:send("Hello UDP server!")
udp:close()

-- TCP server example
local server = socket.tcp()
server:bind("127.0.0.1", 9090)
server:listen(1)
print("TCP server listening on port 9090...")
local client = server:accept()
local msg = client:receive()
print("Received from client:", msg)
client:send("Hello from server!\n")
client:close()
server:close()

-- Error handling for network operations
local function safeRequest(url)
    local ok, body, code = pcall(function()
        return http.request(url)
    end)
    if ok then
        print("Safe request status:", code)
        print("Safe request body:", body)
    else
        print("Network error:", body)
    end
end
-- safeRequest("http://example.com")

-- JSON API call (requires dkjson)
-- local json = require "dkjson"
-- local body, code = http.request("https://api.github.com")
-- local obj, pos, err = json.decode(body)
-- if obj then print("API result:", obj) end

-- Product scenario: health check endpoint
local function healthCheck(host, port)
    local sock = socket.tcp()
    local ok, err = sock:connect(host, port)
    if ok then
        print("Health check passed for", host, port)
        sock:close()
    else
        print("Health check failed for", host, port, err)
    end
end
-- healthCheck("127.0.0.1", 8080)

local endpoints = { "http://example.com", "http://localhost:8000" }
for _, url in ipairs(endpoints) do
    -- Uncomment to use: safeRequest(url)
end

-- Retry logic for network requests (enterprise scenario)
local function retryRequest(url, maxRetries)
    maxRetries = maxRetries or 3
    for attempt = 1, maxRetries do
        local body, code = http.request(url)
        if code == 200 then return body end
        print('Attempt', attempt, 'failed for', url)
    end
    return nil, 'All attempts failed'
end
-- local resp = retryRequest('http://example.com', 3)

-- Circuit breaker pattern (product scenario)
local breaker = { failures = 0, threshold = 2, open = false }
local function circuitRequest(url)
    if breaker.open then return nil, 'Circuit open' end
    local body, code = http.request(url)
    if code ~= 200 then
        breaker.failures = breaker.failures + 1
        if breaker.failures >= breaker.threshold then breaker.open = true end
        return nil, 'Request failed'
    end
    breaker.failures = 0
    return body
end
-- local resp = circuitRequest('http://example.com')

-- Async request batching (simulated)
local function asyncBatch(urls)
    local results = {}
    for _, url in ipairs(urls) do
        local co = coroutine.create(function()
            local body, code = http.request(url)
            table.insert(results, { url = url, code = code })
        end)
        coroutine.resume(co)
    end
    return results
end
-- local batchResults = asyncBatch(endpoints)

-- Product scenario: multi-endpoint health check
local function multiHealthCheck(endpoints, port)
    for _, host in ipairs(endpoints) do
        healthCheck(host, port)
    end
end
-- multiHealthCheck({ '127.0.0.1', 'localhost' }, 8080)
