-- Low-level FFI and System Calls for Senior Backend Engineers

-- LuaJIT FFI for C interop (essential for Google-level performance)
local ffi = require('ffi')

-- System call definitions
ffi.cdef[[
    // Process management
    typedef int pid_t;
    pid_t getpid(void);
    pid_t getppid(void);
    pid_t fork(void);
    int kill(pid_t pid, int sig);
    int waitpid(pid_t pid, int *status, int options);
    
    // File system operations
    int open(const char *pathname, int flags, int mode);
    int close(int fd);
    long read(int fd, void *buf, unsigned long count);
    long write(int fd, const void *buf, unsigned long count);
    int unlink(const char *pathname);
    int mkdir(const char *pathname, int mode);
    int rmdir(const char *pathname);
    
    // Memory management
    void* malloc(size_t size);
    void free(void *ptr);
    void* mmap(void *addr, size_t length, int prot, int flags, int fd, long offset);
    int munmap(void *addr, size_t length);
    
    // Network system calls
    int socket(int domain, int type, int protocol);
    int bind(int sockfd, const struct sockaddr *addr, unsigned int addrlen);
    int listen(int sockfd, int backlog);
    int accept(int sockfd, struct sockaddr *addr, unsigned int *addrlen);
    int connect(int sockfd, const struct sockaddr *addr, unsigned int addrlen);
    long send(int sockfd, const void *buf, size_t len, int flags);
    long recv(int sockfd, void *buf, size_t len, int flags);
    
    // Time and signals
    typedef long time_t;
    time_t time(time_t *t);
    unsigned int sleep(unsigned int seconds);
    int usleep(unsigned int usec);
    
    // Threading (pthreads)
    typedef struct pthread_t pthread_t;
    typedef struct pthread_mutex_t pthread_mutex_t;
    int pthread_create(pthread_t *thread, const void *attr, void *(*start_routine)(void *), void *arg);
    int pthread_join(pthread_t thread, void **retval);
    int pthread_mutex_init(pthread_mutex_t *mutex, const void *attr);
    int pthread_mutex_lock(pthread_mutex_t *mutex);
    int pthread_mutex_unlock(pthread_mutex_t *mutex);
    int pthread_mutex_destroy(pthread_mutex_t *mutex);
    
    // System info
    typedef struct {
        long uptime;
        unsigned long loads[3];
        unsigned long totalram;
        unsigned long freeram;
        unsigned long sharedram;
        unsigned long bufferram;
        unsigned long totalswap;
        unsigned long freeswap;
        unsigned short procs;
        unsigned long totalhigh;
        unsigned long freehigh;
        unsigned int mem_unit;
    } sysinfo_t;
    int sysinfo(sysinfo_t *info);
    
    // Advanced I/O operations
    struct epoll_event {
        uint32_t events;
        union {
            void *ptr;
            int fd;
            uint32_t u32;
            uint64_t u64;
        } data;
    };
    int epoll_create1(int flags);
    int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
    int epoll_wait(int epfd, struct epoll_event *events, int maxevents, int timeout);
    int fcntl(int fd, int cmd, ...);
    
    // Shared memory and IPC
    int shmget(int key, size_t size, int shmflg);
    void* shmat(int shmid, const void *shmaddr, int shmflg);
    int shmdt(const void *shmaddr);
    int shmctl(int shmid, int cmd, void *buf);
    
    // Message queues
    int msgget(int key, int msgflg);
    int msgsnd(int msqid, const void *msgp, size_t msgsz, int msgflg);
    long msgrcv(int msqid, void *msgp, size_t msgsz, long msgtyp, int msgflg);
    int msgctl(int msqid, int cmd, void *buf);
    
    // Semaphores
    struct sembuf {
        unsigned short sem_num;
        short sem_op;
        short sem_flg;
    };
    int semget(int key, int nsems, int semflg);
    int semop(int semid, struct sembuf *sops, size_t nsops);
    int semctl(int semid, int semnum, int cmd, ...);
    
    // Advanced file operations
    struct inotify_event {
        int wd;
        uint32_t mask;
        uint32_t cookie;
        uint32_t len;
        char name[];
    };
    int inotify_init1(int flags);
    int inotify_add_watch(int fd, const char *pathname, uint32_t mask);
    int inotify_rm_watch(int fd, int wd);
    
    // Performance monitoring
    long syscall(long number, ...);
    int perf_event_open(void *attr, pid_t pid, int cpu, int group_fd, unsigned long flags);
    
    // Network advanced
    struct sockaddr_in {
        short sin_family;
        unsigned short sin_port;
        struct in_addr sin_addr;
        char sin_zero[8];
    };
    struct in_addr {
        unsigned long s_addr;
    };
    unsigned long inet_addr(const char *cp);
    char *inet_ntoa(struct in_addr in);
    
    // CPU affinity and scheduling
    int sched_setaffinity(pid_t pid, size_t cpusetsize, const void *mask);
    int sched_getaffinity(pid_t pid, size_t cpusetsize, void *mask);
    int nice(int inc);
    int setpriority(int which, int who, int prio);
    int getpriority(int which, int who);
]]

-- Constants for system calls
local O_RDONLY = 0
local O_WRONLY = 1
local O_RDWR = 2
local O_CREAT = 64
local O_NONBLOCK = 2048
local PROT_READ = 1
local PROT_WRITE = 2
local MAP_PRIVATE = 2
local MAP_SHARED = 1
local MAP_ANONYMOUS = 32

-- IPC constants
local IPC_CREAT = 512
local IPC_EXCL = 1024
local IPC_NOWAIT = 2048

-- Epoll constants
local EPOLLIN = 1
local EPOLLOUT = 4
local EPOLLERR = 8
local EPOLLHUP = 16
local EPOLLET = 2147483648

-- Inotify constants
local IN_ACCESS = 1
local IN_MODIFY = 2
local IN_ATTRIB = 4
local IN_CLOSE_WRITE = 8
local IN_CLOSE_NOWRITE = 16
local IN_OPEN = 32
local IN_MOVED_FROM = 64
local IN_MOVED_TO = 128
local IN_CREATE = 256
local IN_DELETE = 512

--[[
Process Management (Critical for Infrastructure Tools)
]]

local ProcessManager = {}

function ProcessManager.getCurrentPid()
    return ffi.C.getpid()
end

function ProcessManager.getParentPid()
    return ffi.C.getppid()
end

function ProcessManager.forkProcess()
    local pid = ffi.C.fork()
    if pid == 0 then
        return "child"
    elseif pid > 0 then
        return "parent", pid
    else
        return nil, "fork failed"
    end
end

-- Process pool for high-performance servers (Google-style)
function ProcessManager.createWorkerPool(numWorkers, workerFunc)
    local workers = {}
    for i = 1, numWorkers do
        local result, pid = ProcessManager.forkProcess()
        if result == "child" then
            -- Child process - run worker function
            workerFunc(i)
            os.exit(0)
        elseif result == "parent" then
            workers[i] = pid
        end
    end
    return workers
end

-- Example usage:
-- local workers = ProcessManager.createWorkerPool(4, function(workerId)
--     print("Worker", workerId, "starting...")
--     -- Actual work here
-- end)

print("Current PID:", ProcessManager.getCurrentPid())
print("Parent PID:", ProcessManager.getParentPid())

--[[
Low-level File Operations (Essential for System Tools)
]]

local FileSystem = {}

function FileSystem.openFile(path, flags, mode)
    flags = flags or O_RDONLY
    mode = mode or 0644
    local fd = ffi.C.open(path, flags, mode)
    if fd == -1 then
        return nil, "Failed to open file"
    end
    return fd
end

function FileSystem.readFile(fd, size)
    size = size or 4096
    local buffer = ffi.new("char[?]", size)
    local bytesRead = ffi.C.read(fd, buffer, size)
    if bytesRead == -1 then
        return nil, "Read failed"
    end
    return ffi.string(buffer, bytesRead)
end

function FileSystem.writeFile(fd, data)
    local bytesWritten = ffi.C.write(fd, data, #data)
    if bytesWritten == -1 then
        return nil, "Write failed"
    end
    return bytesWritten
end

function FileSystem.closeFile(fd)
    return ffi.C.close(fd) == 0
end

-- Memory mapped files (critical for high-performance data processing)
function FileSystem.mmapFile(path, size)
    local fd = FileSystem.openFile(path, O_RDWR)
    if not fd then return nil, "Cannot open file" end
    
    local addr = ffi.C.mmap(nil, size, PROT_READ + PROT_WRITE, MAP_PRIVATE, fd, 0)
    if addr == ffi.cast("void*", -1) then
        FileSystem.closeFile(fd)
        return nil, "mmap failed"
    end
    
    return {
        addr = addr,
        size = size,
        fd = fd,
        unmap = function(self)
            ffi.C.munmap(self.addr, self.size)
            FileSystem.closeFile(self.fd)
        end
    }
end

--[[
Network Programming at System Level (Google Infrastructure)
]]

local NetworkStack = {}

function NetworkStack.createSocket(domain, type, protocol)
    domain = domain or 2 -- AF_INET
    type = type or 1 -- SOCK_STREAM
    protocol = protocol or 0
    
    local sockfd = ffi.C.socket(domain, type, protocol)
    if sockfd == -1 then
        return nil, "Socket creation failed"
    end
    return sockfd
end

-- Raw socket operations for network tools
function NetworkStack.sendRaw(sockfd, data)
    local bytesSent = ffi.C.send(sockfd, data, #data, 0)
    if bytesSent == -1 then
        return nil, "Send failed"
    end
    return bytesSent
end

function NetworkStack.receiveRaw(sockfd, size)
    size = size or 4096
    local buffer = ffi.new("char[?]", size)
    local bytesReceived = ffi.C.recv(sockfd, buffer, size, 0)
    if bytesReceived == -1 then
        return nil, "Receive failed"
    end
    return ffi.string(buffer, bytesReceived)
end

--[[
Memory Management (Critical for Performance-Critical Code)
]]

local MemoryManager = {}

function MemoryManager.allocate(size)
    local ptr = ffi.C.malloc(size)
    if ptr == nil then
        return nil, "Allocation failed"
    end
    return ptr
end

function MemoryManager.deallocate(ptr)
    ffi.C.free(ptr)
end

-- Custom memory pool (Google-style memory management)
function MemoryManager.createPool(blockSize, numBlocks)
    local totalSize = blockSize * numBlocks
    local pool = MemoryManager.allocate(totalSize)
    if not pool then return nil, "Pool allocation failed" end
    
    local freeList = {}
    for i = 0, numBlocks - 1 do
        table.insert(freeList, ffi.cast("char*", pool) + (i * blockSize))
    end
    
    return {
        pool = pool,
        blockSize = blockSize,
        freeList = freeList,
        allocateBlock = function(self)
            if #self.freeList == 0 then return nil, "Pool exhausted" end
            return table.remove(self.freeList)
        end,
        deallocateBlock = function(self, ptr)
            table.insert(self.freeList, ptr)
        end,
        destroy = function(self)
            MemoryManager.deallocate(self.pool)
        end
    }
end

--[[
System Information (Infrastructure Monitoring)
]]

local SystemInfo = {}

function SystemInfo.getSystemInfo()
    local info = ffi.new("sysinfo_t")
    if ffi.C.sysinfo(info) == -1 then
        return nil, "sysinfo failed"
    end
    
    return {
        uptime = tonumber(info.uptime),
        totalRam = tonumber(info.totalram),
        freeRam = tonumber(info.freeram),
        totalSwap = tonumber(info.totalswap),
        freeSwap = tonumber(info.freeswap),
        processes = tonumber(info.procs),
        load1 = tonumber(info.loads[0]) / 65536.0,
        load5 = tonumber(info.loads[1]) / 65536.0,
        load15 = tonumber(info.loads[2]) / 65536.0
    }
end

-- System monitoring for production environments
function SystemInfo.getMemoryUsage()
    local info = SystemInfo.getSystemInfo()
    if not info then return nil end
    
    return {
        totalMB = info.totalRam / (1024 * 1024),
        freeMB = info.freeRam / (1024 * 1024),
        usedMB = (info.totalRam - info.freeRam) / (1024 * 1024),
        usagePercent = ((info.totalRam - info.freeRam) / info.totalRam) * 100
    }
end

--[[
Example Usage for Google-level System Programming
]]

-- High-performance file processing
local function processLargeFile(filename)
    local mmap = FileSystem.mmapFile(filename, 1024 * 1024) -- 1MB
    if not mmap then
        print("Failed to mmap file")
        return
    end
    
    -- Process memory-mapped data directly
    -- This is orders of magnitude faster than regular file I/O
    local data = ffi.string(mmap.addr, mmap.size)
    print("Processed", #data, "bytes via mmap")
    
    mmap:unmap()
end

-- System monitoring dashboard
local function systemDashboard()
    local sysInfo = SystemInfo.getSystemInfo()
    local memInfo = SystemInfo.getMemoryUsage()
    
    if sysInfo and memInfo then
        print("=== System Dashboard ===")
        print("Uptime:", sysInfo.uptime, "seconds")
        print("Load Average:", sysInfo.load1, sysInfo.load5, sysInfo.load15)
        print("Memory Usage:", string.format("%.1f%%", memInfo.usagePercent))
        print("Free Memory:", string.format("%.1f MB", memInfo.freeMB))
        print("Active Processes:", sysInfo.processes)
    end
end

-- Example calls
systemDashboard()

-- Memory pool example (critical for high-performance servers)
local pool = MemoryManager.createPool(1024, 100) -- 100 blocks of 1KB each
if pool then
    local block = pool:allocateBlock()
    if block then
        print("Allocated block from pool")
        pool:deallocateBlock(block)
        print("Returned block to pool")
    end
    pool:destroy()
end

print("FFI and system calls module loaded successfully!")

--[[
Advanced I/O Operations (High-Performance Servers)
]]

local AdvancedIO = {}

function AdvancedIO.createEpoll()
    local epfd = ffi.C.epoll_create1(0)
    if epfd == -1 then
        return nil, "Failed to create epoll"
    end
    
    return {
        fd = epfd,
        
        addSocket = function(self, sockfd, events)
            events = events or EPOLLIN
            local event = ffi.new("struct epoll_event")
            event.events = events
            event.data.fd = sockfd
            
            if ffi.C.epoll_ctl(self.fd, 1, sockfd, event) == -1 then -- EPOLL_CTL_ADD = 1
                return false, "Failed to add socket to epoll"
            end
            return true
        end,
        
        wait = function(self, maxEvents, timeout)
            maxEvents = maxEvents or 64
            timeout = timeout or -1
            
            local events = ffi.new("struct epoll_event[?]", maxEvents)
            local numEvents = ffi.C.epoll_wait(self.fd, events, maxEvents, timeout)
            
            if numEvents == -1 then
                return nil, "Epoll wait failed"
            end
            
            local results = {}
            for i = 0, numEvents - 1 do
                table.insert(results, {
                    fd = events[i].data.fd,
                    events = events[i].events
                })
            end
            
            return results
        end,
        
        close = function(self)
            ffi.C.close(self.fd)
        end
    }
end

-- High-performance event-driven server
function AdvancedIO.createEventServer(port)
    local serverSocket = NetworkStack.createSocket()
    if not serverSocket then return nil, "Failed to create server socket" end
    
    -- Set socket to non-blocking
    local flags = ffi.C.fcntl(serverSocket, 3, 0) -- F_GETFL = 3
    ffi.C.fcntl(serverSocket, 4, flags + O_NONBLOCK) -- F_SETFL = 4
    
    local epoll = AdvancedIO.createEpoll()
    if not epoll then return nil, "Failed to create epoll" end
    
    epoll:addSocket(serverSocket, EPOLLIN)
    
    return {
        socket = serverSocket,
        epoll = epoll,
        clients = {},
        
        run = function(self)
            print("Event-driven server starting on port", port)
            
            while true do
                local events = self.epoll:wait(64, 1000) -- 1 second timeout
                if events then
                    for _, event in ipairs(events) do
                        if event.fd == self.socket then
                            -- New connection
                            local clientSocket = ffi.C.accept(self.socket, nil, nil)
                            if clientSocket ~= -1 then
                                self.epoll:addSocket(clientSocket, EPOLLIN)
                                self.clients[clientSocket] = true
                                print("New client connected:", clientSocket)
                            end
                        else
                            -- Client data
                            local data = NetworkStack.receiveRaw(event.fd, 1024)
                            if data then
                                print("Received from client", event.fd, ":", data:sub(1, 50))
                                NetworkStack.sendRaw(event.fd, "HTTP/1.1 200 OK\r\n\r\nHello from Lua!")
                            end
                            
                            -- Close client
                            ffi.C.close(event.fd)
                            self.clients[event.fd] = nil
                        end
                    end
                end
            end
        end,
        
        stop = function(self)
            for client in pairs(self.clients) do
                ffi.C.close(client)
            end
            self.epoll:close()
            ffi.C.close(self.socket)
        end
    }
end

--[[
Inter-Process Communication (Enterprise Microservices)
]]

local IPC = {}

function IPC.createSharedMemory(key, size)
    local shmid = ffi.C.shmget(key, size, IPC_CREAT + 0666)
    if shmid == -1 then
        return nil, "Failed to create shared memory"
    end
    
    local addr = ffi.C.shmat(shmid, nil, 0)
    if addr == ffi.cast("void*", -1) then
        return nil, "Failed to attach shared memory"
    end
    
    return {
        id = shmid,
        addr = addr,
        size = size,
        
        write = function(self, data, offset)
            offset = offset or 0
            local ptr = ffi.cast("char*", self.addr) + offset
            ffi.copy(ptr, data, math.min(#data, self.size - offset))
        end,
        
        read = function(self, length, offset)
            offset = offset or 0
            length = length or (self.size - offset)
            local ptr = ffi.cast("char*", self.addr) + offset
            return ffi.string(ptr, length)
        end,
        
        detach = function(self)
            ffi.C.shmdt(self.addr)
        end,
        
        destroy = function(self)
            ffi.C.shmctl(self.id, 0, nil) -- IPC_RMID = 0
        end
    }
end

function IPC.createMessageQueue(key)
    local msqid = ffi.C.msgget(key, IPC_CREAT + 0666)
    if msqid == -1 then
        return nil, "Failed to create message queue"
    end
    
    return {
        id = msqid,
        
        send = function(self, message, type)
            type = type or 1
            local msgp = ffi.new("struct { long mtype; char mtext[?]; }", #message)
            msgp.mtype = type
            ffi.copy(msgp.mtext, message, #message)
            
            if ffi.C.msgsnd(self.id, msgp, #message, 0) == -1 then
                return false, "Failed to send message"
            end
            return true
        end,
        
        receive = function(self, type, maxSize)
            type = type or 0 -- Any type
            maxSize = maxSize or 1024
            
            local msgp = ffi.new("struct { long mtype; char mtext[?]; }", maxSize)
            local size = ffi.C.msgrcv(self.id, msgp, maxSize, type, IPC_NOWAIT)
            
            if size == -1 then
                return nil, "No message available"
            end
            
            return ffi.string(msgp.mtext, size), msgp.mtype
        end,
        
        destroy = function(self)
            ffi.C.msgctl(self.id, 0, nil) -- IPC_RMID = 0
        end
    }
end

--[[
File System Monitoring (Infrastructure Observability)
]]

local FileMonitor = {}

function FileMonitor.create()
    local inotify_fd = ffi.C.inotify_init1(0)
    if inotify_fd == -1 then
        return nil, "Failed to initialize inotify"
    end
    
    return {
        fd = inotify_fd,
        watches = {},
        
        addWatch = function(self, path, mask)
            mask = mask or (IN_CREATE + IN_DELETE + IN_MODIFY + IN_MOVED_FROM + IN_MOVED_TO)
            local wd = ffi.C.inotify_add_watch(self.fd, path, mask)
            
            if wd == -1 then
                return false, "Failed to add watch for " .. path
            end
            
            self.watches[wd] = path
            print("Watching:", path, "with descriptor", wd)
            return wd
        end,
        
        removeWatch = function(self, wd)
            if ffi.C.inotify_rm_watch(self.fd, wd) == 0 then
                self.watches[wd] = nil
                return true
            end
            return false
        end,
        
        readEvents = function(self, timeout)
            -- Use select to implement timeout
            local events = {}
            local buffer = ffi.new("char[4096]")
            local bytesRead = ffi.C.read(self.fd, buffer, 4096)
            
            if bytesRead > 0 then
                local offset = 0
                while offset < bytesRead do
                    local event = ffi.cast("struct inotify_event*", buffer + offset)
                    local path = self.watches[event.wd] or "unknown"
                    
                    table.insert(events, {
                        path = path,
                        mask = event.mask,
                        cookie = event.cookie,
                        name = event.len > 0 and ffi.string(buffer + offset + ffi.sizeof("struct inotify_event"), event.len) or ""
                    })
                    
                    offset = offset + ffi.sizeof("struct inotify_event") + event.len
                end
            end
            
            return events
        end,
        
        close = function(self)
            ffi.C.close(self.fd)
        end
    }
end

--[[
CPU Affinity and Performance Tuning
]]

local Performance = {}

function Performance.setCpuAffinity(pid, cpuMask)
    -- Set CPU affinity for a process
    local mask = ffi.new("unsigned long[1]")
    mask[0] = cpuMask
    
    if ffi.C.sched_setaffinity(pid, ffi.sizeof("unsigned long"), mask) == 0 then
        print("Set CPU affinity for PID", pid, "to mask", cpuMask)
        return true
    end
    return false, "Failed to set CPU affinity"
end

function Performance.setProcessPriority(pid, priority)
    if ffi.C.setpriority(0, pid, priority) == 0 then -- PRIO_PROCESS = 0
        print("Set priority for PID", pid, "to", priority)
        return true
    end
    return false, "Failed to set priority"
end

function Performance.niceProcess(increment)
    local newNice = ffi.C.nice(increment)
    print("Process nice value:", newNice)
    return newNice
end

--[[
Example: High-Performance Log Aggregator
]]

local function logAggregatorDemo()
    print("\n=== High-Performance Log Aggregator Demo ===")
    
    -- Create shared memory for log buffer
    local shm = IPC.createSharedMemory(12345, 4096)
    if shm then
        print("Created shared memory segment:", shm.id)
        
        -- Write log entry
        shm:write("2025-07-27 10:30:00 INFO Application started", 0)
        
        -- Read log entry
        local logEntry = shm:read(100, 0)
        print("Log entry:", logEntry)
        
        shm:detach()
    end
    
    -- Create message queue for log distribution
    local mq = IPC.createMessageQueue(54321)
    if mq then
        print("Created message queue:", mq.id)
        
        -- Send log message
        mq:send("ERROR: Database connection failed", 2) -- Priority 2
        mq:send("INFO: User logged in", 1) -- Priority 1
        
        -- Receive messages
        for i = 1, 2 do
            local msg, type = mq:receive(0, 1024)
            if msg then
                print("Received log message (type " .. type .. "):", msg)
            end
        end
        
        mq:destroy()
    end
    
    -- Monitor log directory
    local monitor = FileMonitor.create()
    if monitor then
        print("Created file monitor")
        
        -- Add watch for /tmp directory (for demo)
        local wd = monitor:addWatch("/tmp", IN_CREATE + IN_DELETE + IN_MODIFY)
        if wd then
            print("Monitoring /tmp for file changes...")
            
            -- In a real application, you'd run this in a loop
            -- local events = monitor:readEvents(1000)
            -- for _, event in ipairs(events) do
            --     print("File event:", event.path, event.name, "mask:", event.mask)
            -- end
        end
        
        monitor:close()
    end
    
    -- Performance tuning
    Performance.niceProcess(-5) -- Higher priority
    Performance.setCpuAffinity(ProcessManager.getCurrentPid(), 3) -- CPU 0 and 1
end

-- Run demo
logAggregatorDemo()
