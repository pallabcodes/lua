-- Distributed Systems Patterns for Senior Backend Engineers

-- Required for real distributed systems (simulation here)
local json = require("json") or { encode = function(t) return "json_placeholder" end, decode = function(s) return {} end }
local socket = require("socket") or { tcp = function() return {} end, gettime = function() return os.time() end }

--[[
Consensus Algorithms (Critical for Google-level Distributed Systems)
]]

local Raft = {}

function Raft.createNode(nodeId, peers)
    return {
        nodeId = nodeId,
        peers = peers or {},
        state = "follower", -- follower, candidate, leader
        currentTerm = 0,
        votedFor = nil,
        log = {},
        commitIndex = 0,
        lastApplied = 0,
        
        -- Leader state
        nextIndex = {},
        matchIndex = {},
        
        -- Timing
        electionTimeout = math.random(150, 300), -- ms
        heartbeatInterval = 50, -- ms
        lastHeartbeat = 0,
        
        -- State transitions
        becomeFollower = function(self, term)
            self.state = "follower"
            self.currentTerm = term
            self.votedFor = nil
            self.lastHeartbeat = socket.gettime() * 1000
            print("Node", self.nodeId, "became follower for term", term)
        end,
        
        becomeCandidate = function(self)
            self.state = "candidate"
            self.currentTerm = self.currentTerm + 1
            self.votedFor = self.nodeId
            self.lastHeartbeat = socket.gettime() * 1000
            print("Node", self.nodeId, "became candidate for term", self.currentTerm)
            return self:requestVotes()
        end,
        
        becomeLeader = function(self)
            self.state = "leader"
            print("Node", self.nodeId, "became leader for term", self.currentTerm)
            
            -- Initialize leader state
            for _, peer in ipairs(self.peers) do
                self.nextIndex[peer] = #self.log + 1
                self.matchIndex[peer] = 0
            end
            
            -- Send initial heartbeats
            self:sendHeartbeats()
        end,
        
        requestVotes = function(self)
            local votes = 1 -- Vote for self
            local lastLogIndex = #self.log
            local lastLogTerm = self.log[lastLogIndex] and self.log[lastLogIndex].term or 0
            
            for _, peer in ipairs(self.peers) do
                local request = {
                    type = "RequestVote",
                    term = self.currentTerm,
                    candidateId = self.nodeId,
                    lastLogIndex = lastLogIndex,
                    lastLogTerm = lastLogTerm
                }
                
                -- Simulate vote response (in real system, would send over network)
                local granted = self:simulateVoteResponse(peer, request)
                if granted then votes = votes + 1 end
            end
            
            local majority = math.floor(#self.peers / 2) + 1
            return votes >= majority
        end,
        
        simulateVoteResponse = function(self, peer, request)
            -- Simulate peer's vote decision
            return math.random() > 0.3 -- 70% chance of granting vote
        end,
        
        sendHeartbeats = function(self)
            if self.state ~= "leader" then return end
            
            for _, peer in ipairs(self.peers) do
                local prevLogIndex = self.nextIndex[peer] - 1
                local prevLogTerm = self.log[prevLogIndex] and self.log[prevLogIndex].term or 0
                
                local request = {
                    type = "AppendEntries",
                    term = self.currentTerm,
                    leaderId = self.nodeId,
                    prevLogIndex = prevLogIndex,
                    prevLogTerm = prevLogTerm,
                    entries = {},
                    leaderCommit = self.commitIndex
                }
                
                -- Simulate sending heartbeat
                print("Leader", self.nodeId, "sending heartbeat to", peer)
            end
        end,
        
        appendEntry = function(self, command)
            if self.state ~= "leader" then
                return false, "Not leader"
            end
            
            local entry = {
                term = self.currentTerm,
                command = command,
                index = #self.log + 1
            }
            
            table.insert(self.log, entry)
            print("Leader", self.nodeId, "appended entry:", command)
            
            return true
        end,
        
        tick = function(self)
            local now = socket.gettime() * 1000
            
            if self.state == "leader" then
                if now - self.lastHeartbeat >= self.heartbeatInterval then
                    self:sendHeartbeats()
                    self.lastHeartbeat = now
                end
            else
                if now - self.lastHeartbeat >= self.electionTimeout then
                    if self:becomeCandidate() then
                        self:becomeLeader()
                    else
                        self:becomeFollower(self.currentTerm)
                    end
                end
            end
        end
    }
end

--[[
Distributed Locking (Essential for Data Consistency)
]]

local DistributedLock = {}

function DistributedLock.create(lockName, ttl)
    return {
        lockName = lockName,
        ttl = ttl or 30000, -- 30 seconds
        lockId = nil,
        acquired = false,
        
        acquire = function(self, timeout)
            timeout = timeout or 5000 -- 5 seconds
            local start = socket.gettime() * 1000
            local lockId = tostring(socket.gettime()) .. "-" .. math.random(10000)
            
            while socket.gettime() * 1000 - start < timeout do
                -- Try to acquire lock (Redis SET NX EX pattern)
                local success = self:tryAcquire(lockId)
                if success then
                    self.lockId = lockId
                    self.acquired = true
                    print("Acquired distributed lock:", self.lockName)
                    return true
                end
                
                -- Wait before retry
                os.execute("sleep 0.1")
            end
            
            return false, "Lock acquisition timeout"
        end,
        
        tryAcquire = function(self, lockId)
            -- Simulate Redis: SET lockName lockId NX EX ttl
            -- In real implementation, would use Redis or etcd
            return math.random() > 0.7 -- 30% success rate for simulation
        end,
        
        release = function(self)
            if not self.acquired or not self.lockId then
                return false, "Lock not acquired"
            end
            
            -- Lua script for atomic release (Redis)
            local luaScript = [[
                if redis.call("GET", KEYS[1]) == ARGV[1] then
                    return redis.call("DEL", KEYS[1])
                else
                    return 0
                end
            ]]
            
            -- Simulate successful release
            self.acquired = false
            self.lockId = nil
            print("Released distributed lock:", self.lockName)
            return true
        end,
        
        renew = function(self)
            if not self.acquired then return false end
            
            -- Extend lock TTL
            print("Renewed lock:", self.lockName)
            return true
        end
    }
end

--[[
Event Sourcing (Google-style Event-Driven Architecture)
]]

local EventStore = {}

function EventStore.create()
    return {
        events = {},
        snapshots = {},
        subscriptions = {},
        
        appendEvent = function(self, streamId, event)
            event.eventId = tostring(socket.gettime()) .. "-" .. math.random(10000)
            event.timestamp = socket.gettime()
            event.streamId = streamId
            
            if not self.events[streamId] then
                self.events[streamId] = {}
            end
            
            table.insert(self.events[streamId], event)
            
            -- Notify subscribers
            self:notifySubscribers(streamId, event)
            
            print("Event appended:", event.type, "to stream", streamId)
            return event.eventId
        end,
        
        getEvents = function(self, streamId, fromVersion)
            fromVersion = fromVersion or 1
            local stream = self.events[streamId] or {}
            local result = {}
            
            for i = fromVersion, #stream do
                table.insert(result, stream[i])
            end
            
            return result
        end,
        
        createSnapshot = function(self, streamId, version, state)
            if not self.snapshots[streamId] then
                self.snapshots[streamId] = {}
            end
            
            self.snapshots[streamId][version] = {
                version = version,
                state = state,
                timestamp = socket.gettime()
            }
            
            print("Snapshot created for stream", streamId, "at version", version)
        end,
        
        getSnapshot = function(self, streamId)
            local snapshots = self.snapshots[streamId] or {}
            local latestVersion = 0
            local latestSnapshot = nil
            
            for version, snapshot in pairs(snapshots) do
                if version > latestVersion then
                    latestVersion = version
                    latestSnapshot = snapshot
                end
            end
            
            return latestSnapshot
        end,
        
        subscribe = function(self, streamId, handler)
            if not self.subscriptions[streamId] then
                self.subscriptions[streamId] = {}
            end
            
            table.insert(self.subscriptions[streamId], handler)
            print("Subscribed to stream:", streamId)
        end,
        
        notifySubscribers = function(self, streamId, event)
            local subscribers = self.subscriptions[streamId] or {}
            for _, handler in ipairs(subscribers) do
                pcall(handler, event)
            end
        end,
        
        replay = function(self, streamId, aggregate)
            local snapshot = self:getSnapshot(streamId)
            local fromVersion = 1
            
            if snapshot then
                aggregate.state = snapshot.state
                fromVersion = snapshot.version + 1
            end
            
            local events = self:getEvents(streamId, fromVersion)
            for _, event in ipairs(events) do
                aggregate:apply(event)
            end
            
            return aggregate
        end
    }
end

--[[
CQRS (Command Query Responsibility Segregation)
]]

local CQRS = {}

function CQRS.createCommandHandler(eventStore)
    return {
        eventStore = eventStore,
        
        handle = function(self, command)
            local aggregate = self:loadAggregate(command.aggregateId)
            
            -- Validate command
            local valid, error = aggregate:validate(command)
            if not valid then
                return false, error
            end
            
            -- Execute command and generate events
            local events = aggregate:execute(command)
            
            -- Append events to store
            for _, event in ipairs(events) do
                self.eventStore:appendEvent(command.aggregateId, event)
            end
            
            return true, events
        end,
        
        loadAggregate = function(self, aggregateId)
            -- Load aggregate from event store
            return self.eventStore:replay(aggregateId, {
                state = {},
                validate = function(self, cmd) return true end,
                execute = function(self, cmd) return {} end,
                apply = function(self, event) end
            })
        end
    }
end

function CQRS.createQueryHandler(readModel)
    return {
        readModel = readModel,
        
        handle = function(self, query)
            -- Execute query against read model
            return self.readModel:query(query)
        end
    }
end

--[[
Saga Pattern (Distributed Transaction Management)
]]

local Saga = {}

function Saga.create(name)
    return {
        name = name,
        steps = {},
        compensations = {},
        state = "pending",
        currentStep = 0,
        
        addStep = function(self, action, compensation)
            table.insert(self.steps, action)
            table.insert(self.compensations, compensation)
        end,
        
        execute = function(self)
            print("Executing saga:", self.name)
            
            for i, step in ipairs(self.steps) do
                self.currentStep = i
                local success, error = pcall(step)
                
                if not success then
                    print("Saga step", i, "failed:", error)
                    self:compensate()
                    return false, error
                end
                
                print("Saga step", i, "completed")
            end
            
            self.state = "completed"
            print("Saga completed:", self.name)
            return true
        end,
        
        compensate = function(self)
            print("Compensating saga:", self.name)
            self.state = "compensating"
            
            -- Execute compensations in reverse order
            for i = self.currentStep, 1, -1 do
                local compensation = self.compensations[i]
                if compensation then
                    local success = pcall(compensation)
                    if success then
                        print("Compensation", i, "completed")
                    else
                        print("Compensation", i, "failed")
                    end
                end
            end
            
            self.state = "compensated"
            print("Saga compensated:", self.name)
        end
    }
end

--[[
Circuit Breaker (Resilience Pattern)
]]

local CircuitBreaker = {}

function CircuitBreaker.create(name, threshold, timeout)
    return {
        name = name,
        threshold = threshold or 5,
        timeout = timeout or 60000, -- 60 seconds
        failures = 0,
        state = "closed", -- closed, open, half-open
        lastFailureTime = 0,
        
        call = function(self, fn, ...)
            if self.state == "open" then
                if socket.gettime() * 1000 - self.lastFailureTime > self.timeout then
                    self.state = "half-open"
                    print("Circuit breaker", self.name, "half-open")
                else
                    return nil, "Circuit breaker open"
                end
            end
            
            local success, result = pcall(fn, ...)
            
            if success then
                if self.state == "half-open" then
                    self.state = "closed"
                    self.failures = 0
                    print("Circuit breaker", self.name, "closed")
                end
                return result
            else
                self.failures = self.failures + 1
                self.lastFailureTime = socket.gettime() * 1000
                
                if self.failures >= self.threshold then
                    self.state = "open"
                    print("Circuit breaker", self.name, "opened")
                end
                
                return nil, result
            end
        end,
        
        getState = function(self)
            return {
                state = self.state,
                failures = self.failures,
                threshold = self.threshold
            }
        end,
        
        reset = function(self)
            self.state = "closed"
            self.failures = 0
            print("Circuit breaker", self.name, "reset")
        end
    }
end

--[[
Bulkhead Pattern (Isolation)
]]

local Bulkhead = {}

function Bulkhead.createResourcePool(name, maxSize)
    return {
        name = name,
        maxSize = maxSize,
        available = {},
        inUse = {},
        
        acquire = function(self, timeout)
            timeout = timeout or 5000
            local start = socket.gettime() * 1000
            
            while socket.gettime() * 1000 - start < timeout do
                if #self.available > 0 then
                    local resource = table.remove(self.available)
                    table.insert(self.inUse, resource)
                    return resource
                end
                os.execute("sleep 0.1")
            end
            
            return nil, "Resource pool exhausted"
        end,
        
        release = function(self, resource)
            for i, r in ipairs(self.inUse) do
                if r == resource then
                    table.remove(self.inUse, i)
                    table.insert(self.available, resource)
                    return true
                end
            end
            return false
        end,
        
        getStats = function(self)
            return {
                available = #self.available,
                inUse = #self.inUse,
                total = #self.available + #self.inUse,
                maxSize = self.maxSize
            }
        end
    }
end

--[[
Example: Distributed Banking System
]]

local function distributedBankingDemo()
    print("=== Distributed Banking System Demo ===")
    
    -- Create event store
    local eventStore = EventStore.create()
    
    -- Create distributed lock for account operations
    local accountLock = DistributedLock.create("account:transfer:123-456", 30000)
    
    -- Create circuit breaker for external service calls
    local paymentBreaker = CircuitBreaker.create("payment-service", 3, 10000)
    
    -- Money transfer saga
    local transferSaga = Saga.create("money-transfer-123")
    
    transferSaga:addStep(
        function()
            -- Step 1: Reserve funds from source account
            if not accountLock:acquire(5000) then
                error("Could not acquire account lock")
            end
            print("Reserved funds from source account")
        end,
        function()
            -- Compensation: Release reservation
            accountLock:release()
            print("Released fund reservation")
        end
    )
    
    transferSaga:addStep(
        function()
            -- Step 2: Credit destination account
            local success = paymentBreaker:call(function()
                -- Simulate payment service call
                if math.random() > 0.8 then error("Payment service error") end
                return true
            end)
            if not success then error("Payment failed") end
            print("Credited destination account")
        end,
        function()
            -- Compensation: Reverse credit
            print("Reversed destination account credit")
        end
    )
    
    transferSaga:addStep(
        function()
            -- Step 3: Commit transaction
            eventStore:appendEvent("account:123", {
                type = "MoneyTransferred",
                amount = 100,
                from = "123",
                to = "456"
            })
            print("Transaction committed")
        end,
        function()
            -- Compensation: Reverse transaction
            eventStore:appendEvent("account:123", {
                type = "TransactionReversed",
                originalAmount = 100
            })
            print("Transaction reversed")
        end
    )
    
    -- Execute the saga
    local success, error = transferSaga:execute()
    if success then
        print("Money transfer completed successfully")
    else
        print("Money transfer failed:", error)
    end
    
    -- Clean up
    accountLock:release()
    
    print("\nCircuit breaker state:", json.encode(paymentBreaker:getState()))
end

--[[
Example: Event-Sourced User Management
]]

local function eventSourcingDemo()
    print("\n=== Event Sourcing Demo ===")
    
    local eventStore = EventStore.create()
    
    -- Subscribe to user events
    eventStore:subscribe("user:123", function(event)
        print("Event received:", event.type, "for user", event.streamId)
    end)
    
    -- Append user events
    eventStore:appendEvent("user:123", {
        type = "UserCreated",
        email = "user@example.com",
        name = "John Doe"
    })
    
    eventStore:appendEvent("user:123", {
        type = "EmailChanged",
        oldEmail = "user@example.com",
        newEmail = "john.doe@example.com"
    })
    
    eventStore:appendEvent("user:123", {
        type = "UserSuspended",
        reason = "Policy violation"
    })
    
    -- Create snapshot
    eventStore:createSnapshot("user:123", 3, {
        email = "john.doe@example.com",
        name = "John Doe",
        status = "suspended"
    })
    
    -- Query events
    local events = eventStore:getEvents("user:123")
    print("Total events for user:123:", #events)
end

-- Run demos
distributedBankingDemo()
eventSourcingDemo()

print("\nDistributed systems patterns loaded successfully!")
