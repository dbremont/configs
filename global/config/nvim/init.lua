require("timestamped_notes").setup()

-------------------------------------------------------------------------------
--
-- plugin configuration
--
-------------------------------------------------------------------------------

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
			require("lspconfig").bashls.setup({})
		end
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
						select = true
					}),
				},

				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end
	},

	--------------------------------------------------------------------------
	-- Treesitter
	--------------------------------------------------------------------------

	{
		"nvim-treesitter/nvim-treesitter",

		build = ":TSUpdate",

		event = { "BufReadPost", "BufNewFile" },

		config = function()

			require("nvim-treesitter.configs").setup({

				highlight = {
					enable = true,
				},

				indent = {
					enable = true,
				},

				ensure_installed = {
					"bash",
					"lua",
					"json",
					"yaml",
					"markdown",
				},
			})

			------------------------------------------------------------------
			-- PRS parser registration
			------------------------------------------------------------------

			local parser_config =
				require("nvim-treesitter.parsers")
				.get_parser_configs()

			parser_config.prs = {

				install_info = {
					url = "~/Code/prs",
					files = { "src/parser.c" },
					branch = "main",
				},

				filetype = "prs",
			}

			------------------------------------------------------------------
			-- .prs filetype detection
			------------------------------------------------------------------

			vim.filetype.add({
				extension = {
					prs = "prs",
				},
			})
		end,
	},
})
