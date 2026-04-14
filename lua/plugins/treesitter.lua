return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        -- The module path has changed from 'nvim-treesitter.configs' to 'nvim-treesitter'
        local configs = require("nvim-treesitter")

        configs.setup({
            ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "javascript", "html" },
            sync_install = false,
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
    dependencies = {
        { 
            'JoosepAlviste/nvim-ts-context-commentstring',
            config = function()
                require('ts_context_commentstring').setup({
                    enable_autocmd = false,
                })
            end
        }
    }
}
