-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#0CFF15" })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#0CFF15", bg = "NONE" })

-- vim.diagnostic.config({
--   virtual_text = false, -- Disables inline diagnostic text
--   virtual_lines = true, -- Uses line-based diagnostic text for a bit more room...
--   signs = true, -- Keeps signs in the gutter
--   underline = true, -- Keeps highlighting of the error
-- })
