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
	    lazy = false,
	    priority = 1000,   -- load very early
	    config = function()
	        -- Delay the setup until after lazy.nvim has processed everything
	        vim.defer_fn(function()
	            -- Ensure the plugin is actually loaded (safety check)
	            local ok, configs = pcall(require, "nvim-treesitter.configs")
	            if not ok then
	                vim.notify("nvim-treesitter not loaded yet, retrying...", vim.log.levels.WARN)
	                return
	            end
	
	            -- Standard setup
	            configs.setup({
	                ensure_installed = { "bash", "lua", "json", "yaml", "markdown" },
	                highlight = { enable = true },
	                indent = { enable = true },
	            })
	
	            -- Register custom parser safely
	            vim.filetype.add({ extension = { prs = "prs" } })
	            local parsers = require("nvim-treesitter.parsers")
	            if not parsers.parsers then
	                parsers.parsers = {}
	            end
	            parsers.parsers.prs = {
	                install_info = {
	                    url = "~/Code/prs",
	                    files = { "src/parser.c" },
	                    branch = "main",
	                    generate_requires_npm = false,
	                    requires_generate_from_grammar = false,
	                },
	                filetype = "prs",
	            }
	            vim.treesitter.language.register("prs", "prs")
	        end, 100)   -- wait 100ms after startup
	    end,
	},
})
