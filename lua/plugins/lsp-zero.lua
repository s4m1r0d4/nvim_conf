return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v4.x',
        lazy = true,
        config = false,
    },
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            {
                'L3MON4D3/LuaSnip',
                build = "make install_jsregexp"
            },
            { 'rafamadriz/friendly-snippets' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-path' },
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
                window = {
                    completion = cmp.config.window.bordered("rounded"),
                    documentation = cmp.config.window.bordered("rounded"),
                },
                sources = {
                    { name = 'nvim_lsp' },
                    {
                        name = 'luasnip',
                        -- group_index = 2
                    },
                    {
                        name = 'path',
                        -- group_index = 2
                    },
                    {
                        name = 'buffer',
                        keyword_length = 5,
                        -- group_index = 2
                    },
                    {
                        name = "copilot",
                        -- group_index = 2
                    }
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-f>'] = cmp.mapping(function(fallback)
                        if luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" })
                }),
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
            })


            require('luasnip.loaders.from_vscode').lazy_load()
        end
    },

    -- LSP
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            require("lspconfig.ui.windows").default_options.border = "rounded"

            -- lsp_attach is where you enable features that only work
            -- if there is a language server active in the file
            local lsp_attach = function(client, bufnr)
                local opts = { buffer = bufnr }

                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

                -- Diagnostics
                vim.keymap.set("n", "<leader>vd", '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
                vim.keymap.set("n", "[d", '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
                vim.keymap.set("n", "]d", '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
            end

            lsp_zero.extend_lspconfig({
                lsp_attach = lsp_attach,
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
                float_border = 'rounded',

                sign_text = {
                    error = '✘',
                    warn = '▲',
                    hint = '⚑',
                    info = '»',
                },
            })

            require('mason-lspconfig').setup({
                ensure_installed = {},
                handlers = {
                    -- this first function is the "default handler"
                    -- it applies to every language server without a "custom handler"
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,
                    omnisharp = function()
                        require('lspconfig').omnisharp.setup {
                            enable_roslyn_analyzers = true,
                            organize_imports_on_format = false,
                            enable_import_completion = false,
                            analyze_open_documents_only = false,
                            filetypes = { "cs", "vb", "razor" }
                        }
                    end,
                    html = function()
                        require('lspconfig').html.setup {
                            cmd = { "vscode-html-language-server", "--stdio" },
                            filetypes = { "html" },
                            init_options = {
                                configurationSection = { "html", "css", "javascript" },
                                embeddedLanguages = {
                                    css = true,
                                    javascript = true
                                },
                                provideFormatter = true
                            },
                            single_file_support = true
                        }
                    end,
                }
            })
        end
    }
}
