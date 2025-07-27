-- Advanced Neovim Lua Scripting

-- Custom floating window
local buf = vim.api.nvim_create_buf(false, true)
local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = 40,
    height = 10,
    row = 5,
    col = 10,
    style = 'minimal'
})
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'Hello from floating window!' })

-- Dynamic keymaps
vim.api.nvim_set_keymap('n', '<leader>tt', ':tabnew<CR>', { noremap = true, silent = true })

-- Command completion
vim.api.nvim_create_user_command('CompleteMe', function(opts)
    print('Completion:', opts.args)
end, { nargs = 1, complete = 'file' })

-- LSP custom handler
vim.lsp.handlers['textDocument/hover'] = function(_, result, ctx, config)
    print('Hover:', vim.inspect(result))
end

-- Treesitter query
-- local ts = require 'vim.treesitter'
-- local parser = ts.get_parser(0, 'lua')
-- local tree = parser:parse()[1]
-- print(vim.inspect(tree:root()))
