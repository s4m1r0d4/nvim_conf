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
                build = "make install_jsregexp",
                dependencies = { 'rafamadriz/friendly-snippets' },
            },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-path' },
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            -- angular template files '*.html' are interpreted as 'htmlangular' instead of 'html'
            require("luasnip").filetype_extend("htmlangular", { "html" })
            require("luasnip/loaders/from_vscode").load({include = {"html"}})
            require('luasnip.loaders.from_vscode').lazy_load()

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
                        -- keyword_length = 5,
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
                        local indent_nodes = true
                        if vim.api.nvim_get_option_value("filetype", { buf = 0 }) == "dart" then
                            indent_nodes = false
                        end
                        require("luasnip").lsp_expand(args.body, {
                            indent = indent_nodes,
                        })
                        -- vim.snippet.expand(args.body)
                    end,
                },
            })
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

            local lsp_defaults = require('lspconfig').util.default_config

            -- Add cmp_nvim_lsp capabilities settings to lspconfig
            -- This should be executed before you configure any language server
            lsp_defaults.capabilities = vim.tbl_deep_extend(
                'force',
                lsp_defaults.capabilities,
                require('cmp_nvim_lsp').default_capabilities()
            )

            lsp_defaults.capabilities.textDocument.completion.completionItem.snippetSupport = true

            -- lsp_attach is where you enable features that only work
            -- if there is a language server active in the file
            vim.api.nvim_create_autocmd('LspAttach', {
                desc = 'LSP actions',
                callback = function(event)
                    local opts = {buffer = event.buf}

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
                vim.keymap.set("n", "[d", '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
                vim.keymap.set("n", "]d", '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)

                -- View diagnostics in quickfix window
                vim.keymap.set("n", "<leader>vq", function()
                    local diagnostics = vim.diagnostic.get(0)  -- Get diagnostics for the current buffer
                    local quickfix_list = {}

                    for _, diag in ipairs(diagnostics) do
                        table.insert(quickfix_list, {
                            bufnr = diag.bufnr,
                            lnum = diag.lnum + 1,  -- Line numbers are 0-indexed, quickfix expects 1-indexed
                            col = diag.col + 1,    -- Column numbers are 0-indexed, quickfix expects 1-indexed
                            text = diag.message,
                            type = diag.severity == vim.diagnostic.severity.ERROR and 'E' or
                                  diag.severity == vim.diagnostic.severity.WARN and 'W' or
                                  diag.severity == vim.diagnostic.severity.INFO and 'I' or 'H',  -- Type of diagnostic
                        })
                    end

                    -- Set the quickfix list with the gathered diagnostics
                    vim.fn.setqflist(quickfix_list, 'r')

                    -- Open the quickfix window
                    vim.cmd('copen')
                end, { buffer = 0 })
                end,
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
                    gopls = function()
                        require 'lspconfig'.gopls.setup {
                            settings = {
                                gopls = {
                                    env = {
                                        GOFLAGS = "-tags=windows,linux,unittest"
                                    }
                                },
                            },
                            on_attach = function(client, bufnr)
                                print('golang mode')
                                -- Golang likes tabs...
                                vim.opt.expandtab = false
                            end
                        }
                    end,
                    dcmls = function ()
                        require 'lspconfig'.gopls.setup {
                            on_attach = function(client, bufnr)
                                vim.opt.tabstop = 2
                                vim.opt.softtabstop = 2
                                vim.opt.shiftwidth = 2
                            end
                        }
                    end,
                    jdtls = function()
                        require('lspconfig').jdtls.setup({
                            on_attach = lsp_attach,
                            capabilities = require('cmp_nvim_lsp').default_capabilities(),
                            cmd = { "jdtls" },
                        })
                    end,
                    dartls = function ()
                        require("lspconfig").dartls.setup({
                            cmd = { "dart", "language-server", "--protocol=lsp" },
                            filetypes = { "dart" },
                            init_options = {
                                closingLabels = true,
                                flutterOutline = true,
                                onlyAnalyzeProjectsWithOpenFiles = true,
                                outline = true,
                                suggestFromUnimportedLibraries = true,
                            },
                            -- root_dir = root_pattern("pubspec.yaml"),
                            settings = {
                                dart = {
                                    completeFunctionCalls = true,
                                    showTodos = true,
                                },
                            },
                            on_attach = function(client, bufnr)
                            end,
                        })
                    end
                }
            })
        end
    }
}
