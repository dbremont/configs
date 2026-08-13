-------------------------------------------------------------------------------
--
-- plugin configuration
--
-------------------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("x", "<A-j>", ":m '>+1<CR>gv")
vim.keymap.set("x", "<A-k>", ":m '<-2<CR>gv")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

	--------------------------------------------------------------------------
	-- LSP
	--------------------------------------------------------------------------

	{
		"neovim/nvim-lspconfig",

		config = function()
			vim.lsp.config("bashls", {})
			vim.lsp.enable("bashls")
		end,
	},

	--------------------------------------------------------------------------
	-- Completion
	--------------------------------------------------------------------------

	{
		"hrsh7th/nvim-cmp",

		event = "InsertEnter",

		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},

		config = function()
			local cmp = require("cmp")

			cmp.setup({
				mapping = {
					["<C-Space>"] = cmp.mapping.complete(),

					["<CR>"] = cmp.mapping.confirm({
						select = true,
					}),
				},

				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},

	--------------------------------------------------------------------------
	-- DAP
	--------------------------------------------------------------------------

	{
		"mfussenegger/nvim-dap",

		config = function()
			require("config.dap")
		end,
	},

	--------------------------------------------------------------------------
	-- Telescope
	--------------------------------------------------------------------------

	{
		"nvim-telescope/telescope.nvim",

		dependencies = {
			"nvim-lua/plenary.nvim",
		},

		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				defaults = {
					layout_strategy = "horizontal",

					layout_config = {
						width = 0.9,
						height = 0.9,
						preview_width = 0.5,
					},

					preview = {
						hide_on_startup = false,
					},
				},
			})

			vim.keymap.set(
				"n",
				"<leader>ff",
				builtin.find_files,
				{ desc = "Find files" }
			)

			vim.keymap.set(
				"n",
				"<leader>fg",
				builtin.live_grep,
				{ desc = "Live grep" }
			)
		end,
	},

})
