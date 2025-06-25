local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local base = require("plugins.configs.lspconfig")

local lspconfig = require("lspconfig")
local util = require "lspconfig/util"

lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "rustup", "run", "stable", "rust-analyzer" },
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
      cargo = {
        allFeatures = true,
      },
      procMacro = {
        enable = true,
      },
    },
  },
  filetypes = { "rust" },
  root_dir = util.root_pattern("Cargo.toml", "rust-project.json"),
}
lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server.capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)

  end,
  capabilities = capabilities,
}

-- Add vue-language-server (volar)
lspconfig.volar.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
  root_dir = util.root_pattern("package.json", "vue.config.js", ".git"),
}

-- Add eslint language server
lspconfig.eslint.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    format = { enable = true },
  },
  root_dir = util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.json", "package.json", ".git"),
}

-- Optionally, for typescript-language-server (if you want it alongside volar)
lspconfig.ts_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = util.root_pattern("package.json", "tsconfig.json", ".git"),
}


