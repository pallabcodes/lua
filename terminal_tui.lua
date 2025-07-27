-- Terminal UI and CLI Tools for Infrastructure Engineers

-- ANSI escape codes for terminal control
local ANSI = {
    -- Colors
    BLACK = "\27[30m",
    RED = "\27[31m",
    GREEN = "\27[32m",
    YELLOW = "\27[33m",
    BLUE = "\27[34m",
    MAGENTA = "\27[35m",
    CYAN = "\27[36m",
    WHITE = "\27[37m",
    RESET = "\27[0m",
    
    -- Background colors
    BG_BLACK = "\27[40m",
    BG_RED = "\27[41m",
    BG_GREEN = "\27[42m",
    BG_YELLOW = "\27[43m",
    BG_BLUE = "\27[44m",
    
    -- Text formatting
    BOLD = "\27[1m",
    DIM = "\27[2m",
    UNDERLINE = "\27[4m",
    BLINK = "\27[5m",
    REVERSE = "\27[7m",
    
    -- Cursor control
    CLEAR_SCREEN = "\27[2J",
    CLEAR_LINE = "\27[K",
    HOME = "\27[H",
    SAVE_CURSOR = "\27[s",
    RESTORE_CURSOR = "\27[u",
    HIDE_CURSOR = "\27[?25l",
    SHOW_CURSOR = "\27[?25h"
}

-- Helper functions for cursor movement
function ANSI.goto(row, col)
    return string.format("\27[%d;%dH", row, col)
end

function ANSI.up(n)
    return string.format("\27[%dA", n or 1)
end

function ANSI.down(n)
    return string.format("\27[%dB", n or 1)
end

function ANSI.right(n)
    return string.format("\27[%dC", n or 1)
end

function ANSI.left(n)
    return string.format("\27[%dD", n or 1)
end

--[[
Terminal UI Framework (Google-style Infrastructure Tools)
]]

local TUI = {}

function TUI.init()
    -- Setup terminal for TUI mode
    os.execute("stty -echo -icanon")
    io.write(ANSI.CLEAR_SCREEN .. ANSI.HOME .. ANSI.HIDE_CURSOR)
    io.flush()
end

function TUI.cleanup()
    -- Restore terminal state
    io.write(ANSI.SHOW_CURSOR .. ANSI.RESET)
    os.execute("stty echo icanon")
    print() -- New line
end

function TUI.getTerminalSize()
    local handle = io.popen("stty size")
    local result = handle:read("*a")
    handle:close()
    local rows, cols = result:match("(%d+) (%d+)")
    return tonumber(rows), tonumber(cols)
end

function TUI.drawBox(x, y, width, height, title)
    local box = {}
    -- Top border
    table.insert(box, ANSI.goto(y, x) .. "┌" .. string.rep("─", width-2) .. "┐")
    
    -- Side borders
    for i = 1, height-2 do
        table.insert(box, ANSI.goto(y+i, x) .. "│" .. string.rep(" ", width-2) .. "│")
    end
    
    -- Bottom border
    table.insert(box, ANSI.goto(y+height-1, x) .. "└" .. string.rep("─", width-2) .. "┘")
    
    -- Title if provided
    if title then
        local titlePos = x + math.floor((width - #title) / 2)
        table.insert(box, ANSI.goto(y, titlePos) .. ANSI.BOLD .. title .. ANSI.RESET)
    end
    
    return table.concat(box)
end

function TUI.drawProgressBar(x, y, width, percent, label)
    local filled = math.floor(width * percent / 100)
    local empty = width - filled
    
    local bar = ANSI.goto(y, x) .. 
                ANSI.BG_GREEN .. string.rep(" ", filled) .. 
                ANSI.BG_BLACK .. string.rep(" ", empty) .. 
                ANSI.RESET
    
    if label then
        bar = bar .. " " .. label .. " " .. percent .. "%"
    end
    
    return bar
end

--[[
Interactive CLI Components
]]

local CLI = {}

function CLI.menu(title, options)
    local selected = 1
    
    while true do
        -- Clear screen and draw menu
        io.write(ANSI.CLEAR_SCREEN .. ANSI.HOME)
        print(ANSI.BOLD .. title .. ANSI.RESET)
        print(string.rep("=", #title))
        print()
        
        for i, option in ipairs(options) do
            if i == selected then
                print(ANSI.REVERSE .. "> " .. option.text .. ANSI.RESET)
            else
                print("  " .. option.text)
            end
        end
        
        print("\nUse ↑↓ to navigate, Enter to select, q to quit")
        
        -- Get user input
        local char = CLI.getChar()
        
        if char == 'q' or char == 'Q' then
            break
        elseif char == '\n' or char == '\r' then
            if options[selected].action then
                options[selected].action()
            end
            break
        elseif char == '\27' then -- Escape sequence
            local seq = CLI.getChar() .. CLI.getChar()
            if seq == "[A" then -- Up arrow
                selected = selected > 1 and selected - 1 or #options
            elseif seq == "[B" then -- Down arrow
                selected = selected < #options and selected + 1 or 1
            end
        end
    end
    
    return selected
end

function CLI.getChar()
    -- Read single character without pressing Enter
    local handle = io.popen("dd bs=1 count=1 2>/dev/null")
    local char = handle:read(1)
    handle:close()
    return char or ""
end

function CLI.confirm(message, default)
    io.write(message .. " [" .. (default and "Y/n" or "y/N") .. "]: ")
    local response = io.read():lower()
    
    if response == "" then
        return default
    end
    
    return response:sub(1,1) == "y"
end

function CLI.input(prompt, default, validator)
    while true do
        io.write(prompt)
        if default then
            io.write(" [" .. default .. "]")
        end
        io.write(": ")
        
        local input = io.read()
        if input == "" and default then
            input = default
        end
        
        if not validator or validator(input) then
            return input
        else
            print(ANSI.RED .. "Invalid input. Please try again." .. ANSI.RESET)
        end
    end
end

--[[
Real-time Dashboard (Infrastructure Monitoring)
]]

local Dashboard = {}

function Dashboard.create()
    local self = {
        widgets = {},
        running = false
    }
    
    function self:addWidget(widget)
        table.insert(self.widgets, widget)
    end
    
    function self:start()
        TUI.init()
        self.running = true
        
        while self.running do
            -- Clear screen
            io.write(ANSI.CLEAR_SCREEN .. ANSI.HOME)
            
            -- Draw all widgets
            for _, widget in ipairs(self.widgets) do
                widget:draw()
            end
            
            -- Refresh rate
            os.execute("sleep 1")
        end
        
        TUI.cleanup()
    end
    
    function self:stop()
        self.running = false
    end
    
    return self
end

-- Widget types for dashboard
local Widget = {}

function Widget.systemInfo(x, y, width, height)
    return {
        x = x, y = y, width = width, height = height,
        draw = function(self)
            local uptime = io.popen("uptime"):read("*a"):gsub("\n", "")
            local memory = io.popen("free -h | grep Mem"):read("*a")
            local load = uptime:match("load average: ([%d%., ]+)")
            
            io.write(TUI.drawBox(self.x, self.y, self.width, self.height, "System Info"))
            io.write(ANSI.goto(self.y + 2, self.x + 2) .. "Uptime: " .. uptime:match("up (.+),"))
            io.write(ANSI.goto(self.y + 3, self.x + 2) .. "Load: " .. (load or "N/A"))
            io.write(ANSI.goto(self.y + 4, self.x + 2) .. "Memory: " .. (memory:match("Mem:%s+(%S+)") or "N/A"))
        end
    }
end

function Widget.logTail(x, y, width, height, logFile)
    return {
        x = x, y = y, width = width, height = height, logFile = logFile,
        draw = function(self)
            local lines = {}
            local handle = io.popen("tail -" .. (self.height - 3) .. " " .. self.logFile .. " 2>/dev/null")
            for line in handle:lines() do
                table.insert(lines, line:sub(1, self.width - 4)) -- Truncate long lines
            end
            handle:close()
            
            io.write(TUI.drawBox(self.x, self.y, self.width, self.height, "Log: " .. self.logFile))
            for i, line in ipairs(lines) do
                io.write(ANSI.goto(self.y + 1 + i, self.x + 2) .. line)
            end
        end
    }
end

function Widget.processMonitor(x, y, width, height)
    return {
        x = x, y = y, width = width, height = height,
        draw = function(self)
            local processes = {}
            local handle = io.popen("ps aux --sort=-%cpu | head -" .. (self.height - 2))
            local header = handle:read() -- Skip header
            for line in handle:lines() do
                table.insert(processes, line:sub(1, self.width - 4))
            end
            handle:close()
            
            io.write(TUI.drawBox(self.x, self.y, self.width, self.height, "Top Processes"))
            for i, proc in ipairs(processes) do
                io.write(ANSI.goto(self.y + 1 + i, self.x + 2) .. proc)
            end
        end
    }
end

--[[
CLI Argument Parser (Infrastructure Tool Pattern)
]]

local ArgParser = {}

function ArgParser.create(description)
    return {
        description = description,
        options = {},
        positional = {},
        
        addOption = function(self, short, long, description, default, required)
            table.insert(self.options, {
                short = short,
                long = long,
                description = description,
                default = default,
                required = required or false
            })
        end,
        
        addPositional = function(self, name, description, required)
            table.insert(self.positional, {
                name = name,
                description = description,
                required = required or false
            })
        end,
        
        parse = function(self, args)
            local result = { options = {}, positional = {} }
            local i = 1
            
            while i <= #args do
                local arg = args[i]
                
                if arg:sub(1,2) == "--" then
                    -- Long option
                    local name = arg:sub(3)
                    local value = args[i+1]
                    result.options[name] = value
                    i = i + 2
                elseif arg:sub(1,1) == "-" then
                    -- Short option
                    local name = arg:sub(2)
                    local value = args[i+1]
                    result.options[name] = value
                    i = i + 2
                else
                    -- Positional argument
                    table.insert(result.positional, arg)
                    i = i + 1
                end
            end
            
            return result
        end,
        
        help = function(self)
            print(self.description)
            print("\nOptions:")
            for _, opt in ipairs(self.options) do
                local optStr = "  -" .. opt.short .. ", --" .. opt.long
                if opt.required then optStr = optStr .. " (required)" end
                print(optStr .. " - " .. opt.description)
            end
            
            if #self.positional > 0 then
                print("\nPositional arguments:")
                for _, pos in ipairs(self.positional) do
                    local posStr = "  " .. pos.name
                    if pos.required then posStr = posStr .. " (required)" end
                    print(posStr .. " - " .. pos.description)
                end
            end
        end
    }
end

--[[
Example Infrastructure Tool: Log Analyzer
]]

local LogAnalyzer = {}

function LogAnalyzer.run()
    local parser = ArgParser.create("Log Analyzer - Analyze system logs")
    parser:addOption("f", "file", "Log file to analyze", "/var/log/syslog", true)
    parser:addOption("n", "lines", "Number of lines to process", "1000", false)
    parser:addOption("p", "pattern", "Pattern to search for", "", false)
    
    local args = parser:parse(arg or {})
    
    if args.options.help or not args.options.f then
        parser:help()
        return
    end
    
    print(ANSI.BOLD .. "Log Analysis Report" .. ANSI.RESET)
    print(string.rep("=", 50))
    
    local logFile = args.options.f or args.options.file
    local numLines = tonumber(args.options.n or args.options.lines) or 1000
    local pattern = args.options.p or args.options.pattern
    
    -- Analyze log file
    local lineCount = 0
    local errorCount = 0
    local warningCount = 0
    local patternMatches = 0
    
    local handle = io.popen("tail -" .. numLines .. " " .. logFile)
    for line in handle:lines() do
        lineCount = lineCount + 1
        
        if line:lower():find("error") then
            errorCount = errorCount + 1
        end
        
        if line:lower():find("warning") then
            warningCount = warningCount + 1
        end
        
        if pattern ~= "" and line:find(pattern) then
            patternMatches = patternMatches + 1
            print(ANSI.YELLOW .. "MATCH: " .. ANSI.RESET .. line:sub(1, 80))
        end
    end
    handle:close()
    
    print("\n" .. ANSI.GREEN .. "Summary:" .. ANSI.RESET)
    print("Total lines processed:", lineCount)
    print("Errors found:", ANSI.RED .. errorCount .. ANSI.RESET)
    print("Warnings found:", ANSI.YELLOW .. warningCount .. ANSI.RESET)
    if pattern ~= "" then
        print("Pattern matches:", ANSI.CYAN .. patternMatches .. ANSI.RESET)
    end
end

--[[
Example Usage: System Monitor Dashboard
]]

local function runSystemMonitor()
    local dashboard = Dashboard.create()
    
    local rows, cols = TUI.getTerminalSize()
    
    -- Add widgets
    dashboard:addWidget(Widget.systemInfo(1, 1, cols//2, 8))
    dashboard:addWidget(Widget.processMonitor(cols//2 + 1, 1, cols//2, 8))
    dashboard:addWidget(Widget.logTail(1, 9, cols, rows - 8, "/var/log/syslog"))
    
    print("Starting system monitor... (Ctrl+C to exit)")
    
    -- Handle Ctrl+C gracefully
    local function signalHandler()
        dashboard:stop()
        TUI.cleanup()
        os.exit(0)
    end
    
    -- Start dashboard
    dashboard:start()
end

--[[
Example Usage: Interactive CLI Menu
]]

local function runInteractiveMenu()
    local options = {
        { text = "System Information", action = function() 
            print("Gathering system info...")
            os.execute("uname -a; free -h; df -h")
        end },
        { text = "Process Monitor", action = function()
            print("Top processes:")
            os.execute("ps aux --sort=-%cpu | head -10")
        end },
        { text = "Network Status", action = function()
            print("Network interfaces:")
            os.execute("ip addr show")
        end },
        { text = "Disk Usage", action = function()
            print("Disk usage:")
            os.execute("df -h")
        end }
    }
    
    CLI.menu("System Administration Menu", options)
end

-- Example command-line tool interface
if arg and #arg > 0 then
    if arg[1] == "monitor" then
        runSystemMonitor()
    elseif arg[1] == "menu" then
        runInteractiveMenu()
    elseif arg[1] == "analyze" then
        LogAnalyzer.run()
    else
        print("Usage: lua terminal_tui.lua [monitor|menu|analyze]")
        print("  monitor - Run system monitor dashboard")
        print("  menu    - Run interactive system menu")
        print("  analyze - Run log analyzer")
    end
else
    -- Demo mode
    print(ANSI.BOLD .. "Terminal TUI Demo" .. ANSI.RESET)
    print("This module provides:")
    print("• ANSI terminal control")
    print("• Interactive CLI components")
    print("• Real-time dashboards")
    print("• Argument parsing")
    print("• Infrastructure monitoring tools")
    print("\nRun with: lua terminal_tui.lua [monitor|menu|analyze]")
end

return {
    ANSI = ANSI,
    TUI = TUI,
    CLI = CLI,
    Dashboard = Dashboard,
    Widget = Widget,
    ArgParser = ArgParser,
    LogAnalyzer = LogAnalyzer
}
