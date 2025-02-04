local M = {}

M.insert_timestamp = function()
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local line = "- [ ] [" .. timestamp .. "] : <name>"
  
  -- Insert at the top of the file (line 1)
  vim.api.nvim_buf_set_lines(0, 0, 0, false, { line })

  vim.cmd("write")
end

M.setup = function()
  vim.cmd("command! InsertTimestamp lua require('timestamped_notes').insert_timestamp()")
  vim.api.nvim_set_keymap("n", "<leader>ts", ":InsertTimestamp<CR>", { noremap = true, silent = true })
end

return M