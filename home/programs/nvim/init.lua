local cmd = vim.cmd
local g = vim.g
local kmap = vim.keymap.set
local o = vim.o
local opt = vim.opt

g.mapleader = ','

cmd 'colorscheme tokyonight'

require("telescope").setup {
  extensions = {
    file_browser = {
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
    },
  },
}
require("telescope").load_extension "file_browser"
kmap('n', '<leader>fb', ':Telescope file_browser<cr>')
kmap('n', '<leader>d', ':Telescope diagnostics<cr>')

require('gitsigns').setup()
require('colorizer').setup { user_default_options = { names = false } }
require('which-key').setup()

require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
}

if string.find(o.shell, 'fish') then
  o.shell = 'sh'
end

if vim.fn.has 'gui_running' == 0 then
  o.titlestring = '%{expand("%:~:h")}'
  o.termguicolors = true
end

o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true

o.textwidth = 78
o.wrap = false
o.whichwrap = 'b,s,<,>,[,]' -- allow left-right movement to next/prev line
o.autowrite = true
o.cmdheight = 2

-- %n      buffer number
-- %f      relative path of the filename
-- %m      modified flag
-- %r      read only flag
-- %y      filetype
-- %=      left/right separator
-- %v      virtual column numer
-- %l/%L   cursor line/total lines
-- %p%%    percent through file
o.statusline = '%n %f %m%r%y' .. '%=' .. '%v %l/%L %p%%'

opt.fillchars = { vert = ' ', diff = '─' }
opt.listchars = { tab = '│ ', trail = '·', extends = '…', nbsp = '‗' }

opt.isfname:remove { '=' } -- ignore = for file names (for completing in shell scripts)

o.hlsearch = false
o.undofile = true -- persistent undo
o.ignorecase = true
o.smartcase = true
o.list = true
o.pastetoggle = '<F10>'
o.scrolloff = 3
o.sidescrolloff = 2
o.timeoutlen = 500 -- mainly for which-key
opt.virtualedit = { 'block', 'onemore' }

kmap('n', '<leader>;', ':bp<cr>')
kmap('n', '<leader>.', ':bn<cr>')
kmap('n', '<leader>he', 'yypVr')
kmap('n', '<leader>v', ':e ~/.config/nixpkgs/configs/nvim/init.lua<cr>')
kmap('n', '<c-c>', '<esc>:set cursorline! cursorcolumn!<cr>', { silent = true })

kmap('n', '<f6>', ':number!<cr>')

kmap('n', '<leader>p', ':pu  +<cr>', { silent = true })
kmap('n', '<leader>P', ':pu! +<cr>', { silent = true })

kmap('n', '<Leader>s', ':setlocal spell! spelllang=en_us<CR>', { silent = true })

kmap('i', '<bs>', '<c-g>u<bs>')
kmap('i', '<cr>', '<c-g>u<cr>')
kmap('i', '<del>', '<c-g>u<del>')
kmap('i', '<c-w>', '<c-g>u<c-w>')

-- Don't use Ex mode, use Q for formatting
kmap({ 'n', 'v', 'o' }, 'Q', 'gq')

-- break a line in normal mode with ctrl-j
kmap('n', '<nl>', 'i<cr><esc>')

cmd [[autocmd TextYankPost * silent! lua vim.highlight.on_yank {timeout=300}]]
cmd [[autocmd BufEnter * silent! lcd %:p:h:gs/ /\\ /]]
-- see :he last-position-jump
cmd [[autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]]
cmd [[autocmd BufEnter *.nix setlocal tabstop=2 shiftwidth=2 softtabstop=2 commentstring=#\ %s]]
cmd [[autocmd BufEnter *.lua setlocal tabstop=2 shiftwidth=2 softtabstop=2]]
cmd [[autocmd BufEnter flake.lock setlocal filetype=json]]

require 'lspsetup'
require 'minisetup'
