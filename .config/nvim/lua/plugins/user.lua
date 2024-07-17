-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  vim.keymap.set("n", "<leader>rn", ":IncRename "),
  require("lspconfig").ruff_lsp.setup {
    init_options = {
      settings = {
        -- Any extra CLI arguments for `ruff` go here.
        args = {},
      },
    },
  },

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  "numToStr/Comment.nvim",

  require("Comment").setup(),

  require("lazy").setup({
    {
      "supermaven-inc/supermaven-nvim",
      config = function() require("supermaven-nvim").setup {} end,
    },
  }, {}),
}
