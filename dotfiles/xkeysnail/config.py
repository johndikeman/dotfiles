# Save as `macos_shortcuts.py`
# Run with: sudo xkeysnail macos_shortcuts.py

from xkeysnail.transform import *

# Define applications that should use macOS shortcuts (exclude terminals)
APPLICATIONS = [
    "gnome-shell",           # GNOME desktop
    "chrome", "chromium","firefox"    # Browsers
    "code",                  # VS Code
    "nautilus",              # File browser
    "gedit", "libreoffice",  # Text editors
    "slack", "discord"       # Apps
]

define_modmap({
    # Map Caps Lock to Escape (optional, macOS-like behavior)
    Key.CAPSLOCK: Key.ESC,
})

define_keymap(
    lambda wm_class: wm_class.casefold() not in [
        "gnome-terminal", "konsole", "xterm", "alacritty", "kitty"
    ],
    {
        # Basic editing shortcuts (Cmd -> Ctrl)
        K("Super-C"): K("Ctrl-C"),        # Copy
        K("Super-V"): K("Ctrl-V"),        # Paste
        K("Super-X"): K("Ctrl-X"),        # Cut
        K("Super-Z"): K("Ctrl-Z"),        # Undo
        K("Super-Shift-Z"): K("Ctrl-Shift-Z"),  # Redo
        K("Super-A"): K("Ctrl-A"),        # Select All
        K("Super-F"): K("Ctrl-F"),        # Find
        
        # Window/Tab Management
        K("Super-Q"): K("Alt-F4"),        # Close app (macOS Quit)
        K("Super-W"): K("Ctrl-W"),        # Close tab/window
        K("Super-T"): K("Ctrl-T"),        # New tab
        K("Super-N"): K("Ctrl-N"),        # New window
        
        # Navigation
        K("Super-Left"): K("Home"),       # Jump to start of line
        K("Super-Right"): K("End"),       # Jump to end of line
        K("Alt-Left"): K("Ctrl-Left"),    # Previous word (macOS Option+Left)
        K("Alt-Right"): K("Ctrl-Right"),  # Next word (macOS Option+Right)
        
        # App Switching & System
        K("Super-Tab"): K("Alt-Tab"),               # App switcher
        K("Super-Grave"): K("Alt-Grave"),           # Switch windows of same app
        K("Super-Space"): K("Super-Space"),         # Keep GNOME search (or remap)
        K("Super-L"): K("Ctrl-Alt-L"),              # Lock screen (Pop!_OS default)
        
        # Browser Shortcuts (Chrome/Chromium/Firefox)
        K("Super-L"): K("Ctrl-L"),        # Focus address bar
        K("Super-R"): K("Ctrl-R"),        # Reload page
        K("Super-KPPLUS"): K("Ctrl-KPPLUS"),  # Zoom in
        K("Super-Minus"): K("Ctrl-Minus"),# Zoom out
    },
    "macOS Shortcuts"
)

# trying this so we can two finger swipe to go left
define_keymap("firefox", {
    K("Ctrl-Left"): K("Alt-Left"),    # Previous word (macOS Option+Left)
})

# Terminal apps: Disable macOS shortcuts to avoid conflicts
define_keymap(
    lambda wm_class: wm_class.casefold() in [
        "gnome-terminal", "konsole", "xterm", "alacritty", "kitty"
    ],
    {
        # Allow native terminal shortcuts (Ctrl+C for SIGINT, etc.)
        # copy/paste
        K("Super-C"): K("Ctrl-Shift-C"),    
        K("Super-V"): K("Ctrl-Shift-V"),   
    },
    "Terminals"
)
