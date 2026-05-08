return {
	{ "lewis6991/gitsigns.nvim", opts = {} },
	{ "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = { contrast = "hard" } },

	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },

		-- example using `opts` for defining servers
		opts = {
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								library = (function()
									local lib = vim.api.nvim_get_runtime_file("", true)
									local filtered_lib = {}
									for _, path in ipairs(lib) do
										-- Check if the path contains the plugin name you want to skip
										if not path:find("milli.nvim") then
											table.insert(filtered_lib, path)
										end
									end
									return filtered_lib
								end)(),
								ignoreDir = { "milli.nvim" },
							},
						},
					},
				},
				pyright = {},
				rust_analyzer = {},
				ts_ls = {},
				svelte = {
					svelte = {
						enableTsPlugin = true,
					},
				},
				nixd = { { nixd = { formatting = { command = { "nixfmt" } } } } },
				gdscript = {},
			},
		},
		config = function(_, opts)
			local bcmp = require("blink.cmp")
			for server, config in pairs(opts.servers) do
				-- passing config.capabilities to blink.cmp merges with the capabilities in your
				-- `opts[server].capabilities, if you've defined it
				config.capabilities = bcmp.get_lsp_capabilities(config.capabilities)
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
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
			keymap = { preset = "super-tab" },

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 100 },
				ghost_text = { enabled = true },
			},

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
			pickers = {
				buffers = {
					sort_lastused = true,
				},
			},
			dependencies = { "nvim-treesitter/nvim-treesitter" },
		},
	},
	{ "ckipp01/stylua-nvim" },
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
				typescript = { "prettierd", "prettier", stop_after_first = true },
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
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
			{ "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit Current File" },
		},
	},
	{ "tpope/vim-fugitive" },
	{ "nvim-tree/nvim-web-devicons", opts = { default = true } },
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		opts = function()
			local splash = require("milli").load({ splash = "vibecattwo" })
			return {
				theme = "hyper",
				config = {
					header = splash.frames[1], -- seed header with frame 0
					shortcut = {
						{
							icon = "󱣀",
							icon_hl = "@variable",
							desc = "workspaces",
							group = "Label",
							action = "Telescope workspaces",
							key = "w",
						},
					},
					change_to_vcs_root = true,
				},
			}
		end,
		config = function(_, opts)
			require("dashboard").setup(opts)
			require("milli").dashboard({ splash = "vibecattwo", loop = true })
		end,
		dependencies = { "nvim-tree/nvim-web-devicons", "amansingh-afk/milli.nvim" },
	},
	{ "amansingh-afk/milli.nvim", lazy = false },
	{ "rcarriga/nvim-notify" },
	{ "MunifTanjim/nui.nvim" },
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},
}
