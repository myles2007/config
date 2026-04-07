-- https://github.com/rachartier/tiny-inline-diagnostic.nvim#configuration
return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      multilines = {
        enabled = true,
      },
      -- Automatically disable diagnostics when opening diagnostic float windows
      override_open_float = false,
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = { diagnostics = { virtual_text = false } },
  },
}
