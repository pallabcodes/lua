-- Container Orchestration and Virtualization for Infrastructure Engineers

local json = require("json") or { encode = function(t) return "json_placeholder" end, decode = function(s) return {} end }
local socket = require("socket") or { gettime = function() return os.time() end }

--[[
Container Runtime Interface (Google Kubernetes-style)
]]

local Container = {}

function Container.create(name, image, config)
    config = config or {}
    
    return {
        id = "container-" .. math.random(100000, 999999),
        name = name,
        image = image,
        state = "created",
        config = config,
        resources = {
            cpu = config.cpu or "100m",
            memory = config.memory or "128Mi",
            storage = config.storage or "1Gi"
        },
        networks = config.networks or { "default" },
        volumes = config.volumes or {},
        env = config.env or {},
        ports = config.ports or {},
        
        start = function(self)
            if self.state == "created" or self.state == "stopped" then
                self.state = "running"
                self.startTime = socket.gettime()
                print("Container", self.name, "started with ID:", self.id)
                return true
            end
            return false, "Container not in startable state"
        end,
        
        stop = function(self, timeout)
            timeout = timeout or 30
            if self.state == "running" then
                self.state = "stopped"
                self.stopTime = socket.gettime()
                print("Container", self.name, "stopped")
                return true
            end
            return false, "Container not running"
        end,
        
        restart = function(self)
            self:stop()
            return self:start()
        end,
        
        remove = function(self, force)
            if self.state == "running" and not force then
                return false, "Container is running, use force=true"
            end
            self.state = "removed"
            print("Container", self.name, "removed")
            return true
        end,
        
        exec = function(self, command)
            if self.state ~= "running" then
                return nil, "Container not running"
            end
            
            print("Executing in container", self.name, ":", command)
            -- Simulate command execution
            return "Command output for: " .. command
        end,
        
        getLogs = function(self, lines)
            lines = lines or 100
            local logs = {}
            
            for i = 1, lines do
                table.insert(logs, string.format("[%s] Log line %d from %s", 
                    os.date("%Y-%m-%d %H:%M:%S"), i, self.name))
            end
            
            return table.concat(logs, "\n")
        end,
        
        getStats = function(self)
            if self.state ~= "running" then
                return nil, "Container not running"
            end
            
            return {
                cpu = {
                    usage = math.random(10, 80) .. "%",
                    limit = self.resources.cpu
                },
                memory = {
                    usage = math.random(50, 200) .. "Mi",
                    limit = self.resources.memory
                },
                network = {
                    rxBytes = math.random(1000, 100000),
                    txBytes = math.random(1000, 100000)
                },
                uptime = self.startTime and (socket.gettime() - self.startTime) or 0
            }
        end,
        
        getInfo = function(self)
            return {
                id = self.id,
                name = self.name,
                image = self.image,
                state = self.state,
                resources = self.resources,
                networks = self.networks,
                ports = self.ports,
                env = self.env
            }
        end
    }
end

--[[
Pod Management (Kubernetes-style)
]]

local Pod = {}

function Pod.create(name, namespace, spec)
    namespace = namespace or "default"
    spec = spec or {}
    
    return {
        metadata = {
            name = name,
            namespace = namespace,
            uid = "pod-" .. math.random(100000, 999999),
            labels = spec.labels or {},
            annotations = spec.annotations or {},
            creationTimestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        },
        spec = spec,
        status = {
            phase = "Pending",
            conditions = {},
            containerStatuses = {}
        },
        containers = {},
        
        addContainer = function(self, container)
            table.insert(self.containers, container)
            table.insert(self.status.containerStatuses, {
                name = container.name,
                state = container.state,
                ready = container.state == "running",
                restartCount = 0
            })
        end,
        
        start = function(self)
            if self.status.phase == "Pending" then
                self.status.phase = "Running"
                
                -- Start all containers
                for _, container in ipairs(self.containers) do
                    container:start()
                end
                
                -- Update container statuses
                for i, status in ipairs(self.status.containerStatuses) do
                    local container = self.containers[i]
                    status.state = container.state
                    status.ready = container.state == "running"
                end
                
                print("Pod", self.metadata.name, "started in namespace", self.metadata.namespace)
                return true
            end
            return false, "Pod not in startable state"
        end,
        
        stop = function(self)
            if self.status.phase == "Running" then
                -- Stop all containers
                for _, container in ipairs(self.containers) do
                    container:stop()
                end
                
                self.status.phase = "Succeeded"
                print("Pod", self.metadata.name, "stopped")
                return true
            end
            return false, "Pod not running"
        end,
        
        delete = function(self)
            self:stop()
            self.status.phase = "Terminating"
            
            -- Remove all containers
            for _, container in ipairs(self.containers) do
                container:remove(true)
            end
            
            print("Pod", self.metadata.name, "deleted")
            return true
        end,
        
        getStatus = function(self)
            return {
                metadata = self.metadata,
                status = self.status,
                containerCount = #self.containers
            }
        end,
        
        getLogs = function(self, containerName)
            for _, container in ipairs(self.containers) do
                if not containerName or container.name == containerName then
                    return container:getLogs()
                end
            end
            return nil, "Container not found"
        end
    }
end

--[[
Service Discovery and Load Balancing
]]

local Service = {}

function Service.create(name, namespace, spec)
    namespace = namespace or "default"
    spec = spec or {}
    
    return {
        metadata = {
            name = name,
            namespace = namespace,
            uid = "service-" .. math.random(100000, 999999)
        },
        spec = {
            selector = spec.selector or {},
            ports = spec.ports or {},
            type = spec.type or "ClusterIP",
            sessionAffinity = spec.sessionAffinity or "None"
        },
        status = {
            loadBalancer = {}
        },
        endpoints = {},
        
        addEndpoint = function(self, ip, port, podName)
            table.insert(self.endpoints, {
                ip = ip,
                port = port,
                podName = podName,
                ready = true
            })
            print("Added endpoint", ip .. ":" .. port, "to service", self.metadata.name)
        end,
        
        removeEndpoint = function(self, ip, port)
            for i, endpoint in ipairs(self.endpoints) do
                if endpoint.ip == ip and endpoint.port == port then
                    table.remove(self.endpoints, i)
                    print("Removed endpoint", ip .. ":" .. port, "from service", self.metadata.name)
                    return true
                end
            end
            return false
        end,
        
        getEndpoint = function(self, strategy)
            strategy = strategy or "round_robin"
            local ready_endpoints = {}
            
            for _, endpoint in ipairs(self.endpoints) do
                if endpoint.ready then
                    table.insert(ready_endpoints, endpoint)
                end
            end
            
            if #ready_endpoints == 0 then
                return nil, "No ready endpoints"
            end
            
            if strategy == "round_robin" then
                local index = (socket.gettime() % #ready_endpoints) + 1
                return ready_endpoints[math.floor(index)]
            elseif strategy == "random" then
                return ready_endpoints[math.random(#ready_endpoints)]
            else
                return ready_endpoints[1]
            end
        end,
        
        healthCheck = function(self)
            for _, endpoint in ipairs(self.endpoints) do
                -- Simulate health check
                endpoint.ready = math.random() > 0.1 -- 90% success rate
            end
        end,
        
        getInfo = function(self)
            return {
                metadata = self.metadata,
                spec = self.spec,
                endpoints = #self.endpoints,
                readyEndpoints = #self:getReadyEndpoints()
            }
        end,
        
        getReadyEndpoints = function(self)
            local ready = {}
            for _, endpoint in ipairs(self.endpoints) do
                if endpoint.ready then
                    table.insert(ready, endpoint)
                end
            end
            return ready
        end
    }
end

--[[
Container Orchestrator (Mini Kubernetes)
]]

local Orchestrator = {}

function Orchestrator.create()
    return {
        nodes = {},
        pods = {},
        services = {},
        deployments = {},
        
        addNode = function(self, name, capacity)
            local node = {
                name = name,
                capacity = capacity or { cpu = "4", memory = "8Gi", pods = "110" },
                allocatable = capacity or { cpu = "3.8", memory = "7.5Gi", pods = "110" },
                conditions = {
                    { type = "Ready", status = "True" },
                    { type = "MemoryPressure", status = "False" },
                    { type = "DiskPressure", status = "False" },
                    { type = "PIDPressure", status = "False" }
                },
                pods = {},
                ready = true
            }
            
            self.nodes[name] = node
            print("Node", name, "added to cluster")
            return node
        end,
        
        schedulePod = function(self, pod)
            -- Simple scheduling algorithm
            local bestNode = nil
            local minPods = math.huge
            
            for nodeName, node in pairs(self.nodes) do
                if node.ready and #node.pods < minPods then
                    minPods = #node.pods
                    bestNode = node
                end
            end
            
            if not bestNode then
                return false, "No suitable node found"
            end
            
            -- Schedule pod to node
            table.insert(bestNode.pods, pod)
            self.pods[pod.metadata.uid] = pod
            
            print("Pod", pod.metadata.name, "scheduled to node", bestNode.name)
            return true
        end,
        
        createDeployment = function(self, name, namespace, spec)
            spec = spec or {}
            local replicas = spec.replicas or 1
            
            local deployment = {
                metadata = {
                    name = name,
                    namespace = namespace or "default",
                    uid = "deployment-" .. math.random(100000, 999999)
                },
                spec = {
                    replicas = replicas,
                    selector = spec.selector or {},
                    template = spec.template or {}
                },
                status = {
                    replicas = 0,
                    readyReplicas = 0,
                    updatedReplicas = 0
                },
                pods = {}
            }
            
            -- Create replica pods
            for i = 1, replicas do
                local podName = name .. "-" .. math.random(10000, 99999)
                local pod = Pod.create(podName, namespace, spec.template)
                
                -- Add containers from template
                if spec.template.containers then
                    for _, containerSpec in ipairs(spec.template.containers) do
                        local container = Container.create(
                            containerSpec.name,
                            containerSpec.image,
                            containerSpec
                        )
                        pod:addContainer(container)
                    end
                end
                
                if self:schedulePod(pod) then
                    table.insert(deployment.pods, pod)
                    deployment.status.replicas = deployment.status.replicas + 1
                end
            end
            
            self.deployments[deployment.metadata.uid] = deployment
            print("Deployment", name, "created with", replicas, "replicas")
            return deployment
        end,
        
        scaleDeployment = function(self, deploymentUid, replicas)
            local deployment = self.deployments[deploymentUid]
            if not deployment then
                return false, "Deployment not found"
            end
            
            local currentReplicas = #deployment.pods
            
            if replicas > currentReplicas then
                -- Scale up
                for i = currentReplicas + 1, replicas do
                    local podName = deployment.metadata.name .. "-" .. math.random(10000, 99999)
                    local pod = Pod.create(podName, deployment.metadata.namespace, deployment.spec.template)
                    
                    if self:schedulePod(pod) then
                        table.insert(deployment.pods, pod)
                    end
                end
            elseif replicas < currentReplicas then
                -- Scale down
                for i = currentReplicas, replicas + 1, -1 do
                    local pod = table.remove(deployment.pods)
                    if pod then
                        pod:delete()
                        self.pods[pod.metadata.uid] = nil
                    end
                end
            end
            
            deployment.spec.replicas = replicas
            deployment.status.replicas = #deployment.pods
            print("Deployment", deployment.metadata.name, "scaled to", replicas, "replicas")
            return true
        end,
        
        getClusterStatus = function(self)
            local nodeCount = 0
            local readyNodes = 0
            local totalPods = 0
            local runningPods = 0
            
            for _, node in pairs(self.nodes) do
                nodeCount = nodeCount + 1
                if node.ready then readyNodes = readyNodes + 1 end
                totalPods = totalPods + #node.pods
            end
            
            for _, pod in pairs(self.pods) do
                if pod.status.phase == "Running" then
                    runningPods = runningPods + 1
                end
            end
            
            return {
                nodes = {
                    total = nodeCount,
                    ready = readyNodes
                },
                pods = {
                    total = totalPods,
                    running = runningPods
                },
                deployments = #self.deployments,
                services = #self.services
            }
        end
    }
end

--[[
Example: Microservices Platform Demo
]]

local function microservicesPlatformDemo()
    print("=== Microservices Platform Demo ===")
    
    -- Create orchestrator
    local k8s = Orchestrator.create()
    
    -- Add nodes to cluster
    k8s:addNode("node-1", { cpu = "4", memory = "8Gi", pods = "50" })
    k8s:addNode("node-2", { cpu = "4", memory = "8Gi", pods = "50" })
    k8s:addNode("node-3", { cpu = "2", memory = "4Gi", pods = "30" })
    
    -- Create web application deployment
    local webDeployment = k8s:createDeployment("web-app", "production", {
        replicas = 3,
        template = {
            containers = {
                {
                    name = "web",
                    image = "nginx:latest",
                    ports = { { containerPort = 80 } },
                    cpu = "200m",
                    memory = "256Mi"
                }
            }
        }
    })
    
    -- Create API deployment
    local apiDeployment = k8s:createDeployment("api-server", "production", {
        replicas = 2,
        template = {
            containers = {
                {
                    name = "api",
                    image = "myapp/api:v1.2.0",
                    ports = { { containerPort = 8080 } },
                    cpu = "500m",
                    memory = "512Mi",
                    env = {
                        DATABASE_URL = "postgres://db:5432/myapp",
                        REDIS_URL = "redis://cache:6379"
                    }
                }
            }
        }
    })
    
    -- Create database deployment
    local dbDeployment = k8s:createDeployment("database", "production", {
        replicas = 1,
        template = {
            containers = {
                {
                    name = "postgres",
                    image = "postgres:13",
                    ports = { { containerPort = 5432 } },
                    cpu = "1000m",
                    memory = "2Gi",
                    env = {
                        POSTGRES_DB = "myapp",
                        POSTGRES_USER = "user",
                        POSTGRES_PASSWORD = "password"
                    }
                }
            }
        }
    })
    
    -- Start all pods
    for _, pod in pairs(k8s.pods) do
        pod:start()
    end
    
    -- Create services
    local webService = Service.create("web-service", "production", {
        selector = { app = "web-app" },
        ports = { { port = 80, targetPort = 80 } },
        type = "LoadBalancer"
    })
    
    local apiService = Service.create("api-service", "production", {
        selector = { app = "api-server" },
        ports = { { port = 8080, targetPort = 8080 } },
        type = "ClusterIP"
    })
    
    local dbService = Service.create("db-service", "production", {
        selector = { app = "database" },
        ports = { { port = 5432, targetPort = 5432 } },
        type = "ClusterIP"
    })
    
    -- Add endpoints to services
    webService:addEndpoint("10.0.1.10", 80, "web-app-1")
    webService:addEndpoint("10.0.1.11", 80, "web-app-2")
    webService:addEndpoint("10.0.1.12", 80, "web-app-3")
    
    apiService:addEndpoint("10.0.2.10", 8080, "api-server-1")
    apiService:addEndpoint("10.0.2.11", 8080, "api-server-2")
    
    dbService:addEndpoint("10.0.3.10", 5432, "database-1")
    
    -- Simulate load balancing
    print("\nSimulating load balancing:")
    for i = 1, 5 do
        local endpoint = webService:getEndpoint("round_robin")
        if endpoint then
            print("Request", i, "routed to:", endpoint.ip .. ":" .. endpoint.port)
        end
    end
    
    -- Scale API deployment
    print("\nScaling API deployment from 2 to 4 replicas...")
    k8s:scaleDeployment(apiDeployment.metadata.uid, 4)
    
    -- Run health checks
    print("\nRunning health checks...")
    webService:healthCheck()
    apiService:healthCheck()
    dbService:healthCheck()
    
    -- Get cluster status
    print("\nCluster Status:")
    local status = k8s:getClusterStatus()
    print("Nodes:", status.nodes.ready .. "/" .. status.nodes.total, "ready")
    print("Pods:", status.pods.running .. "/" .. status.pods.total, "running")
    print("Deployments:", status.deployments)
    print("Services:", status.services)
    
    -- Get service info
    print("\nService Information:")
    print("Web Service:", json.encode(webService:getInfo()))
    print("API Service:", json.encode(apiService:getInfo()))
    print("DB Service:", json.encode(dbService:getInfo()))
    
    -- Show pod logs
    print("\nSample pod logs:")
    for uid, pod in pairs(k8s.pods) do
        if pod.metadata.name:match("web%-app") then
            local logs = pod:getLogs(3)
            print("Logs from", pod.metadata.name .. ":")
            print(logs:sub(1, 200) .. "...")
            break
        end
    end
    
    -- Container statistics
    print("\nContainer Statistics:")
    for uid, pod in pairs(k8s.pods) do
        for _, container in ipairs(pod.containers) do
            local stats = container:getStats()
            if stats then
                print(container.name .. ":", "CPU:", stats.cpu.usage, "Memory:", stats.memory.usage)
            end
        end
    end
end

-- Run the demo
microservicesPlatformDemo()

print("\nContainer orchestration and virtualization module loaded successfully!")

return {
    Container = Container,
    Pod = Pod,
    Service = Service,
    Orchestrator = Orchestrator
}
