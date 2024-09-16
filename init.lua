-- Add the correct runtime path for Packer
vim.o.runtimepath = vim.o.runtimepath .. ',' .. vim.fn.expand('$LOCALAPPDATA') .. '/nvim-data/site'

-- Load Packer
vim.cmd [[packadd packer.nvim]]

-- Packer plugin manager setup
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'        -- Packer can manage itself
  use 'neovim/nvim-lspconfig'         -- Collection of configurations for built-in LSP client
  use 'hrsh7th/nvim-cmp'              -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'          -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip'      -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip'              -- Snippets plugin
  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-tree/nvim-tree.lua'
  use 'nvim-lualine/lualine.nvim'
  use 'lewis6991/gitsigns.nvim'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use 'numToStr/Comment.nvim'
  use { "catppuccin/nvim", as = "catppuccin" }
  -- use 'nvim-tree/nvim-web-devicons'
  use 'DaikyXendo/nvim-material-icon'
  use 'tpope/vim-fugitive'
  use 'github/copilot.vim'
  use 'ThePrimeagen/harpoon'
  use 'mbbill/undotree'
  use 'jose-elias-alvarez/null-ls.nvim'     -- Null-ls for formatting
  use 'MunifTanjim/prettier.nvim'           -- Prettier plugin
end)

-- Basic settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.wrap = false
vim.o.clipboard = 'unnamedplus'
vim.o.termguicolors = true

-- Key mappings
vim.g.mapleader = ' '
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- LSP settings
local lspconfig = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  -- buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'ts_ls' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- nvim-cmp setup
local cmp = require('cmp')
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
}

-- Treesitter configuration
require('nvim-treesitter.configs').setup {
  ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript", "python" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  },
}

-- Nvim-tree setup
require('nvim-tree').setup({
  view = {
    width = 30,
    side = 'right',
  },
})

-- Lualine setup
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
  },
}

-- Harpoon setup
require('harpoon').setup({
  global_settings = {
    save_on_toggle = false,
    save_on_change = true,
    enter_on_sendcmd = false,
    tmux_autoclose_windows = false,
    excluded_filetypes = { 'harpoon' },
    mark_branch = false,
  }
})

-- Enable persistent undo
vim.opt.undofile = true

-- Set the directory where undo files are stored
local undodir = vim.fn.stdpath('config') .. '/undodir'

-- Create the directory if it doesn't exist
if not vim.fn.isdirectory(undodir) then
  vim.fn.mkdir(undodir, 'p')
end

vim.opt.undodir = undodir

-- Key mappings for Harpoon
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Add file to Harpoon
map('n', '<leader>a', ":lua require('harpoon.mark').add_file()<CR>", opts)

-- Toggle Harpoon quick menu
map('n', '<leader>h', ":lua require('harpoon.ui').toggle_quick_menu()<CR>", opts)

-- Navigate to Harpoon marks
map('n', '<leader>1', ":lua require('harpoon.ui').nav_file(1)<CR>", opts)
map('n', '<leader>2', ":lua require('harpoon.ui').nav_file(2)<CR>", opts)
map('n', '<leader>3', ":lua require('harpoon.ui').nav_file(3)<CR>", opts)
map('n', '<leader>4', ":lua require('harpoon.ui').nav_file(4)<CR>", opts)

-- Cycle through Harpoon marks
map('n', '<C-n>', ":lua require('harpoon.ui').nav_next()<CR>", opts)
map('n', '<C-p>', ":lua require('harpoon.ui').nav_prev()<CR>", opts)


-- Key mapping for Undotree
vim.api.nvim_set_keymap('n', '<leader>u', ':UndotreeToggle<CR>', { noremap = true, silent = true })



-- Gitsigns setup
require('gitsigns').setup()

-- Key mappings for Gitsigns
vim.api.nvim_set_keymap('n', '<leader>sh', ':Gitsigns toggle_signs<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sj', ':Gitsigns next_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sk', ':Gitsigns preview_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>si', ':Gitsigns preview_hunk_inline<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sr', ':Gitsigns reset_hunk<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sp', ':Gitsigns preview_hunk<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sb', ':Gitsigns blame_line<CR>', { noremap = true, silent = true })



-- Telescope setup
local telescope = require('telescope')
telescope.setup{}
-- Telescope keymaps
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true })

-- Telescope mappings for Quickfix list
-- Search and populate Quickfix list
map('n', '<leader>fs', ":lua require('telescope.builtin').grep_string()<CR>", opts)

-- Search for a string and send results to Quickfix list
map('n', '<leader>fgq', ":lua require('telescope.builtin').live_grep({qflist = true})<CR>", opts)

-- List Quickfix entries using Telescope
map('n', '<leader>fq', ":lua require('telescope.builtin').quickfix()<CR>", opts)




-- Telescope extension for Harpoon
require('telescope').load_extension('harpoon')

-- Find Harpoon marks using Telescope
map('n', '<leader>fm', ":Telescope harpoon marks<CR>", opts)


--  -- Fugitive key mappings
vim.api.nvim_set_keymap('n', '<leader>gs', ':Git<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gc', ':Git commit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gp', ':Git push<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gl', ':Git log<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gd', ':Gdiffsplit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gb', ':Git blame<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gB', ':GBrowse<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gr', ':Gread<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gw', ':Gwrite<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ge', ':Gedit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gm', ':GMove<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gx', ':GDelete<CR>', { noremap = true, silent = true })
-- 0Gclog keymap
vim.api.nvim_set_keymap('n', '<leader>tt', ':Gclog<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>p', '"+p', { noremap = true, silent = true })


-- Open the Quickfix list
map('n', '<leader>q', ':copen<CR>', opts)

-- Close the Quickfix list
map('n', '<leader>qc', ':cclose<CR>', opts)

-- Navigate to the next item in the Quickfix list
map('n', ']q', ':cnext<CR>', opts)

-- Navigate to the previous item in the Quickfix list
map('n', '[q', ':cprev<CR>', opts)

-- Navigate to the first item in the Quickfix list
map('n', '<leader>qq', ':cfirst<CR>', opts)

-- Navigate to the last item in the Quickfix list
map('n', '<leader>ql', ':clast<CR>', opts)

-- Remove all entries from the Quickfix list
map('n', '<leader>qr', ':call setqflist([])<CR>', opts)


-- diffget left and right mappings
vim.api.nvim_set_keymap('n', '<leader>gl', ':diffget //3<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gr', ':diffget //2<CR>', { noremap = true, silent = true })

-- Comment.nvim setup
require('Comment').setup()
require('remix_helper')


-- Prettier setup
local prettier = require("prettier")

prettier.setup({
  bin = 'prettier', -- or 'prettierd' if you have it installed
  filetypes = {
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "scss",
    "typescript",
    "typescriptreact",
    "yaml",
  },
})

-- Null-ls setup for Prettier integration
local null_ls = require("null-ls")
local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- Event to format before saving
local async = event == "BufWritePost"

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier, -- Add prettier as a formatter
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      -- Keymap to manually trigger formatting
      vim.keymap.set("n", "<Leader>f", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })

      -- Auto format on save
      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      vim.api.nvim_create_autocmd(event, {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, async = async })
        end,
        desc = "[lsp] format on save",
      })
    end
  end,
})


-- Set colorscheme
vim.cmd[[colorscheme catppuccin-mocha]]



