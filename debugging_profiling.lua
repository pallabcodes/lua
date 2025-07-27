-- Advanced Debugging and Profiling for Production Systems in Lua

-- Debug information and stack traces
local function getStackTrace()
    local trace = {}
    local level = 2
    while true do
        local info = debug.getinfo(level, "Snl")
        if not info then break end
        table.insert(trace, {
            source = info.source,
            name = info.name or "anonymous",
            line = info.currentline,
            func = info.what
        })
        level = level + 1
    end
    return trace
end

-- Enhanced error handling with stack traces
local function safeCall(fn, ...)
    local function errorHandler(err)
        local stack = getStackTrace()
        print("ERROR:", err)
        print("Stack trace:")
        for i, frame in ipairs(stack) do
            print(string.format("  %d. %s:%d in %s (%s)", 
                i, frame.source, frame.line, frame.name, frame.func))
        end
        return err
    end
    return xpcall(fn, errorHandler, ...)
end

-- Example usage
local function buggyFunction()
    error("Something went wrong!")
end
safeCall(buggyFunction)

-- Memory profiling and leak detection
local function memoryProfiler()
    local profile = {
        start_memory = collectgarbage("count"),
        allocations = {},
        peak_memory = 0,
        gc_cycles = 0
    }
    
    -- Hook for tracking allocations
    local old_gc = collectgarbage
    collectgarbage = function(...)
        profile.gc_cycles = profile.gc_cycles + 1
        local current = old_gc("count")
        profile.peak_memory = math.max(profile.peak_memory, current)
        return old_gc(...)
    end
    
    return {
        snapshot = function()
            local current = collectgarbage("count")
            table.insert(profile.allocations, {
                time = os.time(),
                memory = current
            })
            return current
        end,
        
        report = function()
            local current = collectgarbage("count")
            local leaked = current - profile.start_memory
            print("Memory Profile Report:")
            print("  Start memory:", profile.start_memory, "KB")
            print("  Current memory:", current, "KB")
            print("  Peak memory:", profile.peak_memory, "KB")
            print("  Memory leaked:", leaked, "KB")
            print("  GC cycles:", profile.gc_cycles)
            return {
                start = profile.start_memory,
                current = current,
                peak = profile.peak_memory,
                leaked = leaked,
                gc_cycles = profile.gc_cycles
            }
        end
    }
end

-- Performance timing with microsecond precision
local function createTimer()
    local start_time = os.clock()
    return {
        elapsed = function()
            return (os.clock() - start_time) * 1000 -- milliseconds
        end,
        
        reset = function()
            start_time = os.clock()
        end,
        
        lap = function(name)
            local elapsed = (os.clock() - start_time) * 1000
            print(string.format("Timer [%s]: %.3f ms", name or "lap", elapsed))
            return elapsed
        end
    }
end

-- Function call profiler
local function createProfiler()
    local calls = {}
    local timers = {}
    
    return {
        wrap = function(fn, name)
            return function(...)
                local timer = createTimer()
                calls[name] = (calls[name] or 0) + 1
                timers[name] = timers[name] or { total = 0, min = math.huge, max = 0 }
                
                local result = {fn(...)}
                
                local elapsed = timer.elapsed()
                timers[name].total = timers[name].total + elapsed
                timers[name].min = math.min(timers[name].min, elapsed)
                timers[name].max = math.max(timers[name].max, elapsed)
                
                return table.unpack(result)
            end
        end,
        
        report = function()
            print("Function Call Profile:")
            for name, count in pairs(calls) do
                local stats = timers[name]
                local avg = stats.total / count
                print(string.format("  %s: %d calls, %.3f ms total, %.3f ms avg, %.3f ms min, %.3f ms max",
                    name, count, stats.total, avg, stats.min, stats.max))
            end
        end
    }
end

-- Signal handling for graceful shutdown
local function setupSignalHandlers()
    -- Simulate signal handling (in real Lua, you'd use luaposix or FFI)
    local signals = {
        SIGTERM = 15,
        SIGINT = 2,
        SIGUSR1 = 10,
        SIGUSR2 = 12
    }
    
    local handlers = {}
    
    return {
        register = function(signal, handler)
            handlers[signal] = handler
            print("Registered handler for signal", signal)
        end,
        
        trigger = function(signal)
            local handler = handlers[signal]
            if handler then
                print("Handling signal", signal)
                handler()
            else
                print("No handler for signal", signal)
            end
        end
    }
end

-- Core dump simulation and crash recovery
local function crashRecovery(fn, recovery_fn)
    local function crashHandler(err)
        print("CRASH DETECTED:", err)
        
        -- Simulate core dump collection
        local core_dump = {
            timestamp = os.date("%Y-%m-%d %H:%M:%S"),
            error = err,
            stack = getStackTrace(),
            memory = collectgarbage("count"),
            environment = {
                lua_version = _VERSION,
                platform = os.getenv("OS") or "unknown"
            }
        }
        
        print("Core dump collected:")
        for k, v in pairs(core_dump) do
            if type(v) == "table" then
                print("  " .. k .. ": [table with " .. #v .. " entries]")
            else
                print("  " .. k .. ":", v)
            end
        end
        
        -- Run recovery function
        if recovery_fn then
            print("Running recovery function...")
            recovery_fn(core_dump)
        end
        
        return err
    end
    
    return xpcall(fn, crashHandler)
end

-- CPU profiling with sampling
local function cpuProfiler(sample_rate)
    sample_rate = sample_rate or 100 -- samples per second
    local samples = {}
    local active = false
    
    return {
        start = function()
            active = true
            print("CPU profiler started (sample rate:", sample_rate, "Hz)")
        end,
        
        sample = function()
            if not active then return end
            
            local info = debug.getinfo(2, "Snl")
            if info then
                local key = string.format("%s:%d", info.source, info.currentline)
                samples[key] = (samples[key] or 0) + 1
            end
        end,
        
        stop = function()
            active = false
            print("CPU profiler stopped")
        end,
        
        report = function()
            print("CPU Profile (hotspots):")
            local sorted = {}
            for location, count in pairs(samples) do
                table.insert(sorted, {location = location, count = count})
            end
            
            table.sort(sorted, function(a, b) return a.count > b.count end)
            
            for i = 1, math.min(10, #sorted) do
                local item = sorted[i]
                print(string.format("  %d samples: %s", item.count, item.location))
            end
        end
    }
end

-- Memory leak detector
local function memoryLeakDetector()
    local snapshots = {}
    local refs = {}
    
    return {
        snapshot = function(name)
            snapshots[name] = {
                memory = collectgarbage("count"),
                time = os.time(),
                refs = {}
            }
            
            -- Track object references (simplified)
            for k, v in pairs(_G) do
                if type(v) == "table" then
                    snapshots[name].refs[k] = tostring(v)
                end
            end
            
            print("Memory snapshot taken:", name)
        end,
        
        compare = function(snap1, snap2)
            local s1 = snapshots[snap1]
            local s2 = snapshots[snap2]
            
            if not s1 or not s2 then
                print("Invalid snapshot names")
                return
            end
            
            local memory_diff = s2.memory - s1.memory
            print(string.format("Memory diff %s -> %s: %.2f KB", 
                snap1, snap2, memory_diff))
            
            -- Check for new references (potential leaks)
            local new_refs = 0
            for k, v in pairs(s2.refs) do
                if not s1.refs[k] then
                    new_refs = new_refs + 1
                end
            end
            
            if new_refs > 0 then
                print("Potential memory leaks detected:", new_refs, "new references")
            end
        end
    }
end

-- Health check system
local function healthChecker()
    local checks = {}
    
    return {
        register = function(name, check_fn, threshold)
            checks[name] = {
                fn = check_fn,
                threshold = threshold or 5000, -- 5 second timeout
                last_result = nil,
                failures = 0
            }
        end,
        
        run = function()
            local results = {}
            
            for name, check in pairs(checks) do
                local timer = createTimer()
                local ok, result = pcall(check.fn)
                local elapsed = timer.elapsed()
                
                if ok and elapsed < check.threshold then
                    check.failures = 0
                    check.last_result = result
                    results[name] = { status = "healthy", result = result, time = elapsed }
                else
                    check.failures = check.failures + 1
                    results[name] = { 
                        status = "unhealthy", 
                        error = result,
                        time = elapsed,
                        failures = check.failures
                    }
                end
            end
            
            return results
        end,
        
        report = function()
            local results = self.run()
            print("Health Check Report:")
            for name, result in pairs(results) do
                print(string.format("  %s: %s (%.2f ms)", 
                    name, result.status, result.time))
                if result.error then
                    print("    Error:", result.error)
                end
            end
        end
    }
end

-- Production debugging utilities
local ProductionDebugger = {
    log_level = "INFO",
    
    levels = {
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4,
        FATAL = 5
    },
    
    log = function(self, level, message, context)
        local level_num = self.levels[level] or 2
        local current_level = self.levels[self.log_level] or 2
        
        if level_num >= current_level then
            local timestamp = os.date("%Y-%m-%d %H:%M:%S")
            local log_entry = string.format("[%s] %s: %s", timestamp, level, message)
            
            if context then
                log_entry = log_entry .. " | Context: " .. tostring(context)
            end
            
            print(log_entry)
            
            -- In production, you'd write to log files, send to logging service
            if level == "FATAL" then
                -- Trigger alerts, save core dump, etc.
                print("FATAL error detected - triggering emergency procedures")
            end
        end
    end,
    
    debug = function(self, message, context)
        self:log("DEBUG", message, context)
    end,
    
    info = function(self, message, context)
        self:log("INFO", message, context)
    end,
    
    warn = function(self, message, context)
        self:log("WARN", message, context)
    end,
    
    error = function(self, message, context)
        self:log("ERROR", message, context)
    end,
    
    fatal = function(self, message, context)
        self:log("FATAL", message, context)
    end
}

-- Example usage scenarios
print("=== Debugging and Profiling Demo ===")

-- Memory profiling
local mem_prof = memoryProfiler()
for i = 1, 1000 do
    local data = {id = i, value = string.rep("data", i)}
end
mem_prof.snapshot()
mem_prof.report()

-- Function profiling
local profiler = createProfiler()
local slowFunction = profiler.wrap(function(n)
    local sum = 0
    for i = 1, n do sum = sum + i end
    return sum
end, "slowFunction")

for i = 1, 5 do
    slowFunction(1000)
end
profiler.report()

-- Signal handling setup
local signals = setupSignalHandlers()
signals.register("SIGTERM", function()
    print("Gracefully shutting down...")
    -- Save state, close connections, etc.
end)

-- Health checks
local health = healthChecker()
health.register("memory", function()
    local mem = collectgarbage("count")
    if mem > 10000 then -- 10MB threshold
        error("Memory usage too high: " .. mem .. " KB")
    end
    return mem .. " KB"
end)

health.register("cpu", function()
    -- Simulate CPU check
    return "CPU usage OK"
end)

health.report()

-- Production logging
ProductionDebugger:info("System started successfully")
ProductionDebugger:warn("High memory usage detected", "Memory: " .. collectgarbage("count") .. " KB")
ProductionDebugger:debug("Debug information", {user_id = 123, action = "login"})

print("Debugging and profiling systems initialized")
