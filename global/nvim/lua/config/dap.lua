local dap = require("dap")

dap.adapters.gdb = {
    type = "executable",
    command = "/home/dvictoriano/.local/gdb-17.2/bin/gdb",
    args = {
        "--interpreter=dap",
    },
}

dap.configurations.c = {
    {
        name = "Launch C program",
        type = "gdb",
        request = "launch",

        program = function()
            return vim.fn.input(
                "Path to executable: ",
                vim.fn.getcwd() .. "/",
                "file"
            )
        end,

        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
}

vim.keymap.set("n", "<F5>", dap.continue)
vim.keymap.set("n", "<F9>", dap.toggle_breakpoint)
vim.keymap.set("n", "<F10>", dap.step_over)
vim.keymap.set("n", "<F11>", dap.step_into)
vim.keymap.set("n", "<F12>", dap.step_out)
