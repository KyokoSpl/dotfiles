
-- You can also add or configure plugins by creating files in this `plugins/` folder
-- PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ENABLING THIS FILE
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize dashboard options
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
        " ██████   █████  ██    ██                   ",
        "██       ██   ██  ██  ██                    ",
        "██   ███ ███████   ████                     ",
        "██    ██ ██   ██    ██                      ",
        " ██████  ██   ██    ██                      ",
        "                                            ",
        "                                            ",
        "                ███████ ██   ██ ██ ████████ ",
        "                ██      ██   ██ ██    ██    ",
        "                ███████ ███████ ██    ██    ",
        "                     ██ ██   ██ ██    ██    ",
        "                ███████ ██   ██ ██    ██    ",
        "                                            ",
        "                                            ",
          }, "\n"),
        },
      },
    },
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- Custom keybinding for documentation
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- Map K to show documentation
          ["K"] = {
            function()
              local filetype = vim.bo.filetype
              if filetype == "vim" or filetype == "help" then
                vim.cmd("help " .. vim.fn.expand("<cword>"))
              elseif #vim.lsp.get_active_clients({ bufnr = 0 }) > 0 then
                vim.lsp.buf.hover()
              else
                vim.cmd("!" .. vim.o.keywordprg .. " " .. vim.fn.expand("<cword>"))
              end
            end,
            desc = "Show documentation",
          },
        },
      },
    },
  },
}
