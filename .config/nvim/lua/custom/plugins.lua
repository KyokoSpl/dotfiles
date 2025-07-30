local cmp = require "cmp"

local plugins = {

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",
        "clangd",
        "clang-format",
        "codelldb",
        "stylua",
        "vue-language-server",
        "vscode-eslint-language-server",
        "typescript-language-server",
      },
    },
  },
--  {
--     "github/copilot.vim", 
    
--     lazy = false,
--     config = function()
--       -- Mapping tab is already used by NvChad
--       vim.g.copilot_no_tab_map = true;
--       vim.g.copilot_assume_mapped = true;
--       vim.g.copilot_tab_fallback = "";
--       -- The mapping is set to other key, see custom/lua/mappings
--       -- or run <leader>ch to see copilot mapping section
--     end
--   },
  --
  { 
  'IogaMaster/neocord',
  event = "VeryLazy",
  config = function()
    require("neocord").setup({
      -- General options
      logo                = "auto",                     -- "auto" or url
      logo_tooltip        = nil,                        -- nil or string
      main_image          = "language",                 -- "language" or "logo"
      client_id           = "1157438221865717891",      -- Use your own Discord application client id (not recommended)
      log_level           = nil,                        -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
      debounce_timeout    = 10,                         -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
      blacklist           = {},                         -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
      file_assets         = {},                         -- Custom file asset definitions keyed by file names and extensions (see default config at `lua/presence/file_assets.lua` for reference)
      show_time           = true,                       -- Show the timer
      global_timer        = false,                      -- if set true, timer won't update when any event are triggered
      buttons             = nil,                        -- A list of buttons (objects with label and url attributes) or a function returning such list.

      -- Rich Presence text options
      editing_text        = "Editing %s",               -- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
      file_explorer_text  = "Browsing %s",             -- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
      git_commit_text     = "Committing changes",      -- Format string rendered when committing changes in git (either string or function(filename: string): string)
      plugin_manager_text = "Managing plugins",        -- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
      reading_text        = "Reading %s",              -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
      workspace_text      = "Working on %s",           -- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
      line_number_text    = "Line %s out of %s",       -- Format string rendered when `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
      terminal_text       = "Using Terminal",          -- Format string rendered when in terminal mode.
    })
  end,
},
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  -- Add vue and eslint language servers
  {
    "jose-elias-alvarez/typescript.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    dependencies = "neovim/nvim-lspconfig",
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
    dependencies = "neovim/nvim-lspconfig",
    config = function()
      require "custom.configs.rustaceanvim"
    end
  },
  {
    "mfussenegger/nvim-dap",
    init = function()
      require("core.utils").load_mappings("dap")
    end
  },
  {
    'saecki/crates.nvim',
    ft = {"toml"},
    config = function(_, opts)
      local crates  = require('crates')
      crates.setup(opts)
      require('cmp').setup.buffer({
        sources = { { name = "crates" }}
      })
      crates.show()
      require("core.utils").load_mappings("crates")
    end,
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function ()
      vim.g.rustfmt_autosave = 1
    end
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    lazy = false,
    config = function(_, opts)
      require("nvim-dap-virtual-text").setup()
    end
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local M = require "plugins.configs.cmp"
      M.completion.completeopt = "menu,menuone,noselect"
      M.mapping["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = false,
      }
      table.insert(M.sources, {name = "crates"})
      return M
    end,
  },
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    dependencies = "neovim/nvim-lspconfig", -- Fixed: depencencies -> dependencies
    opts = function()
     return require("custom.configs.rust-tools") -- Fixed: added return
    end,
    config = function(_, opts)
      require("rust-tools").setup(opts)
    end,
  },
{
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "canary",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim" },
  },
  config = function()
    require("CopilotChat").setup({
      model = 'claude-3.5-sonnet', -- or 'claude-3.5-sonnet', 'gpt-4o-mini'
    })
  end,
},
{
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      copilot_model = 'claude-3.5-sonnet', -- or 'claude-3.5-sonnet', 'gpt-4o-mini'
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<C-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      copilot_node_command = 'node', -- Node.js version must be > 16.x
      server_opts_overrides = {
        -- You can try different model settings here
        settings = {
          advanced = {
            listCount = 10, -- Number of completions
            inlineSuggestCount = 3, -- Number of inline suggestions
          }
        }
      },
    })
  end,
},
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local languages = {
        "lua", "luadoc", "printf", "vim", "vimdoc",
        "rust", "javascript", "typescript", "vue", "html", "css"
      }
      opts.ensure_installed = languages
      opts.highlight = {
        enable = true,
        use_languagetree = true,
      }
      opts.indent = { enable = true }
      return opts
    end,
  },
}
return plugins
