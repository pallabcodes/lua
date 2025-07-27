-- Neovim config with Lua
-- Place in ~/.config/nvim/init.lua or source from there

vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Relative line numbers
vim.o.tabstop = 4 -- Tab width
vim.o.expandtab = true -- Use spaces for tabs
vim.cmd('colorscheme desert') -- Set colorscheme

-- Keymap example
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true })

-- Autocommand example
vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = '*.lua',
    callback = function()
        print('Lua file saved!')
    end,
})

--[[
Advanced Neovim Lua Config for Big Tech/Product Companies
]]

-- Plugin management (using packer.nvim)
-- Install packer.nvim first: https://github.com/wbthomason/packer.nvim
-- Example:
-- require('packer').startup(function()
--   use 'wbthomason/packer.nvim'
--   use 'nvim-telescope/telescope.nvim'
--   use 'neovim/nvim-lspconfig'
--   use 'hrsh7th/nvim-cmp'
-- end)

-- Custom command
vim.api.nvim_create_user_command('Greet', function()
    print('Hello from Neovim Lua!')
end, {})

-- LSP setup (using nvim-lspconfig)
-- local lspconfig = require('lspconfig')
-- lspconfig.pyright.setup{}
-- lspconfig.tsserver.setup{}

-- Diagnostics display
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
})

-- Statusline example (using lualine)
-- require('lualine').setup { options = { theme = 'gruvbox' } }

-- Productivity: autoformat on save
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*.lua',
    callback = function()
        vim.lsp.buf.format()
    end,
})

-- Productivity: toggle relative number
vim.api.nvim_set_keymap('n', '<leader>rn', ':set relativenumber!<CR>', { noremap = true, silent = true })

-- Productivity: open file explorer
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Productivity automations (enterprise scenario)
local function saveSession()
    vim.cmd('mksession! .session.vim')
    print('Session saved')
end
vim.api.nvim_create_user_command('SaveSession', saveSession, {})

-- Custom statusline (product scenario)
local function customStatusline()
    local mode = vim.api.nvim_get_mode().mode
    local file = vim.fn.expand('%:t')
    local line = vim.fn.line('.')
    local col = vim.fn.col('.')
    return string.format('[%s] %s %d:%d', mode, file, line, col)
end
vim.o.statusline = '%!v:lua.customStatusline()'

-- Advanced plugin chaining (productivity)
local function setupPluginChain()
    -- Chain: LSP -> Diagnostics -> Autocomplete -> Format
    vim.api.nvim_create_autocmd('LspAttach', {
        callback = function()
            print('LSP attached, setting up chain...')
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
        end
    })
end
setupPluginChain()
