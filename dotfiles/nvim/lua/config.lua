
-- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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

vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")

-- tell vim-svelte-plugin to enable typescript syntax in svelte files
vim.g.vim_svelte_plugin_use_typescript = 1

-- format lua files
vim.keymap.set("n", "<leader>f", [[<cmd>lua require("stylua-nvim").format_file()<CR>]], opts)

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
	nil_ls = { ['nil'] = { formatting = { command = { "nixfmt" } } } }
}

-- cute fterm
vim.keymap.set({ "n", "t" }, "<Leader>i", '<CMD>lua require("FTerm").toggle()<CR>')

-- treesitter stuff
local parser_install_dir = vim.fn.stdpath("cache") .. "/treesitters"
vim.fn.mkdir(parser_install_dir, "p")
vim.opt.runtimepath:append(parser_install_dir)

-- telescope shit!!!
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>fs", builtin.treesitter, {})

local telescope = require("telescope")
telescope.load_extension("workspaces")
vim.keymap.set("n", "<leader>fw", require("telescope").extensions.workspaces.workspaces, {})

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
