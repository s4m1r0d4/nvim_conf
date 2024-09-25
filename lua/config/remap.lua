vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- -- Paste in new line above with format
-- vim.keymap.set("v", "<leader>pu", "y :pu!<CR>V=")

-- Move line blocks
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor while appending the line bellow
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor in the middle of the screen while moving
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- don't think so...
-- greatest remap ever (keep text in clipboard after pasting it over smth)
-- vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland (Yank into system clipboard)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Paste system clipboard
vim.keymap.set("n", "<leader>sp", [["+p]])

-- Select all
vim.keymap.set("n", "<leader>e", [[ggVG]])

-- Select all and paste to system clipboard
vim.keymap.set("n", "<leader>E", [[ggVG"+y"]])

-- search and replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gIc<Left><Left><Left><Left>]])

-- Navigate tabs with tab key
vim.keymap.set('n', '<TAB>', 'gt')
vim.keymap.set('n', '<S-TAB>', 'gT')

-- Create new tab
vim.keymap.set('n', '<leader><TAB>', ':tabnew<CR>')
vim.keymap.set('n', '<leader>t', ':tabnew<CR>:terminal<CR>')
vim.keymap.set('n', '<leader>T', ':tabnew<CR>:terminal<CR><C-w>s:terminal<CR>')

-- Proyecto
-- vim.keymap.set('n', '<leader>x', ':tabnew<CR>:terminal<CR>i cd Server && go run .<CR><C-\\><C-n>:split<CR>:term<CR>i cd DomesticaWeb && ng s<CR>')

-- Select all
vim.keymap.set('n', '<TAB>', 'gt')

vim.keymap.set('t', "<Esc>", "<C-\\><C-n>")
vim.keymap.set('t', "<A-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set('t', "<A-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set('t', "<A-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set('t', "<A-l>", "<C-\\><C-N><C-w>l")

vim.keymap.set("i", "<A-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("i", "<A-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("i", "<A-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("i", "<A-l>", "<C-\\><C-N><C-w>l")
vim.keymap.set("n", "<A-h>", "<C-w>h")
vim.keymap.set("n", "<A-j>", "<C-w>j")
vim.keymap.set("n", "<A-k>", "<C-w>k")
vim.keymap.set("n", "<A-l>", "<C-w>l")


---- Plugin Keymaps ----

-- Telescope keymaps
local tls_built_in = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', tls_built_in.find_files, {})
vim.keymap.set('n', '<leader>fw', tls_built_in.live_grep, {})
vim.keymap.set('n', '<leader>gf', tls_built_in.git_files, {})

-- Undo tree keymaps
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- Vim fugitive
vim.keymap.set('n', '<leader>gs', vim.cmd.Git)

require('Comment').setup({
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})

-- go to angular template of correspondig angular component
vim.keymap.set('n', '<leader>at', function()
    local path = vim.fn.expand('%:p:h')
    local filename = vim.fn.expand('%:t:r')
    local template_path = path .. '/' .. filename .. '.html'
    vim.cmd('e ' .. template_path)
end)

-- go to angular template of correspondig angular component, split vertically
vim.keymap.set('n', '<leader>At', function()
    local path = vim.fn.expand('%:p:h')
    local filename = vim.fn.expand('%:t:r')
    local template_path = path .. '/' .. filename .. '.html'
    -- open template path in vertical split window
    vim.cmd('vs ' .. template_path)
end)

-- go to angular component of correspondig angular template
vim.keymap.set('n', '<leader>ac', function()
    local path = vim.fn.expand('%:p:h')
    local filename = vim.fn.expand('%:t:r')
    local template_path = path .. '/' .. filename .. '.ts'
    vim.cmd('e ' .. template_path)
end)

-- go to angular component of correspondig angular template, split vertically
vim.keymap.set('n', '<leader>Ac', function()
    local path = vim.fn.expand('%:p:h')
    local filename = vim.fn.expand('%:t:r')
    local template_path = path .. '/' .. filename .. '.ts'
    -- open template path in vertical split window
    vim.cmd('vs ' .. template_path)
end)
