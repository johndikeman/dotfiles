-- greetd greeter Hyprland config (Lua) — launch regreet and exit when it's done
hl.on("hyprland.start", function()
	hl.exec_cmd("@regreet@; hyprctl dispatch exit")
end)

hl.config({
	-- Disable Hyprland branding and splash
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},

	-- Basic input settings
	input = {
		kb_layout = "us",
		follow_mouse = 1,
		touchpad = {
			natural_scroll = false,
		},
	},

	-- Window rules for regreet
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 0,
	},

	-- Disable animations for faster startup
	animations = {
		enabled = false,
	},
})

hl.monitor({ output = "HDMI-A-1", mode = "3840x2160", position = "0x0", scale = 1.5 })
