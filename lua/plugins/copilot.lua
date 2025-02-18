return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  lazy = true,
  config = function()
    -- require("copilot").setup({
    --     suggestion = { enabled = false },
    --     panel = { enabled = false },
    --     filetypes = {}
    -- })
    require("copilot").setup {
      filetypes = {
        ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
      },
    }
  end,
}
