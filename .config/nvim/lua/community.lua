
-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.cmake"},
  { import = "astrocommunity.pack.cpp"},
  { import = "astrocommunity.pack.dart"},
  { import = "astrocommunity.pack.eslint"},
  { import = "astrocommunity.pack.fish"},
  { import = "astrocommunity.pack.go"},
  { import = "astrocommunity.pack.html-css"},
  { import = "astrocommunity.pack.json"},
  { import = "astrocommunity.pack.kotlin"},
  { import = "astrocommunity.pack.markdown"},
  { import = "astrocommunity.pack.prettier"},
  { import = "astrocommunity.pack.python-ruff"},
  { import = "astrocommunity.pack.sql"},
  { import = "astrocommunity.pack.tailwindcss"},
  { import = "astrocommunity.pack.toml"},
  { import = "astrocommunity.pack.typescript-all-in-one"},
  { import = "astrocommunity.pack.vue"},
  { import = "astrocommunity.pack.yaml."},
