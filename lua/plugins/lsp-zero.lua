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
        -- config = true,
        config = function()
            require('mason').setup({
                ui = {
                    border = "rounded"
                }
            })
        end
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
            require("luasnip/loaders/from_vscode").load({ include = { "html" } })
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
                    local opts = { buffer = event.buf }

                    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
                    vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
                    vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration() end, opts)
                    vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end, opts)
                    vim.keymap.set('n', 'go', function() vim.lsp.buf.type_definition() end, opts)
                    vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, opts)
                    vim.keymap.set('n', 'gn', function() vim.lsp.buf.signature_help() end, opts)
                    vim.keymap.set('n', '<F2>', function() vim.lsp.buf.rename() end, opts)
                    vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                    vim.keymap.set('n', '<F4>', function() vim.lsp.buf.code_action() end, opts)

                    -- Diagnostics
                    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
                    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
                    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)

                    -- View diagnostics in quickfix window
                    vim.keymap.set("n", "<leader>vq", function()
                        local diagnostics = vim.diagnostic.get(0) -- Get diagnostics for the current buffer
                        local quickfix_list = {}

                        for _, diag in ipairs(diagnostics) do
                            table.insert(quickfix_list, {
                                bufnr = diag.bufnr,
                                lnum = diag.lnum + 1, -- Line numbers are 0-indexed, quickfix expects 1-indexed
                                col = diag.col + 1,   -- Column numbers are 0-indexed, quickfix expects 1-indexed
                                text = diag.message,
                                type = diag.severity == vim.diagnostic.severity.ERROR and 'E' or
                                    diag.severity == vim.diagnostic.severity.WARN and 'W' or
                                    diag.severity == vim.diagnostic.severity.INFO and 'I' or 'H',   -- Type of diagnostic
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
                    angularls = function()
                        local project_root = vim.fs.dirname(vim.fs.find({ 'package.json' }, { upward = true })[1])

                        -- Path to the local angular service and typescript
                        local cmd = {
                            "ngserver",
                            "--stdio",
                            "--tsProbeLocations", project_root .. "/node_modules",
                            "--ngProbeLocations", project_root .. "/node_modules",
                        }

                        require('lspconfig').angularls.setup({
                            cmd = cmd,
                            on_new_config = function(new_config, new_root_dir)
                                new_config.cmd = {
                                    "ngserver",
                                    "--stdio",
                                    "--tsProbeLocations", new_root_dir .. "/node_modules",
                                    "--ngProbeLocations", new_root_dir .. "/node_modules",
                                }
                            end,
                        })
                    end,
                    omnisharp = function()
                        require('lspconfig').omnisharp.setup {
                            cmd = { "dotnet", vim.fn.stdpath "data" .. "/mason/packages/omnisharp/libexec/OmniSharp.dll" },
                            enable_roslyn_analyzers = true,
                            organize_imports_on_format = false,
                            enable_import_completion = false,
                            filetypes = { "cs", "vb", "razor" },
                            log_level = vim.lsp.log_levels.ERROR,

                            handlers = {
                                ["textDocument/definition"] = require('omnisharp_extended').handler,
                            },

                            settings = {
                                dotnet = {
                                    backgroundAnalysis = {
                                        analyzerDiagnosticsScope = "openFiles",
                                        compilerDiagnosticsScope = "openFiles",
                                    },
                                    sdk = {
                                        path = vim.fn.exepath("dotnet"),
                                    },
                                    roslynExtensionsOptions = {
                                        enableAnalyzersSupport = true,
                                    },
                                    formattingOptions = {
                                        enableEditorConfigSupport = true,
                                    }
                                }
                            }
                        }
                    end,
                    html = function()
                        require('lspconfig').html.setup {
                            cmd = { "vscode-html-language-server", "--stdio" },
                            filetypes = { "html", "htmlangular" },
                            init_options = {
                                configurationSection = { "html", "css", "javascript" },
                                embeddedLanguages = {
                                    css = true,
                                    javascript = true
                                },
                                provideFormatter = true,
                            },
                            single_file_support = true,

                            settings = {
                                format = {
                                    contentUnformatted = "pre",
                                    wrapAttributes = {
                                        desc = "aligned-multiple",
                                        indentInnerHtml = true,
                                    }
                                }

                            }

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
                    dcmls = function()
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
                    dartls = function()
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
                    end,
                }
            })
        end
    },
    {
        "Hoffs/omnisharp-extended-lsp.nvim",
        lazy = true,
        config = function()
            -- Plugin loads automatically, handler is available via require('omnisharp_extended').handler
        end
    }
}
