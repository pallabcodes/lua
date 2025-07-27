-- System Design Patterns and Infrastructure Tools for Senior Engineers

-- Simulation of external dependencies
local json = require("json") or { encode = function(t) return "json_placeholder" end, decode = function(s) return {} end }
local socket = require("socket") or { gettime = function() return os.time() end }

--[[
Load Balancer Implementation (Google/AWS-style)
]]

local LoadBalancer = {}

function LoadBalancer.create(algorithm)
    local lb = {
        algorithm = algorithm or "round_robin",
        servers = {},
        current = 1,
        weights = {},
        health_checks = {},
        
        addServer = function(self, server, weight)
            table.insert(self.servers, server)
            self.weights[server] = weight or 1
            self.health_checks[server] = true
            print("Added server:", server, "with weight:", weight or 1)
        end,
        
        removeServer = function(self, server)
            for i, s in ipairs(self.servers) do
                if s == server then
                    table.remove(self.servers, i)
                    self.weights[server] = nil
                    self.health_checks[server] = nil
                    print("Removed server:", server)
                    break
                end
            end
        end,
        
        getServer = function(self)
            local healthy_servers = {}
            for _, server in ipairs(self.servers) do
                if self.health_checks[server] then
                    table.insert(healthy_servers, server)
                end
            end
            
            if #healthy_servers == 0 then
                return nil, "No healthy servers available"
            end
            
            if self.algorithm == "round_robin" then
                return self:roundRobin(healthy_servers)
            elseif self.algorithm == "weighted_round_robin" then
                return self:weightedRoundRobin(healthy_servers)
            elseif self.algorithm == "least_connections" then
                return self:leastConnections(healthy_servers)
            elseif self.algorithm == "random" then
                return healthy_servers[math.random(#healthy_servers)]
            else
                return healthy_servers[1]
            end
        end,
        
        roundRobin = function(self, servers)
            if self.current > #servers then self.current = 1 end
            local server = servers[self.current]
            self.current = self.current + 1
            return server
        end,
        
        weightedRoundRobin = function(self, servers)
            local totalWeight = 0
            for _, server in ipairs(servers) do
                totalWeight = totalWeight + self.weights[server]
            end
            
            local random = math.random(totalWeight)
            local weightSum = 0
            
            for _, server in ipairs(servers) do
                weightSum = weightSum + self.weights[server]
                if random <= weightSum then
                    return server
                end
            end
            
            return servers[1]
        end,
        
        leastConnections = function(self, servers)
            -- Simulate connection counts
            local minConnections = math.huge
            local selectedServer = servers[1]
            
            for _, server in ipairs(servers) do
                local connections = math.random(1, 100) -- Simulate
                if connections < minConnections then
                    minConnections = connections
                    selectedServer = server
                end
            end
            
            return selectedServer
        end,
        
        healthCheck = function(self, server)
            -- Simulate health check (in real world, would ping server)
            local healthy = math.random() > 0.1 -- 90% success rate
            self.health_checks[server] = healthy
            return healthy
        end,
        
        runHealthChecks = function(self)
            for _, server in ipairs(self.servers) do
                self:healthCheck(server)
            end
        end,
        
        getStats = function(self)
            local healthy = 0
            for _, health in pairs(self.health_checks) do
                if health then healthy = healthy + 1 end
            end
            
            return {
                totalServers = #self.servers,
                healthyServers = healthy,
                algorithm = self.algorithm
            }
        end
    }
    
    return lb
end

--[[
Rate Limiter (Token Bucket & Sliding Window)
]]

local RateLimiter = {}

function RateLimiter.tokenBucket(capacity, refillRate)
    return {
        capacity = capacity,
        tokens = capacity,
        refillRate = refillRate, -- tokens per second
        lastRefill = socket.gettime(),
        
        isAllowed = function(self, tokensRequested)
            tokensRequested = tokensRequested or 1
            self:refill()
            
            if self.tokens >= tokensRequested then
                self.tokens = self.tokens - tokensRequested
                return true
            end
            
            return false
        end,
        
        refill = function(self)
            local now = socket.gettime()
            local timePassed = now - self.lastRefill
            local tokensToAdd = timePassed * self.refillRate
            
            self.tokens = math.min(self.capacity, self.tokens + tokensToAdd)
            self.lastRefill = now
        end,
        
        getTokens = function(self)
            self:refill()
            return self.tokens
        end
    }
end

function RateLimiter.slidingWindow(windowSize, limit)
    return {
        windowSize = windowSize, -- seconds
        limit = limit,
        requests = {},
        
        isAllowed = function(self, identifier)
            identifier = identifier or "default"
            local now = socket.gettime()
            
            if not self.requests[identifier] then
                self.requests[identifier] = {}
            end
            
            -- Remove old requests outside window
            local userRequests = self.requests[identifier]
            while #userRequests > 0 and userRequests[1] <= now - self.windowSize do
                table.remove(userRequests, 1)
            end
            
            -- Check if under limit
            if #userRequests < self.limit then
                table.insert(userRequests, now)
                return true
            end
            
            return false
        end,
        
        getRequestCount = function(self, identifier)
            identifier = identifier or "default"
            local now = socket.gettime()
            local userRequests = self.requests[identifier] or {}
            
            -- Count requests in current window
            local count = 0
            for _, timestamp in ipairs(userRequests) do
                if timestamp > now - self.windowSize then
                    count = count + 1
                end
            end
            
            return count
        end
    }
end

--[[
Caching Layer with TTL and LRU Eviction
]]

local Cache = {}

function Cache.create(maxSize, defaultTTL)
    return {
        maxSize = maxSize or 1000,
        defaultTTL = defaultTTL or 3600, -- 1 hour
        data = {},
        accessOrder = {},
        timestamps = {},
        
        set = function(self, key, value, ttl)
            ttl = ttl or self.defaultTTL
            local now = socket.gettime()
            
            -- Remove if already exists
            if self.data[key] then
                self:removeFromAccessOrder(key)
            end
            
            -- Check if cache is full
            if not self.data[key] and self:size() >= self.maxSize then
                self:evictLRU()
            end
            
            self.data[key] = value
            self.timestamps[key] = now + ttl
            table.insert(self.accessOrder, key)
        end,
        
        get = function(self, key)
            local now = socket.gettime()
            
            -- Check if exists and not expired
            if self.data[key] and self.timestamps[key] > now then
                -- Move to end (most recently used)
                self:removeFromAccessOrder(key)
                table.insert(self.accessOrder, key)
                return self.data[key]
            elseif self.data[key] then
                -- Expired, remove
                self:delete(key)
            end
            
            return nil
        end,
        
        delete = function(self, key)
            if self.data[key] then
                self.data[key] = nil
                self.timestamps[key] = nil
                self:removeFromAccessOrder(key)
                return true
            end
            return false
        end,
        
        removeFromAccessOrder = function(self, key)
            for i, k in ipairs(self.accessOrder) do
                if k == key then
                    table.remove(self.accessOrder, i)
                    break
                end
            end
        end,
        
        evictLRU = function(self)
            if #self.accessOrder > 0 then
                local lruKey = table.remove(self.accessOrder, 1)
                self.data[lruKey] = nil
                self.timestamps[lruKey] = nil
                print("Evicted LRU key:", lruKey)
            end
        end,
        
        size = function(self)
            local count = 0
            for _ in pairs(self.data) do count = count + 1 end
            return count
        end,
        
        cleanup = function(self)
            local now = socket.gettime()
            local expired = {}
            
            for key, expiry in pairs(self.timestamps) do
                if expiry <= now then
                    table.insert(expired, key)
                end
            end
            
            for _, key in ipairs(expired) do
                self:delete(key)
            end
            
            return #expired
        end,
        
        getStats = function(self)
            return {
                size = self:size(),
                maxSize = self.maxSize,
                accessOrderLength = #self.accessOrder
            }
        end
    }
end

--[[
Message Queue System (Producer-Consumer)
]]

local MessageQueue = {}

function MessageQueue.create(maxSize)
    return {
        maxSize = maxSize or 10000,
        queue = {},
        subscribers = {},
        deadLetterQueue = {},
        
        publish = function(self, topic, message, priority)
            priority = priority or 5 -- Default priority
            
            if not self.queue[topic] then
                self.queue[topic] = {}
            end
            
            if #self.queue[topic] >= self.maxSize then
                return false, "Queue full"
            end
            
            local envelope = {
                id = tostring(socket.gettime()) .. "-" .. math.random(10000),
                message = message,
                priority = priority,
                timestamp = socket.gettime(),
                retryCount = 0
            }
            
            -- Insert based on priority (higher number = higher priority)
            local inserted = false
            for i, msg in ipairs(self.queue[topic]) do
                if priority > msg.priority then
                    table.insert(self.queue[topic], i, envelope)
                    inserted = true
                    break
                end
            end
            
            if not inserted then
                table.insert(self.queue[topic], envelope)
            end
            
            print("Published message to", topic, "with priority", priority)
            return envelope.id
        end,
        
        subscribe = function(self, topic, handler, options)
            options = options or {}
            
            if not self.subscribers[topic] then
                self.subscribers[topic] = {}
            end
            
            local subscriber = {
                handler = handler,
                maxRetries = options.maxRetries or 3,
                ackTimeout = options.ackTimeout or 30
            }
            
            table.insert(self.subscribers[topic], subscriber)
            print("Subscribed to topic:", topic)
        end,
        
        consume = function(self, topic)
            if not self.queue[topic] or #self.queue[topic] == 0 then
                return nil
            end
            
            local message = table.remove(self.queue[topic], 1)
            local subscribers = self.subscribers[topic] or {}
            
            for _, subscriber in ipairs(subscribers) do
                local success = pcall(subscriber.handler, message.message)
                
                if not success then
                    message.retryCount = message.retryCount + 1
                    
                    if message.retryCount <= subscriber.maxRetries then
                        -- Retry later
                        table.insert(self.queue[topic], message)
                        print("Message retry", message.retryCount, "for", message.id)
                    else
                        -- Send to dead letter queue
                        if not self.deadLetterQueue[topic] then
                            self.deadLetterQueue[topic] = {}
                        end
                        table.insert(self.deadLetterQueue[topic], message)
                        print("Message sent to dead letter queue:", message.id)
                    end
                    
                    break
                end
            end
            
            return message
        end,
        
        getQueueSize = function(self, topic)
            return self.queue[topic] and #self.queue[topic] or 0
        end,
        
        getDeadLetterSize = function(self, topic)
            return self.deadLetterQueue[topic] and #self.deadLetterQueue[topic] or 0
        end,
        
        getStats = function(self)
            local stats = { topics = {} }
            
            for topic, queue in pairs(self.queue) do
                stats.topics[topic] = {
                    queueSize = #queue,
                    deadLetterSize = self:getDeadLetterSize(topic),
                    subscribers = self.subscribers[topic] and #self.subscribers[topic] or 0
                }
            end
            
            return stats
        end
    }
end

--[[
Service Discovery and Registry
]]

local ServiceRegistry = {}

function ServiceRegistry.create()
    return {
        services = {},
        healthChecks = {},
        
        register = function(self, serviceName, endpoint, metadata)
            metadata = metadata or {}
            
            if not self.services[serviceName] then
                self.services[serviceName] = {}
            end
            
            local service = {
                endpoint = endpoint,
                metadata = metadata,
                registeredAt = socket.gettime(),
                lastSeen = socket.gettime(),
                healthy = true
            }
            
            table.insert(self.services[serviceName], service)
            print("Registered service:", serviceName, "at", endpoint)
            
            return #self.services[serviceName]
        end,
        
        discover = function(self, serviceName, strategy)
            strategy = strategy or "random"
            local services = self.services[serviceName] or {}
            local healthy = {}
            
            for _, service in ipairs(services) do
                if service.healthy then
                    table.insert(healthy, service)
                end
            end
            
            if #healthy == 0 then
                return nil, "No healthy services found"
            end
            
            if strategy == "random" then
                return healthy[math.random(#healthy)]
            elseif strategy == "round_robin" then
                -- Simple round robin
                local index = (socket.gettime() % #healthy) + 1
                return healthy[math.floor(index)]
            else
                return healthy[1]
            end
        end,
        
        healthCheck = function(self, serviceName)
            local services = self.services[serviceName] or {}
            
            for _, service in ipairs(services) do
                -- Simulate health check
                service.healthy = math.random() > 0.1 -- 90% success
                service.lastSeen = socket.gettime()
            end
        end,
        
        unregister = function(self, serviceName, endpoint)
            local services = self.services[serviceName] or {}
            
            for i, service in ipairs(services) do
                if service.endpoint == endpoint then
                    table.remove(services, i)
                    print("Unregistered service:", serviceName, "at", endpoint)
                    return true
                end
            end
            
            return false
        end,
        
        getServices = function(self, serviceName)
            return self.services[serviceName] or {}
        end,
        
        cleanup = function(self)
            local now = socket.gettime()
            local timeout = 300 -- 5 minutes
            
            for serviceName, services in pairs(self.services) do
                for i = #services, 1, -1 do
                    local service = services[i]
                    if now - service.lastSeen > timeout then
                        table.remove(services, i)
                        print("Cleaned up stale service:", serviceName, service.endpoint)
                    end
                end
            end
        end
    }
end

--[[
Example: Distributed E-commerce System
]]

local function distributedEcommerceDemo()
    print("=== Distributed E-commerce System Demo ===")
    
    -- Setup load balancer for API servers
    local apiLoadBalancer = LoadBalancer.create("weighted_round_robin")
    apiLoadBalancer:addServer("api-1.example.com", 3)
    apiLoadBalancer:addServer("api-2.example.com", 2)
    apiLoadBalancer:addServer("api-3.example.com", 1)
    
    -- Setup rate limiter for API protection
    local rateLimiter = RateLimiter.slidingWindow(60, 100) -- 100 requests per minute
    
    -- Setup cache for product data
    local productCache = Cache.create(1000, 1800) -- 30 minutes TTL
    
    -- Setup message queue for order processing
    local orderQueue = MessageQueue.create(5000)
    
    -- Setup service registry
    local serviceRegistry = ServiceRegistry.create()
    
    -- Register services
    serviceRegistry:register("payment-service", "payment-1.internal:8080", { version = "1.2.0" })
    serviceRegistry:register("inventory-service", "inventory-1.internal:8081", { version = "2.1.0" })
    serviceRegistry:register("notification-service", "notify-1.internal:8082", { version = "1.0.5" })
    
    -- Subscribe to order events
    orderQueue:subscribe("orders", function(order)
        print("Processing order:", order.orderId)
        
        -- Simulate payment processing
        local paymentService = serviceRegistry:discover("payment-service")
        if paymentService then
            print("Using payment service:", paymentService.endpoint)
        end
        
        -- Simulate inventory update
        local inventoryService = serviceRegistry:discover("inventory-service")
        if inventoryService then
            print("Updating inventory via:", inventoryService.endpoint)
        end
        
        -- Send notification
        local notificationService = serviceRegistry:discover("notification-service")
        if notificationService then
            print("Sending notification via:", notificationService.endpoint)
        end
    end)
    
    -- Simulate API requests
    for i = 1, 10 do
        -- Rate limiting check
        local userId = "user" .. math.random(1, 5)
        if rateLimiter:isAllowed(userId) then
            -- Get server from load balancer
            local server = apiLoadBalancer:getServer()
            print("Request", i, "routed to:", server)
            
            -- Check cache for product
            local productId = "product" .. math.random(1, 3)
            local product = productCache:get(productId)
            
            if not product then
                product = { id = productId, name = "Product " .. productId, price = math.random(10, 100) }
                productCache:set(productId, product)
                print("Cached product:", productId)
            else
                print("Cache hit for product:", productId)
            end
            
            -- Place order (simulate)
            if math.random() > 0.7 then
                local orderId = "order-" .. i
                orderQueue:publish("orders", {
                    orderId = orderId,
                    userId = userId,
                    productId = productId,
                    quantity = math.random(1, 5)
                }, math.random(1, 10))
            end
        else
            print("Rate limit exceeded for user:", userId)
        end
    end
    
    -- Process some orders
    for i = 1, 3 do
        orderQueue:consume("orders")
    end
    
    -- Run health checks
    apiLoadBalancer:runHealthChecks()
    serviceRegistry:healthCheck("payment-service")
    serviceRegistry:healthCheck("inventory-service")
    
    -- Print stats
    print("\n=== System Stats ===")
    print("Load Balancer:", json.encode(apiLoadBalancer:getStats()))
    print("Cache:", json.encode(productCache:getStats()))
    print("Message Queue:", json.encode(orderQueue:getStats()))
    
    -- Cleanup
    productCache:cleanup()
    serviceRegistry:cleanup()
end

-- Run the demo
distributedEcommerceDemo()

print("\nSystem design patterns loaded successfully!")

return {
    LoadBalancer = LoadBalancer,
    RateLimiter = RateLimiter,
    Cache = Cache,
    MessageQueue = MessageQueue,
    ServiceRegistry = ServiceRegistry
}
