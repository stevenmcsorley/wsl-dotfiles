local M = {}

function M.setup_git_blame_preview()
  local blame_buf = vim.api.nvim_get_current_buf()
  local blame_win = vim.api.nvim_get_current_win()

  -- Create a preview window
  vim.cmd('vsplit')
  local preview_win = vim.api.nvim_get_current_win()
  local preview_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(preview_win, preview_buf)

  -- Function to update preview
  local function update_preview()
    local line = vim.api.nvim_win_get_cursor(blame_win)[1]
    local blame_line = vim.api.nvim_buf_get_lines(blame_buf, line - 1, line, false)[1]
    local hash = blame_line:match('^(%x+)')
    if hash and #hash > 7 then
      local temp_file = vim.fn.tempname()
      vim.fn.system('git show ' .. hash .. ':' .. vim.fn.expand('%:t') .. ' > ' .. temp_file)
      vim.api.nvim_buf_set_option(preview_buf, 'buftype', 'nofile')
      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, vim.fn.readfile(temp_file))
      vim.api.nvim_win_set_cursor(preview_win, {line, 0})
      os.remove(temp_file)
    end
  end

  -- Set up keymaps for navigation
  local opts = {noremap = true, silent = true}
  vim.api.nvim_buf_set_keymap(blame_buf, 'n', 'j', ':lua vim.api.nvim_win_set_cursor(0, {vim.api.nvim_win_get_cursor(0)[1] + 1, 0})<CR>', opts)
  vim.api.nvim_buf_set_keymap(blame_buf, 'n', 'k', ':lua vim.api.nvim_win_set_cursor(0, {vim.api.nvim_win_get_cursor(0)[1] - 1, 0})<CR>', opts)
  vim.api.nvim_buf_set_keymap(blame_buf, 'n', 'q', ':bdelete!<CR>:quit<CR>', opts)

  -- Set up autocommand for cursor movement
  vim.cmd([[
    augroup GitBlamePreview
      autocmd!
      autocmd CursorMoved <buffer> lua vim.schedule(function() require('git_blame').update_preview() end)
    augroup END
  ]])

  -- Initial update
  update_preview()

  -- Store update_preview in the module
  M.update_preview = update_preview
end

return M
