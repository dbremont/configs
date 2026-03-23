-- floating_menu.lua

local M = {}

M.show_menu = function()
    local buf = vim.api.nvim_create_buf(false, true)
    local opts = {
        relative = "cursor",
        row = 1,
        col = 0,
        width = 30,
        height = 5,
        style = "minimal",
        border = "rounded",
    }

    local win = vim.api.nvim_open_win(buf, true, opts)
    local items = { "apple", "banana", "cherry", "date", "elderberry" }
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, items)

    local current = 0

    local function update_highlight()
        vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Visual", current, 0, -1)
    end

    vim.api.nvim_buf_set_keymap(buf, "n", "<C-n>", "", {
        noremap = true,
        callback = function()
            current = (current + 1) % #items
            update_highlight()
        end,
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "<C-p>", "", {
        noremap = true,
        callback = function()
            current = (current - 1 + #items) % #items
            update_highlight()
        end,
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
        noremap = true,
        callback = function()
            print("Selected: " .. items[current + 1])
            vim.api.nvim_win_close(win, true)
        end,
    })

    update_highlight()
end

return M
