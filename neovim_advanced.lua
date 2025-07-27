-- Advanced Neovim Plugin Development for Senior Engineers

-- Modern Neovim API patterns used in big tech companies
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local keymap = vim.keymap
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

--[[
LSP Integration Patterns (Google/Microsoft-style IDE features)
]]

local LSPIntegration = {}

function LSPIntegration.setup()
    -- Advanced LSP configuration for enterprise development
    local lsp_config = {
        -- TypeScript/JavaScript (for web infrastructure)
        tsserver = {
            settings = {
                typescript = {
                    inlayHints = {
                        includeInlayParameterNameHints = "all",
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    }
                }
            }
        },
        
        -- Go (infrastructure/backend services)
        gopls = {
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                        shadow = true,
                    },
                    staticcheck = true,
                    codelenses = {
                        gc_details = true,
                        generate = true,
                        regenerate_cgo = true,
                        test = true,
                        tidy = true,
                        upgrade_dependency = true,
                        vendor = true,
                    },
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                }
            }
        },
        
        -- Rust (systems programming)
        rust_analyzer = {
            settings = {
                ["rust-analyzer"] = {
                    cargo = {
                        allFeatures = true,
                        loadOutDirsFromCheck = true,
                        runBuildScripts = true,
                    },
                    checkOnSave = {
                        allFeatures = true,
                        command = "clippy",
                        extraArgs = { "--no-deps" },
                    },
                    procMacro = {
                        enable = true,
                        ignored = {
                            ["async-trait"] = { "async_trait" },
                            ["napi-derive"] = { "napi" },
                            ["async-recursion"] = { "async_recursion" },
                        },
                    },
                }
            }
        },
        
        -- Python (data engineering/ML)
        pylsp = {
            settings = {
                pylsp = {
                    plugins = {
                        pycodestyle = {
                            ignore = { 'W391' },
                            maxLineLength = 100,
                        },
                        pyflakes = { enabled = true },
                        pylint = { enabled = true },
                        black = { enabled = true },
                        isort = { enabled = true },
                        mypy = { enabled = true },
                    }
                }
            }
        }
    }
    
    -- Setup LSP servers with advanced configurations
    for server, config in pairs(lsp_config) do
        require('lspconfig')[server].setup(config)
    end
    
    -- Advanced LSP keymaps for productivity
    local function setup_lsp_keymaps(bufnr)
        local opts = { buffer = bufnr, silent = true }
        
        -- Navigation (Google-style code browsing)
        keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
        
        -- Code actions and refactoring
        keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
        
        -- Diagnostics (enterprise error handling)
        keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
        keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
        
        -- Workspace management
        keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
    end
    
    -- Auto-setup LSP keymaps on LSP attach
    autocmd("LspAttach", {
        group = augroup("UserLspConfig", {}),
        callback = function(ev)
            setup_lsp_keymaps(ev.buf)
            
            -- Enable inlay hints if supported
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client and client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(ev.buf, true)
            end
        end,
    })
end

--[[
Advanced Telescope Configuration (Google-style Code Search)
]]

local TelescopeConfig = {}

function TelescopeConfig.setup()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    local builtin = require('telescope.builtin')
    
    telescope.setup {
        defaults = {
            -- Google-style fuzzy search
            prompt_prefix = "🔍 ",
            selection_caret = "▶ ",
            path_display = { "truncate" },
            
            -- Advanced file filtering
            file_ignore_patterns = {
                "node_modules/", ".git/", "dist/", "build/",
                "target/", "*.lock", "*.log"
            },
            
            -- Improved sorting and matching
            sorting_strategy = "ascending",
            layout_strategy = "horizontal",
            layout_config = {
                horizontal = {
                    prompt_position = "top",
                    preview_width = 0.55,
                    results_width = 0.8,
                },
                vertical = {
                    mirror = false,
                },
                width = 0.87,
                height = 0.80,
                preview_cutoff = 120,
            },
            
            -- Advanced mappings
            mappings = {
                i = {
                    ["<C-n>"] = actions.cycle_history_next,
                    ["<C-p>"] = actions.cycle_history_prev,
                    ["<C-j>"] = actions.move_selection_next,
                    ["<C-k>"] = actions.move_selection_previous,
                    ["<C-c>"] = actions.close,
                    ["<Down>"] = actions.move_selection_next,
                    ["<Up>"] = actions.move_selection_previous,
                    ["<CR>"] = actions.select_default,
                    ["<C-x>"] = actions.select_horizontal,
                    ["<C-v>"] = actions.select_vertical,
                    ["<C-t>"] = actions.select_tab,
                    ["<C-u>"] = actions.preview_scrolling_up,
                    ["<C-d>"] = actions.preview_scrolling_down,
                },
                n = {
                    ["<esc>"] = actions.close,
                    ["<CR>"] = actions.select_default,
                    ["<C-x>"] = actions.select_horizontal,
                    ["<C-v>"] = actions.select_vertical,
                    ["<C-t>"] = actions.select_tab,
                    ["j"] = actions.move_selection_next,
                    ["k"] = actions.move_selection_previous,
                    ["H"] = actions.move_to_top,
                    ["M"] = actions.move_to_middle,
                    ["L"] = actions.move_to_bottom,
                    ["<Down>"] = actions.move_selection_next,
                    ["<Up>"] = actions.move_selection_previous,
                    ["gg"] = actions.move_to_top,
                    ["G"] = actions.move_to_bottom,
                    ["<C-u>"] = actions.preview_scrolling_up,
                    ["<C-d>"] = actions.preview_scrolling_down,
                },
            },
        },
        
        extensions = {
            -- Advanced file browser
            file_browser = {
                theme = "ivy",
                hijack_netrw = true,
                mappings = {
                    ["i"] = {
                        ["<A-c>"] = require("telescope._extensions.file_browser.actions").create,
                        ["<S-CR>"] = require("telescope._extensions.file_browser.actions").create_from_prompt,
                        ["<A-r>"] = require("telescope._extensions.file_browser.actions").rename,
                        ["<A-m>"] = require("telescope._extensions.file_browser.actions").move,
                        ["<A-y>"] = require("telescope._extensions.file_browser.actions").copy,
                        ["<A-d>"] = require("telescope._extensions.file_browser.actions").remove,
                        ["<C-o>"] = require("telescope._extensions.file_browser.actions").open,
                        ["<C-g>"] = require("telescope._extensions.file_browser.actions").goto_parent_dir,
                        ["<C-e>"] = require("telescope._extensions.file_browser.actions").goto_home_dir,
                        ["<C-w>"] = require("telescope._extensions.file_browser.actions").goto_cwd,
                        ["<C-t>"] = require("telescope._extensions.file_browser.actions").change_cwd,
                        ["<C-f>"] = require("telescope._extensions.file_browser.actions").toggle_browser,
                        ["<C-h>"] = require("telescope._extensions.file_browser.actions").toggle_hidden,
                        ["<C-s>"] = require("telescope._extensions.file_browser.actions").toggle_all,
                    },
                },
            },
            
            -- Git integration
            git_worktree = {
                theme = "dropdown",
            },
            
            -- Project management
            project = {
                base_dirs = {
                    '~/dev',
                    '~/work',
                    '~/projects',
                },
                hidden_files = true,
                theme = "dropdown",
            }
        }
    }
    
    -- Load extensions
    telescope.load_extension('file_browser')
    telescope.load_extension('git_worktree')
    telescope.load_extension('project')
    
    -- Custom search functions for enterprise development
    local function live_grep_git_root()
        local git_root = fn.system("git rev-parse --show-toplevel")
        if vim.v.shell_error ~= 0 then
            builtin.live_grep()
        else
            builtin.live_grep { search_dirs = { git_root:gsub("\n", "") } }
        end
    end
    
    local function find_files_git_root()
        local git_root = fn.system("git rev-parse --show-toplevel")
        if vim.v.shell_error ~= 0 then
            builtin.find_files()
        else
            builtin.find_files { cwd = git_root:gsub("\n", "") }
        end
    end
    
    -- Keymaps for Google-style productivity
    keymap.set('n', '<leader>ff', builtin.find_files, {})
    keymap.set('n', '<leader>fg', builtin.live_grep, {})
    keymap.set('n', '<leader>fb', builtin.buffers, {})
    keymap.set('n', '<leader>fh', builtin.help_tags, {})
    keymap.set('n', '<leader>fr', builtin.oldfiles, {})
    keymap.set('n', '<leader>fc', builtin.commands, {})
    keymap.set('n', '<leader>fk', builtin.keymaps, {})
    keymap.set('n', '<leader>fs', builtin.grep_string, {})
    keymap.set('n', '<leader>fd', builtin.diagnostics, {})
    keymap.set('n', '<leader>ft', builtin.treesitter, {})
    keymap.set('n', '<leader>fp', telescope.extensions.project.project, {})
    keymap.set('n', '<leader>fe', telescope.extensions.file_browser.file_browser, {})
    
    -- Git-aware searches
    keymap.set('n', '<leader>gf', find_files_git_root, {})
    keymap.set('n', '<leader>gg', live_grep_git_root, {})
    keymap.set('n', '<leader>gb', builtin.git_branches, {})
    keymap.set('n', '<leader>gc', builtin.git_commits, {})
    keymap.set('n', '<leader>gs', builtin.git_status, {})
    
    -- LSP integration
    keymap.set('n', '<leader>lr', builtin.lsp_references, {})
    keymap.set('n', '<leader>ld', builtin.lsp_definitions, {})
    keymap.set('n', '<leader>li', builtin.lsp_implementations, {})
    keymap.set('n', '<leader>lt', builtin.lsp_type_definitions, {})
    keymap.set('n', '<leader>ls', builtin.lsp_document_symbols, {})
    keymap.set('n', '<leader>lw', builtin.lsp_workspace_symbols, {})
end

--[[
Advanced Plugin Architecture (Enterprise Plugin Development)
]]

local PluginFramework = {}

function PluginFramework.create_plugin(name, config)
    local plugin = {
        name = name,
        config = config or {},
        commands = {},
        keymaps = {},
        autocmds = {},
        highlights = {},
        
        -- Plugin lifecycle
        setup = function(self, user_config)
            self.config = vim.tbl_deep_extend("force", self.config, user_config or {})
            self:_register_commands()
            self:_register_keymaps()
            self:_register_autocmds()
            self:_register_highlights()
            if self.on_setup then self:on_setup() end
        end,
        
        -- Command registration
        add_command = function(self, name, fn, opts)
            self.commands[name] = { fn = fn, opts = opts or {} }
        end,
        
        _register_commands = function(self)
            for name, cmd in pairs(self.commands) do
                api.nvim_create_user_command(name, cmd.fn, cmd.opts)
            end
        end,
        
        -- Keymap registration
        add_keymap = function(self, mode, lhs, rhs, opts)
            table.insert(self.keymaps, { mode = mode, lhs = lhs, rhs = rhs, opts = opts or {} })
        end,
        
        _register_keymaps = function(self)
            for _, map in ipairs(self.keymaps) do
                keymap.set(map.mode, map.lhs, map.rhs, map.opts)
            end
        end,
        
        -- Autocmd registration
        add_autocmd = function(self, event, pattern, callback, opts)
            table.insert(self.autocmds, {
                event = event,
                pattern = pattern,
                callback = callback,
                opts = opts or {}
            })
        end,
        
        _register_autocmds = function(self)
            local group = augroup(self.name, { clear = true })
            for _, autocmd_config in ipairs(self.autocmds) do
                autocmd_config.opts.group = group
                autocmd(autocmd_config.event, autocmd_config.opts)
            end
        end,
        
        -- Highlight registration
        add_highlight = function(self, name, opts)
            self.highlights[name] = opts
        end,
        
        _register_highlights = function(self)
            for name, opts in pairs(self.highlights) do
                api.nvim_set_hl(0, name, opts)
            end
        end,
        
        -- Utility methods
        create_floating_window = function(self, content, opts)
            opts = opts or {}
            local width = opts.width or math.floor(vim.o.columns * 0.8)
            local height = opts.height or math.floor(vim.o.lines * 0.8)
            
            local buf = api.nvim_create_buf(false, true)
            api.nvim_buf_set_lines(buf, 0, -1, false, content)
            
            local win = api.nvim_open_win(buf, true, {
                relative = 'editor',
                width = width,
                height = height,
                col = math.floor((vim.o.columns - width) / 2),
                row = math.floor((vim.o.lines - height) / 2),
                style = 'minimal',
                border = 'rounded',
                title = opts.title or self.name,
                title_pos = 'center',
            })
            
            return buf, win
        end,
        
        notify = function(self, message, level)
            vim.notify(string.format("[%s] %s", self.name, message), level or vim.log.levels.INFO)
        end
    }
    
    return plugin
end

--[[
Example: Advanced Git Integration Plugin
]]

local GitIntegration = PluginFramework.create_plugin("GitIntegration", {
    auto_stage = false,
    show_blame = true,
    commit_template = "feat: "
})

function GitIntegration:on_setup()
    -- Add git status to statusline
    self:add_autocmd("BufEnter", "*", function()
        self:update_git_status()
    end)
    
    -- Git blame virtual text
    if self.config.show_blame then
        self:add_autocmd("CursorHold", "*", function()
            self:show_git_blame()
        end)
    end
    
    -- Commands
    self:add_command("GitStatus", function() self:show_status() end, { desc = "Show git status" })
    self:add_command("GitCommit", function() self:commit_interactive() end, { desc = "Interactive commit" })
    self:add_command("GitBlame", function() self:toggle_blame() end, { desc = "Toggle git blame" })
    
    -- Keymaps
    self:add_keymap('n', '<leader>gs', function() self:show_status() end, { desc = "Git status" })
    self:add_keymap('n', '<leader>gc', function() self:commit_interactive() end, { desc = "Git commit" })
    self:add_keymap('n', '<leader>gb', function() self:toggle_blame() end, { desc = "Git blame" })
    
    -- Highlights
    self:add_highlight("GitBlameVirtText", { fg = "#7c7c7c", italic = true })
end

function GitIntegration:update_git_status()
    local git_root = fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
    if vim.v.shell_error == 0 then
        local branch = fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
        vim.g.git_branch = branch
    else
        vim.g.git_branch = nil
    end
end

function GitIntegration:show_git_blame()
    local line = api.nvim_win_get_cursor(0)[1]
    local file = api.nvim_buf_get_name(0)
    
    if file == "" then return end
    
    local blame_info = fn.system(string.format("git blame -L %d,%d --porcelain %s 2>/dev/null", line, line, file))
    if vim.v.shell_error == 0 then
        local author = blame_info:match("author ([^\n]+)")
        local date = blame_info:match("author%-time (%d+)")
        
        if author and date then
            local formatted_date = os.date("%Y-%m-%d", tonumber(date))
            local blame_text = string.format("• %s (%s)", author, formatted_date)
            
            api.nvim_buf_set_extmark(0, api.nvim_create_namespace("git_blame"), line - 1, 0, {
                virt_text = { { blame_text, "GitBlameVirtText" } },
                virt_text_pos = "eol"
            })
        end
    end
end

function GitIntegration:show_status()
    local status = fn.system("git status --porcelain")
    local lines = vim.split(status, "\n")
    
    local content = { "Git Status:", "" }
    for _, line in ipairs(lines) do
        if line ~= "" then
            table.insert(content, line)
        end
    end
    
    self:create_floating_window(content, { title = "Git Status", width = 60, height = 20 })
end

function GitIntegration:commit_interactive()
    local message = fn.input("Commit message: ", self.config.commit_template)
    if message and message ~= "" then
        local result = fn.system(string.format("git commit -m '%s'", message))
        if vim.v.shell_error == 0 then
            self:notify("Commit successful", vim.log.levels.INFO)
        else
            self:notify("Commit failed: " .. result, vim.log.levels.ERROR)
        end
    end
end

function GitIntegration:toggle_blame()
    -- Toggle blame virtual text
    self.blame_enabled = not self.blame_enabled
    if not self.blame_enabled then
        api.nvim_buf_clear_namespace(0, api.nvim_create_namespace("git_blame"), 0, -1)
    end
end

--[[
Setup Functions (Call these in your init.lua)
]]

local function setup_advanced_neovim()
    -- LSP setup
    LSPIntegration.setup()
    
    -- Telescope setup
    TelescopeConfig.setup()
    
    -- Custom git plugin
    GitIntegration:setup({
        auto_stage = true,
        show_blame = true,
        commit_template = "feat: "
    })
    
    -- Additional enterprise configurations
    vim.opt.completeopt = { "menu", "menuone", "noselect" }
    vim.opt.updatetime = 250
    vim.opt.timeoutlen = 300
    vim.opt.undofile = true
    vim.opt.backup = false
    vim.opt.swapfile = false
    vim.opt.cmdheight = 1
    vim.opt.pumheight = 10
    vim.opt.scrolloff = 8
    vim.opt.sidescrolloff = 8
    vim.opt.splitbelow = true
    vim.opt.splitright = true
    vim.opt.termguicolors = true
    vim.opt.wrap = false
    vim.opt.linebreak = true
    vim.opt.showbreak = "↪ "
    vim.opt.list = true
    vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }
    vim.opt.fillchars = { eob = " " }
    
    -- Advanced search and replace
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.inccommand = "split"
    
    -- Performance optimizations
    vim.opt.lazyredraw = false
    vim.opt.synmaxcol = 240
    vim.opt.updatetime = 250
    
    print("Advanced Neovim configuration loaded!")
end

-- Auto-setup if running in Neovim
if vim then
    setup_advanced_neovim()
end

return {
    LSPIntegration = LSPIntegration,
    TelescopeConfig = TelescopeConfig,
    PluginFramework = PluginFramework,
    GitIntegration = GitIntegration,
    setup = setup_advanced_neovim
}
