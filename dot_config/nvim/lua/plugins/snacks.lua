return {
  {
    "snacks.nvim",
    opts = {
      scroll = { enabled = false },
      picker = {
        sources = {
          projects = {
            dev = { "~/git" },
            max_depth = 5,
          },
        },
      },
    },
  },
}
