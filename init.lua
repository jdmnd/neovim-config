-- General
vim.o.shiftwidth = 2    -- Use indents of 2 spaces
vim.o.tabstop = 2       -- An indentation every 2 columns
vim.o.softtabstop = 2   -- Let backspace delete indent
vim.o.expandtab = true  -- always uses spaces instead of tab characters

vim.o.wrap = false      -- Don't wrap lines
vim.o.ignorecase = true -- Case insensitive search
vim.o.smartcase = true  -- Case sensitive search if there is a capital letter

vim.o.showmatch = true  -- Flash matching brackets

vim.o.splitright = true -- Open new splits to the right
vim.o.splitbelow = true -- Open new splits to the bottom

vim.o.list = true       -- Show invisible characters
vim.opt.listchars = {
  tab = '› ',
  trail = '•',
  extends = '…',
  precedes = '…',
  nbsp = '␣',
}

vim.opt.diffopt:append 'vertical'

vim.o.guifont = 'Source Code Pro:h15'

vim.o.backup = true
vim.o.undofile = true
vim.o.undolevels = 1000
vim.o.undoreload = 10000

do
  local parent = vim.fn.stdpath('data')
  local prefix = 'nvim'
  local dir_list = {
    backup = 'backupdir',
    views = 'viewdir',
    swap = 'directory',
    undo = 'undodir',
  }
  local common_dir = parent .. '/.' .. prefix
  for dirname, setting_name in pairs(dir_list) do
    local directory = common_dir .. dirname .. '/'
    if vim.fn.isdirectory(directory) ~= 1 then
      print('Creating directory: ' .. directory)
      vim.fn.mkdir(directory, 'p')
    end
    local directory = vim.fn.substitute(directory, ' ', '\\ ', 'g')
    vim.o[setting_name] = directory
  end
end

-- return cursor to first window (often NERDTree)
vim.keymap.set('n', '<leader><C-O>', '1<C-W>w')


-- loading NERDTree windows when restoring a session reports errors, so
-- let's disable storing empty windows in sessions
vim.opt.sessionoptions:remove 'blank'

-- an autocmd to save the session automatically before quitting
vim.api.nvim_create_autocmd('VimLeavePre', {
  desc = 'Save session before quitting',
  pattern = '*',
  callback = function()
    if vim.v.this_session ~= '' then
      vim.cmd('silent! mksession! ' .. vim.v.this_session)
    end
  end,
})


-- load a session automatically if there is one in the current directory
if vim.fn.argc() == 0 then
  vim.api.nvim_create_autocmd('VimEnter', {
    desc = 'Load default session if there is one',
    pattern = '*',
    callback = function()
      print('This session is ' .. vim.v.this_session)
      if vim.v.this_session == '' then
        if not pcall(vim.cmd, 'silent! source Session.vim') then
          print('Failed to load session from ' .. vim.v.this_session)
          vim.v.this_session = ''
        end
      end
    end,
    nested = true,
  })
end


vim.g.mapleader = ','  -- Leader key

-- Strip trailing whitespace
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Register StripTrailingWhitespace autocmd',
  pattern = 'c,cpp,elixir,go,h,haskell,java,javascript,lua,python,ruby,rust,sql,yaml,yml',
  group = vim.api.nvim_create_augroup('StripTrailingWhitespace', { clear = true }),
  callback = function(opts)
    vim.api.nvim_create_autocmd('BufWritePre', {
      desc = 'Call StripTrailingWhitespace on save',
      buffer = opts.buf,
      command = 'call StripTrailingWhitespace()',
    })
  end,
})

vim.cmd [[
  function! StripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endfunction
]]

vim.keymap.set('n', 'Y', 'y$') -- Yank to end of line

-- Disable search highlighting
vim.keymap.set('n', '<leader>/', ':nohlsearch<CR>')

-- Map H and L to move between buffers. Conflicts with ability to move to
-- bottom/top of screen, so first remap those to gh, gl.
vim.keymap.set('n', 'gh', '<S-H>')
vim.keymap.set('n', 'gl', '<S-L>')
vim.keymap.set('n', '<S-H>', ':bprev<CR>')
vim.keymap.set('n', '<S-L>', ':bnext<CR>')

-- Visual shifting (does not exit Visual mode)
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Allow using the repeat operator with a visual selection (!)
-- http://stackoverflow.com/a/8064607/127816
vim.keymap.set('v', '.', ':normal .<CR>')

-- Remap * to highlight the word under the cursor without moving to next result
vim.keymap.set('n', '*', 'mxHmz`x*`zzt`x')

-- Nerd tree file browser
vim.keymap.set('n', '<C-O>', ':NERDTreeToggle<CR>')
vim.keymap.set('n', '<C-H>', ':NERDTreeFind<CR>')

-- move between splits with ⌥+hjkl
vim.keymap.set('n', '∆', '<C-W><C-J>')
vim.keymap.set('n', '˚', '<C-W><C-K>')
vim.keymap.set('n', '¬', '<C-W><C-L>')
vim.keymap.set('n', '˙', '<C-W><C-H>')

-- iterate error list with ⌥+mb
vim.keymap.set('n', '∫', ':cprev<CR>')
vim.keymap.set('n', 'µ', ':cnext<CR>')

-- iterate jumplist forward/backward
vim.keymap.set('n', '<C-K>', '<C-O>')
vim.keymap.set('n', '<C-J>', '<C-I>')

-- Allow saving of files as sudo when I forgot to start vim using sudo.
-- cmap w!! w !sudo tee > /dev/null %
vim.keymap.set('c', 'w!!', 'w !sudo tee > /dev/null %')

-- write without losing position on line
vim.keymap.set('n', '<leader>w', ':silent write<CR>', { silent = true })

-- Tabularize align columns around a character
-- map <leader>t :Tab<CR>
vim.keymap.set('n', '<leader>t', ':Tab /<CR>')

-- fugitive
vim.keymap.set('n', '<leader>gw', ':Gwrite<CR>')
vim.keymap.set('n', '<leader>gr', ':Gread<CR>')
vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
vim.keymap.set('n', '<leader>gs', ':Git status<CR>')
vim.keymap.set('n', '<leader>gp', ':Git pull<CR>')
vim.keymap.set('n', '<leader>gP', ':Git push<CR>')

vim.keymap.set('n', '<leader>a', ':RG<CR>')
vim.keymap.set('n', '<leader>*', 'yiw:RG <C-r>"<CR>')
vim.keymap.set('v', '<leader>a', 'y:RG <C-r>"<CR>')


-- -- Package manager -- --
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Install packages
require("lazy").setup({
  -- {
  --   "ribru17/bamboo.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     -- require('bamboo').load()
  --   end,
  -- },
  -- {
  --   'AlexvZyl/nordic.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --       -- require 'nordic' .load()
  --   end
  -- },
  -- {
  --   'Domeee/mosel.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --       -- require 'mosel' .load()
  --   end
  -- },
  {
    'deparr/tairiki.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tairiki').load()
    end,
  },
  'scrooloose/nerdtree',
  'jiangmiao/auto-pairs',
  'tpope/vim-surround',
  'pangloss/vim-javascript',
  'mxw/vim-jsx',
  'othree/html5.vim',
  'github/copilot.vim',
  'tpope/vim-fugitive',
  'scrooloose/nerdcommenter',
  'godlygeek/tabular',
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    }
  },
}, {
  git = {
    url_format = "git@github.com:%s"
  }
})

-- telescope
do
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
  vim.keymap.set('n', '<C-p>', builtin.find_files, {})
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  vim.keymap.set('n', '<leader>a', builtin.git_files, {})
  vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

  require('telescope').setup {
    defaults = {
      mappings = {
        i = {
          ['<C-j>'] = 'move_selection_next',
          ['<C-k>'] = 'move_selection_previous',
        }
      }
    }
  }
end

-- treesitter
require'nvim-treesitter.configs'.setup {
  highlight = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<M-Up>",
      node_incremental = "<M-Up>",
      scope_incremental = "<M-Right>",
      node_decremental = "<M-Down>",
    }
  },
  textobjects = { enable = true },
}
