-------------------- LSP -----------------------------------
--vim.cmd 'set signcolumn=auto'
--vim.cmd 'set shortmess+=c'
--vim.cmd 'set completeopt=menuone,noinsert,noselect'
--vim.cmd 'set pumheight=10'

local util = require('util')
local function setup_servers()
    require'lspinstall'.setup()
    -- get all installed servers
    local servers = require'lspinstall'.installed_servers()
    for _, server in pairs(servers) do
        local config = {}
        if server == "go" then
            config = {
                cmd = {"gopls", "serve"},
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                        },
                        staticcheck = true,
                    }
                }
            }
        end
        if server == "lua" then
            --config = {
            --    --cmd = {vim.fn.stdpath("data").."/bin/linux/lua-language-server", "-E", vim.fn.stdpath("data") .. "/main.lua"},
            --    settings = {
            --        Lua = {
            --            diagnostics = {
            --                globals = {'vim'},
            --            },
            --            workspace = {
            --                library = {
            --                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            --                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            --                },
            --            },
            --        },
            --    }
            --}
            -- Configure lua language server for neovim development
            local sumneko_root = vim.fn.stdpath("data").."/lspinstall/lua/sumneko-lua/extension/server"
            config = {
                cmd = {sumneko_root .. "/bin/Linux/lua-language-server", "-E", sumneko_root .. "/main.lua"},
                settings = {
                    Lua = {
                      runtime = {
                        -- LuaJIT in the case of Neovim
                        version = 'LuaJIT',
                        path = vim.split(package.path, ';'),
                      },
                      diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = {'vim'},
                      },
                      workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = {
                          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                        },
                      },
                    },
                },
            }
        end
        -- for debug
        -- print(vim.inspect(config))
        require'lspconfig'[server].setup{config}
    end
end

setup_servers()

function Goimports(timeout_ms)
  print "action"
  local context = { source = { organizeImports = true } }
  vim.validate { context = { context, "t", true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  if not result or next(result) == nil then return end
  local actions = result[1].result
  if not actions then return end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == "table" then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == "table" then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

--https://github.com/iamcco/diagnostic-languageserver
--lsp.diagnosticls.setup {
--  cmd = {"diagnostic-languageserver"},
--  filetypes = {"javascript", "typescript", "javascriptreact", "typescriptreact", "javascript.jsx", "typescript.tsx"},
--  init_options = {
--    filetypes = {
--      javascript = "eslint",
--      javascriptreact = "eslint",
--      typescript = "eslint",
--      typescriptreact = "eslint",
--      ["typescript.tsx"] = "eslint",
--      ["javascript.jsx"] = "eslint",
--      go = "goimports"
--    },
--    linters = {
--      eslint = {
--        command = "./node_modules/.bin/eslint",
--        rootPatterns = {".git"},
--        debounce = 100,
--        args = {
--          "--stdin",
--          "--stdin-filename",
--          "%filepath",
--          "--format",
--          "json"
--        },
--        sourceName = "eslint",
--        parseJson = {
--          errorsRoot = "[0].messages",
--          line = "line",
--          column = "column",
--          endLine = "endLine",
--          endColumn = "endColumn",
--          message = "[eslint] ${message} [${ruleId}]",
--          security = "severity"
--        },
--        securities = {
--          [2] = "error",
--          [1] = "warning"
--        }
--      }
--    }
--  }
--}
-- sagaに任せるものはこちらではコメントアウト
--util.map('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
--util.map('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
--util.map('n', 'ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
--util.map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
--util.map('n', 'rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
--util.map('n', '<leader>ee', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
util.map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
util.map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
util.map('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
util.map('n', 'fmt', '<cmd>lua vim.lsp.buf.formatting()<CR>')
util.map('n', '<leader>ai', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
util.map('n', '<leader>ao', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
util.map('n', '<space>r', '<cmd>lua vim.lsp.buf.references()<CR>')
util.map('n', '<space>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')

vim.cmd([[ autocmd BufWritePost *.js,*.ts,*.tsx,*.jsx lua vim.lsp.buf.formatting() ]])
--vim.cmd([[ autocmd BufWritePost *.go lua Goimports(1000) ]])
