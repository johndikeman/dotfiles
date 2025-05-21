return {
	"olimorris/codecompanion.nvim",
	opts = {
		adapters = {
			deepseek = function()
				return require("codecompanion.adapters").extend("anthropic", {
					env = { api_key = require("keys") },
				})
			end,
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
}
