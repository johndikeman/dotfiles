return {
	"olimorris/codecompanion.nvim",
	opts = {
		adapters = {
			deepseek = function()
				return require("codecompanion.adapters").extend("deepseek", {
					env = {
						api_key = function(adapter)
							return require("keys").DEEPSEEK
						end,
					},
				})
			end,
			gemini = function()
				return require("codecompanion.adapters").extend("gemini-vai", {
					env = {
						api_key = function(adapter)
							return require("keys").GEMINI
						end,
					},
				})
			end,
		},
		strategies = {
			chat = {
				adapter = "gemini",
			},
			inline = {
				adapter = "gemini",
			},
			cmd = {
				adapter = "gemini",
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
}
