return {
	"olimorris/codecompanion.nvim",
	opts = {
		adapters = {
			deepseek = function()
				return require("codecompanion.adapters").extend("deepseek", {
					env = {
						api_key = function(adapter)
							return require("keys")
						end,
					},
				})
			end,
		},
		strategies = {
			chat = {
				adapter = "deepseek",
			},
			inline = {
				adapter = "deepseek",
			},
			cmd = {
				adapter = "deepseek",
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
}
