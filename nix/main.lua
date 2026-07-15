local colors = require("colors")
local mod = "SUPER"

hl.config({
	debug = {
		disable_logs = false,
	},
	xwayland = {
		force_zero_scaling = true,
	},
	general = {
		gaps_in = 2,
		gaps_out = 4,
		border_size = 1,
		col = {
			active_border = {
				colors = { "rgba(" .. colors.base08 .. "ee)", "rgba(" .. colors.base09 .. "ee)" },
				angle = 45,
			},
			inactive_border = "rgba(" .. colors.base03 .. "aa)",
		},
		layout = "dwindle",
	},
	decoration = {
		rounding = 5,
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
		},
	},
	input = {
		kb_layout = "us",
		follow_mouse = 1,
		touchpad = {
			natural_scroll = true,
			clickfinger_behavior = true,
		},
		sensitivity = -0.2,
		accel_profile = "adaptive",
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
})

-- Animations
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- Gestures
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Autostart
hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user start hyprland-session.target")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("waybar")
	hl.exec_cmd("dunst")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("/usr/libexec/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("swww-randomize.sh @wallpapers@")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

hl.on("hyprland.shutdown", function()
	os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
end)

-- Binds
hl.bind(mod .. " + space", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mod .. " + p", hl.dsp.window.pseudo())
hl.bind(mod .. " + SHIFT + f", hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(mod .. " + SHIFT + o", hl.dsp.exec_cmd("firefox-history.sh"))

-- Global copy-paste
hl.bind(mod .. " + c", hl.dsp.exec_cmd("modcopypaste.sh copy kitty"))
hl.bind(mod .. " + v", hl.dsp.exec_cmd("modcopypaste.sh paste kitty"))

-- MacOS-esque bindings
local macos_binds = {
	a = "a",
	f = "f",
	r = "r",
	t = "t",
	w = "w",
}

for k, v in pairs(macos_binds) do
	hl.bind(mod .. " + " .. k, function()
		hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = v, state = "down" }))
		hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = v, state = "up" }))
	end, { repeating = false })
end

hl.bind(mod .. " + q", hl.dsp.window.close())
hl.bind(mod .. " + m", hl.dsp.exit())

-- Focus
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.exec_cmd("window-switcher.sh"))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces
for i = 1, 9 do
	hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png"))

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true, repeating = true })

-- Brightness
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessbuttons.sh intel_backlight .1"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessbuttons.sh intel_backlight -.1"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86KbdBrightnessUp",
	hl.dsp.exec_cmd("brightnessbuttons.sh smc::kbd_backlight .1"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86KbdBrightnessDown",
	hl.dsp.exec_cmd("brightnessbuttons.sh smc::kbd_backlight -.1"),
	{ locked = true, repeating = true }
)

-- Mouse Binds
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
