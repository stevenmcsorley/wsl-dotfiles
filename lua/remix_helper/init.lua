-- ~/.config/nvim/lua/remix_helper/init.lua

local M = {}

-- Require the snippets module
local snippets = require('remix_helper.snippets')

-- Filetype detection
vim.cmd([[
  augroup RemixFiletypes
    autocmd!
    autocmd BufRead,BufNewFile *.jsx set filetype=javascriptreact
    autocmd BufRead,BufNewFile *.tsx set filetype=typescriptreact
  augroup END
]])

-- Commands
vim.cmd([[
  command! RemixDev lua require('remix_helper').start_dev_server()
  command! RemixBuild lua require('remix_helper').build_project()
  command! RemixStop lua require('remix_helper').stop_dev_server()
  command! -nargs=+ NewRoute lua require('remix_helper').new_route(<f-args>)
]])

function M.new_route(name, type)
  local route_file = "app/routes/" .. name .. ".tsx"
  
  -- Handle Index Route (_index.tsx)
  if name == "index" or name == "_index" then
    route_file = "app/routes/_index.tsx"
  end

  -- Handle Nested Routes using dot delimiters (e.g., concerts.trending.tsx)
  if string.match(name, "%.") and not string.match(name, "%[%.%]") then
    route_file = "app/routes/" .. name:gsub("%.", "/") .. ".tsx"
  end

  -- Handle Dynamic Routes with $ (e.g., concerts.$city.tsx)
  if string.match(name, "%$") then
    route_file = "app/routes/" .. name:gsub("%$", "$") .. ".tsx"
  end

  -- Handle Optional Routes with parentheses (e.g., ($lang).categories.tsx)
  if string.match(name, "%(") then
    route_file = "app/routes/" .. name .. ".tsx"
  end

  -- Handle Splat Routes with $ (e.g., files.$.tsx)
  if name == "$" or string.match(name, "%$") then
    route_file = "app/routes/" .. name .. ".tsx"
  end

  -- Handle Escaped Routes (e.g., sitemap[.]xml.tsx)
  if string.match(name, "%[%.%]") then
    route_file = "app/routes/" .. name:gsub("%[%.%]", ".") .. ".tsx"
  end

  -- Handle Pathless Routes with leading underscore (_auth.tsx)
  if string.match(name, "^_") then
    route_file = "app/routes/" .. name .. ".tsx"
  end

  -- Check if route already exists
  if vim.fn.filereadable(route_file) == 1 then
    print("Route already exists!")
    return
  end

  -- Ensure that the directory structure exists
  local route_dir = route_file:match("(.*/)")
  vim.fn.mkdir(route_dir, "p") -- 'p' ensures that parent directories are created

  -- Try to open the file for writing
  local f, err = io.open(route_file, 'w')
  if not f then
    print("Failed to create route file: " .. err)
    return
  end

  -- Base route content for any type of route
  local content = [[
export default function ]] .. name:gsub("^%l", string.upper) .. [[Page() {
  return (
    <div>
      <h1>]] .. name:gsub("^%l", string.upper) .. [[ Page</h1>
    </div>
  );
}
]]

  -- Write the content to the file
  f:write(content)
  f:close()

  -- Open the newly created route in the editor
  vim.cmd('edit ' .. route_file)
  print("New route created: " .. route_file)
end-- Function to start the dev server
function M.start_dev_server()
  vim.cmd('split | terminal npm run dev')
  vim.cmd('startinsert')
end

-- Function to build the project
function M.build_project()
  vim.cmd('split | terminal npm run build')
  vim.cmd('startinsert')
end

-- Function to stop the dev server
function M.stop_dev_server()
  -- Close the last terminal window opened
  vim.cmd('silent! bd! term://*')
  print('Terminal windows closed.')
end

-- Go to the loader file for the current route
function M.goto_loader()
  local current_file = vim.fn.expand('%:p')
  local loader_file = current_file:gsub('%.tsx$', '.loader.ts')
  if vim.fn.filereadable(loader_file) == 1 then
    vim.cmd('edit ' .. loader_file)
  else
    -- Create the loader file and add boilerplate code
    local f = io.open(loader_file, 'w')
    f:write([[
import { LoaderFunction } from "@remix-run/node";

export const loader: LoaderFunction = async () => {
  return null;
};
    ]])
    f:close()
    vim.cmd('edit ' .. loader_file)
  end
end

-- Keybindings
vim.api.nvim_set_keymap('n', '<Leader>gl', ':lua require("remix_helper").goto_loader()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>rd', ':RemixDev<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>ks', ':RemixStop<CR>', { noremap = true, silent = true })

-- Return module
return M
