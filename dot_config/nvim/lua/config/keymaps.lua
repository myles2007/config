-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "g.", vim.lsp.buf.code_action, { desc = "Show code actions" })
-- vim.keymap.set("n", "<leader>z", require("snacks").
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>z")

-- vim.keymap.set({ "n", "i" }, "<C-i>", function()
--   vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
-- end, { desc = "Toggle inlay_hints" })
