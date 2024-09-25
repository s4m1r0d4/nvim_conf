return {
  "zbirenbaum/copilot-cmp",
  config = function ()
    require("copilot_cmp").setup()
  end,
  dependencies = {
      { 'hrsh7th/nvim-cmp' }
  }
}
