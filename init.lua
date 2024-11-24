-- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
-- how  to make p, y, x, to copy-paste from system clipboard by default
vim.opt.clipboard = "unnamed"

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("t", "jk", "<C-\\><C-n>")

-- space leader pls
vim.g.mapleader = " "

require("lazy").setup({
	{ "lewis6991/gitsigns.nvim" },
	{ "sainnhe/gruvbox-material" },
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
	{ "nvim-telescope/telescope.nvim", tag = "0.1.5" },
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
			local deepseek_key = require("keys")

			-- overwriting the default openai config with our parameters
			require("model.providers.openai").initialize({
				model = "deepseek-coder",
				temperature = 0,
				max_tokens = 4000,
			})
			local deepseek = require("model.providers.openai")

			local prompts = require("prompts")
			local extract = require("model.prompts.extract")
			local mode = require("model").mode

			require("model").setup({
				default_prompt = {
					provider = deepseek,
					options = {
						url = "https://api.deepseek.com/v1",
						authorization = deepseek_key,
					},
					mode = mode.INSERT_OR_REPLACE,
					builder = function(input, context)
						return deepseek.adapt(prompts.code_replace_fewshot(input, context))
					end,
					transform = extract.markdown_code,
				},
			})
		end,
	},
	{
		'numToStr/Comment.nvim',
		opts = {
			-- add any options here
		}
	}
})

-- gruvbox
vim.cmd("colorscheme gruvbox-material")

-- tell vim-svelte-plugin to enable typescript syntax in svelte files
vim.g.vim_svelte_plugin_use_typescript = 1

-- format lua files
vim.keymap.set("n", "<leader>f", [[<cmd>lua require("stylua-nvim").format_file()<CR>]], opts)

-- requiring mason first because he told me to https://github.com/williamboman/mason-lspconfig.nvim
require("mason").setup()

local servers = {
	-- clangd = {},
	-- gopls = {},
	lua_ls = {},
	pyright = {},
	rust_analyzer = {},
	ts_ls = {},
	svelte = {
		svelte = {
			enableTsPlugin = true,
		},
	},
}

local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
	function(server_name)
		local lspconfig = require("lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		lspconfig[server_name].setup({
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				-- Your on_attach function here
			end,
			settings = servers[server_name],
		})
	end,
})

-- telescope shit!!!
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>fs", function()
	builtin.lsp_document_symbols({ symbols = "function" })
end, {})

-- cute fterm
vim.keymap.set({ "n", "t" }, "<Leader>i", '<CMD>lua require("FTerm").toggle()<CR>')

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Setup language servers.
local lspconfig = require("lspconfig")

local lspc_servers = vim.tbl_keys(servers)
for _, lsp in ipairs(lspc_servers) do
	lspconfig[lsp].setup({
		-- on_attach = my_custom_on_attach,
		capabilities = capabilities,
	})
end

-- setup cmp autocomplete
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
		["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
		-- C-b (back) C-f (forward) for snippet placeholder navigation.
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
	},
})

-- treesitter stuff
require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "rust", "gdscript" },
	highlight = {
		enable = true,
		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = true,
	},
})

-- Global mappings for vim LSP
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})

-- null-ls, the LSP thing for the prettier plugin
local null_ls = require("null-ls")

local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePost"

null_ls.setup({
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.keymap.set("n", "<Leader>f", function()
				vim.lsp.buf.format({
					bufnr = vim.api.nvim_get_current_buf(),
					filter = function(c)
						return c.name == "null-ls"
					end,
				})
			end, { buffer = bufnr, desc = "[lsp] format" })

			-- format on save
			vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
			vim.api.nvim_create_autocmd(event, {
				buffer = bufnr,
				group = group,
				callback = function()
					vim.lsp.buf.format({
						bufnr = vim.api.nvim_get_current_buf(),
						filter = function(c)
							return c.name == "null-ls"
						end,
					})
				end,
				desc = "[lsp] format on save",
			})
		end

		if client.supports_method("textDocument/rangeFormatting") then
			vim.keymap.set("x", "<Leader>f", function()
				vim.lsp.buf.format({
					bufnr = vim.api.nvim_get_current_buf(),
					filter = function(c)
						return c.name == "null-ls"
					end,
				})
			end, { buffer = bufnr, desc = "[lsp] format" })
		end
	end,
	sources = {
		null_ls.builtins.formatting.black,
	},
})

local prettier = require("prettier")

prettier.setup({
	bin = "prettierd", -- or `'prettierd'` (v0.23.3+)
	filetypes = {
		"css",
		"graphql",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"less",
		"markdown",
		"scss",
		"typescript",
		"typescriptreact",
		"yaml",
		"svelte",
		"lua",
	},
	cli_options = {
		arrow_parens = "always",
		bracket_spacing = true,
		bracket_same_line = false,
		embedded_language_formatting = "auto",
		end_of_line = "lf",
		html_whitespace_sensitivity = "css",
		-- jsx_bracket_same_line = false,
		jsx_single_quote = false,
		print_width = 80,
		prose_wrap = "preserve",
		quote_props = "as-needed",
		semi = true,
		single_attribute_per_line = false,
		single_quote = false,
		tab_width = 2,
		trailing_comma = "es5",
		use_tabs = false,
		vue_indent_script_and_style = false,
	},
})


require('gitsigns').setup()
require('Comment').setup()
