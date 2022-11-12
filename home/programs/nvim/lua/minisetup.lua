local ucmd = vim.api.nvim_create_user_command

require('mini.align').setup({ mappings = { start_with_preview = '<cr>' } })
require('mini.bufremove').setup()
require('mini.comment').setup()
require('mini.starter').setup()
require('mini.statusline').setup()
require('mini.tabline').setup()

ucmd('BD', function()
  MiniBufremove.delete()
end, {})

