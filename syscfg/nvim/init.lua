-- ========================================================================== --
--                          EDITOR CONFIGURATION                              --
-- ========================================================================== --
local option = vim.opt

option.number = true
option.relativenumber = true
option.ignorecase = true
option.smartcase = true
option.hlsearch = false
option.wrap = true
option.breakindent = true
option.tabstop = 2
option.shiftwidth = 2
option.expandtab = false
option.cursorline = true
option.splitbelow = true
option.splitright = true
option.clipboard = "unnamedplus"
option.termguicolors = true

-- VS Code-like completion behavior
-- menuone: popup even if there's only one match
-- noselect: don't force-select the first item (let you keep typing)
option.completeopt = { "menu", "menuone", "noselect" }

-- ========================================================================== --
--                          PLUGIN MANAGER (lazy.nvim)                         --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
--                               PLUGINS                                      --
-- ========================================================================== --
require("lazy").setup({
  spec = {
    -- 1. Autopairs: Auto-close brackets () [] {}
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      config = true
    },

		-- 2. Vague: Colorscheme
    {'vague-theme/vague.nvim', lazy = false, priority = 1000, 
    config = function()
      vim.cmd([[colorscheme vague]])
    end,
    },

    -- 3. Mini.Completion: Lightweight VS Code-like autocomplete
    {
      'echasnovski/mini.completion',
      version = false,
      config = function()
        require('mini.completion').setup({
          window = {
            completion = { border = 'rounded', winblend = 10 },
            info = { border = 'rounded', winblend = 10 },
          },
          -- 50ms delay for a snappy VS Code feel
          delay = { completion = 50, info = 50 },
        })

        -- Keybindings for VS Code behavior
        local imap_expr = function(lhs, rhs)
          vim.keymap.set('i', lhs, rhs, { expr = true, replace_keycodes = false })
        end

        -- Use Tab to go down, Shift-Tab to go up
        imap_expr('<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
        imap_expr('<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])
        
        -- Use Enter to confirm the selection (and not create a new line)
        imap_expr('<CR>',    [[pumvisible() ? "\<C-y>" : "\<CR>"]])
      end
    },

  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})
