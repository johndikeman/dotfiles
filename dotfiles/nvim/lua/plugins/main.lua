return {
	{ "lewis6991/gitsigns.nvim", opts = {} },
	{ "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = { contrast = "hard" } },
	{ "numToStr/FTerm.nvim" },
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },

		-- example using `opts` for defining servers
		opts = {
			servers = {
				lua_ls = {},
				pyright = {},
				rust_analyzer = {},
				ts_ls = {},
				svelte = {
					svelte = {
						enableTsPlugin = true,
					},
				},
				nil_ls = { ["nil"] = { formatting = { command = { "nixfmt" } } } },
				gdscript = {},
			},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			for server, config in pairs(opts.servers) do
				-- passing config.capabilities to blink.cmp merges with the capabilities in your
				-- `opts[server].capabilities, if you've defined it
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				lspconfig[server].setup(config)
			end
		end,
	},
	{ "mrcjkb/rustaceanvim" }, -- configuring LSP for rust
	{
		"saghen/blink.cmp",

		-- use a release tag to download pre-built binaries
		version = "1.*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = { preset = "enter" },

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			-- (Default) Only show the documentation popup when manually triggered
			completion = { documentation = { auto_show = false } },

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
				"python",
				"rust",
				"gdscript",
				"svelte",
				"typescript",
				"javascript",
				"css",
			},
			highlight = {
				enable = true,
				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = true,
			},
		},
	},
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
	{
		"nvim-telescope/telescope.nvim",
		opts = {
			extensions = {
				workspaces = {
					-- keep insert mode after selection in the picker, default is false
					keep_insert = true,
					-- Highlight group used for the path in the picker, default is "String"
					path_hl = "String",
				},
			},
		},
	},
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
			{ "<C-m>d", ":Mdelete<cr>", mode = "n" },
			{ "<C-m>s", ":Mselect<cr>", mode = "n" },
			{ "<C-m><space>", ":Mchat<cr>", mode = "n" },
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
						show_reasoning = true,
					},
					params = {
						model = "deepseek-reasoner",
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
					end,
				},
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		opts = {
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		},
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		opts = {
			enable_autocmd = false,
		},
	},
	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		opts = {
			-- whether to map keybinds or not. default true
			default_mappings = false,
			-- which builtin marks to show. default {}
			builtin_marks = { ".", "<", ">", "^" },
			-- whether movements cycle back to the beginning/end of buffer. default true
			cyclic = true,
			-- whether the shada file is updated after modifying uppercase marks. default false
			force_write_shada = false,
			-- how often (in ms) to redraw signs/recompute mark positions.
			-- higher values will have better performance but may cause visual lag,
			-- while lower values may cause performance penalties. default 150.
			refresh_interval = 250,
			-- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
			-- marks, and bookmarks.
			-- can be either a table with all/none of the keys, or a single number, in which case
			-- the priority applies to all marks.
			-- default 10.
			sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
			-- disables mark tracking for specific filetypes. default {}
			excluded_filetypes = {},
			-- disables mark tracking for specific buftypes. default {}
			excluded_buftypes = {},
			-- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
			-- sign/virttext. Bookmarks can be used to group together positions and quickly move
			-- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
			-- default virt_text is "".
			bookmark_0 = {
				sign = "☭",
				virt_text = "yo",
				-- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
				-- defaults to false.
				annotate = true,
			},
			mappings = {
				next_bookmark0 = "mn",
				prev_bookmark0 = "mN",
				set_bookmark0 = "mm",
				delete_bookmark = "dm",
				delete_bookmark0 = "dma",
			},
		},
	},
	{
		"natecraddock/workspaces.nvim",
		tag = "1.0",
		opts = {

			auto_open = false,
			hooks = {
				add = {},
				remove = {},
				rename = {},
				open_pre = {},
				open = { "Telescope find_files" },
			},
		},
	},
	{
		"stevearc/conform.nvim",
		log_level = vim.log.levels.DEBUG,
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- Customize or remove this keymap to your liking
				"<leader>f",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		-- This will provide type hinting with LuaLS
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				svelte = { "prettierd", "prettier", stop_after_first = true },
				nix = { "nixfmt" },
			},
			-- Set default options
			default_format_opts = {},
			-- Set up format-on-save
			format_on_save = { timeout_ms = 500 },
			-- Customize formatters
			formatters = {
				nixfmt = { command = "nixfmt" },
				shfmt = {
					prepend_args = { "-i", "2" },
				},
			},
		},
		init = function()
			-- If you want the formatexpr, here is the place to set it
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
