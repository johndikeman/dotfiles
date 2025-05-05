return {
	{ "lewis6991/gitsigns.nvim" },
	{ "ellisonleao/gruvbox.nvim",         priority = 1000,  config = true, opts = {contrast = "hard"}},
	{ "numToStr/FTerm.nvim" },
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "neovim/nvim-lspconfig" },
	{ "hrsh7th/cmp-nvim-lsp" }, -- LSP source for nvim-cmp
	{ "mrcjkb/rustaceanvim" }, -- configuring LSP for rust
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "hrsh7th/nvim-cmp" }, -- autocomplete
	{ "hrsh7th/cmp-vsnip" },
	{ "hrsh7th/vim-vsnip" },
	{ "nvim-treesitter/nvim-treesitter" },
	{ "jose-elias-alvarez/null-ls.nvim" }, -- some lsp thing for prettier plugin to work
	{ "MunifTanjim/prettier.nvim" },
	{ "nvim-lua/plenary.nvim" },
	{ "folke/lsp-colors.nvim" },
	{
		"folke/trouble.nvim",
		tag = "v3.6.0",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{ "leafOfTree/vim-svelte-plugin" },
	{ "nvim-telescope/telescope.nvim", tag = "0.1.8" },
	{ "ckipp01/stylua-nvim" },

	{
		"gsuuon/model.nvim",

		-- Don't need these if lazy = false
		cmd = { "M", "Model", "Mchat" },
		init = function()
			vim.filetype.add({
				extension = {
					mchat = "mchat",
				},
			})
		end,
		ft = "mchat",

		keys = {
			{ "<C-m>d",       ":Mdelete<cr>", mode = "n" },
			{ "<C-m>s",       ":Mselect<cr>", mode = "n" },
			{ "<C-m><space>", ":Mchat<cr>",   mode = "n" },
		},

		config = function()
			local deepseek = require("model.providers.deepseek")
			local prompts = require("prompts")
			local extract = require("model.prompts.extract")
			local chat_prompts = require("model.prompts.chats")
			local mode = require("model").mode

			require("model").setup({
				default_prompt = {
					provider = deepseek,
					options = {
						show_reasoning = true
					},
					params = {
						model = "deepseek-reasoner"
					},
					mode = mode.INSERT_OR_REPLACE,
					builder = function(input, context)
						return prompts.code_replace_fewshot(input, context)
					end,
					transform = extract.markdown_code,
				},
				chats = chat_prompts,
				secrets = {
					DEEPSEEK_API_KEY = function()
						return require("keys")
					end
				}
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		opts = {
			-- add any options here
		},
	},
	{ "JoosepAlviste/nvim-ts-context-commentstring" },
	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"natecraddock/workspaces.nvim",
		tag = "1.0",
	},
}
