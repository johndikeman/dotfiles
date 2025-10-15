{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # Essential utilities
    waybar # Status bar
    wofi # Application launcher
    dunst # Notification daemon
    libnotify # Notification library
    swww # Wallpaper
    wl-clipboard # Clipboard manager
    cliphist # clipboard history
    grim # Screenshot utility
    slurp # Screen area selection
    pamixer # Audio control
    brightnessctl # Brightness control
    networkmanagerapplet # Network manager tray
    blueman # Bluetooth manager
    swaylock-effects # Screen locker
    swayidle # Idle management
    wlsunset # Night light
    kitty # Terminal emulator
    xdg-desktop-portal-hyprland # XDG portal
    polkit_gnome # Authentication agent
    qt5.qtwayland # QT wayland support
    qt6.qtwayland # QT6 wayland support
    adwaita-icon-theme # Icon theme
    papirus-icon-theme # Additional icon theme
    catppuccin-gtk # GTK theme
    # Fonts are managed in configuration.nix

    (pkgs.writeShellApplication {
      name = "swww-randomize.sh";
      runtimeInputs = [ swww ];
      text = builtins.readFile ../scripts/swww-randomize.sh;
    })
    (pkgs.writeShellApplication {
      name = "modcopypaste.sh";
      runtimeInputs = [ jq ];
      text = builtins.readFile ../scripts/modcopypaste.sh;
    })
  ];

  services.swayidle =
    let
      # Lock command
      lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
      # TODO: modify "display" function based on your window manager
      # Sway
      # display = status: "swaymsg 'output * power ${status}'";
      # Hyprland
      display = status: "hyprctl dispatch dpms ${status}";
      # Niri
      # display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
    in
    {
      enable = true;
      timeouts = [
        {
          timeout = 280; # in seconds
          command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
        }
        {
          timeout = 300;
          command = lock;
        }
        {
          timeout = 420;
          command = display "off";
          resumeCommand = display "on";
        }
        {
          timeout = 600;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = lock + "; " + (display "off");
        }
        {
          event = "after-resume";
          command = "${pkgs.procps}/bin/killall swaylock; " + (display "on"); # my experience tells me this doens't work (i get swaylock on resume instead of sddm now) but my overall experience is fine/working so im not touching anything!
        }

      ];
    };

  # Enable Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    xwayland = {
      enable = true;
    };

    settings = {
      "$mod" = "SUPER";

      debug = {
        disable_logs = false;
      };

      exec-once = [
        "swww-daemon"
        "waybar"
        "dunst"
        "nm-applet"
        "blueman-applet"
        "/usr/libexec/polkit-gnome-authentication-agent-1"
        "swww-randomize.sh ~/wallpapers/"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      monitor = [
        "HDMI-A-1,3840x2160,0x0,1.5"
        # need to take the scaling into account in the position!
        "HDMI-A-2,3840x2160,-1440x-450,1.5,transform,1"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      # General configuration
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Decoration configuration
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        # drop_shadow = true;
        # shadow_range = 4;
        # shadow_render_power = 3;
      };

      # Animation configuration
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = -0.2;
        accel_profile = "flat";
      };

      # Window rules
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,class:^(blueman-manager)$"
        "float,class:^(nm-connection-editor)$"
      ];

      # Key bindings
      bind = [
        "$mod, space, exec, wofi --show drun"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        # fullscreen
        "$mod SHIFT, F, fullscreen"

        # global copy-paste with mod key
        "$mod, C, exec, modcopypaste.sh copy kitty"
        "$mod, V, exec, modcopypaste.sh paste kitty"

        # macos-esque bindings
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, F, sendshortcut, CTRL, F, active"
        "$mod, A, sendshortcut, CTRL, A, active"
        "$mod, R, sendshortcut, CTRL, R, active"
        "$mod, T, sendshortcut, CTRL, T, active"
        "$mod, W, sendshortcut, CTRL, W, active"

        # Move focus with mod + arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Screenshot bindings
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT, Print, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png"

        # Volume control
        ",XF86AudioRaiseVolume, exec, pamixer -i 5"
        ",XF86AudioLowerVolume, exec, pamixer -d 5"
        ",XF86AudioMute, exec, pamixer -t"

        # Brightness control
        ",XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  # Configure dunst for notifications
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 10;
        frame_color = "#8AADF4";
        separator_color = "frame";
        font = "Cartograph CF 10";
      };

      urgency_low = {
        background = "#24273A";
        foreground = "#CAD3F5";
        timeout = 5;
      };

      urgency_normal = {
        background = "#24273A";
        foreground = "#CAD3F5";
        timeout = 10;
      };

      urgency_critical = {
        background = "#24273A";
        foreground = "#CAD3F5";
        frame_color = "#F5A97F";
        timeout = 0;
      };
    };
  };

  # Configure waybar
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "cpu"
          "memory"
          "battery"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        "clock" = {
          format = "{:%I:%M %p}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "cpu" = {
          format = "cpu: {usage}% ";
          tooltip = false;
        };

        "memory" = {
          format = "mem: {}% ";
        };

        "battery" = {
          states = {
            "good" = 95;
            "warning" = 30;
            "critical" = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = {
            default = [
              "🪫"
              "🪫"
              "🔋"
              "🔋"
              "🔋"
            ];
            charging = [
              "⚡🪫"
              "⚡🪫"
              "⚡🔋"
              "⚡🔋"
              "⚡🔋"
            ];
          };
        };

        "network" = {
          format-wifi = "🛜 {essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "disconnected :(";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-bluetooth-muted = "muted {icon}";
          format-muted = "muted {icon}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "🎧";
            hands-free = "🎧";
            headset = "🎧";
            phone = "📱";
            portable = "📱";
            car = "🚗";
            default = [
              "🎧"
              "🎧"
              "🎧"
            ];
          };
          on-click = "pavucontrol";
        };

        "tray" = {
          icon-size = 21;
          spacing = 10;
        };
      };
    };
    style = ''
      						* {
      							border: none;
      							border-radius: 0;
      							font-family: "Cartograph CF";
      							font-size: 13px;
      							min-height: 0;
      						}

      						window#waybar {
      							background: rgba(21, 18, 27, 0.8);
      							color: #cdd6f4;
      						}

      						tooltip {
      							background: #1e1e2e;
      							border-radius: 10px;
      							border-width: 2px;
      							border-style: solid;
      							border-color: #11111b;
      						}

      						#workspaces button {
      							padding: 5px;
      							color: #313244;
      							margin-right: 5px;
      						}

      						#workspaces button.active {
      							color: #a6adc8;
      						}

      						#workspaces button.focused {
      							color: #a6adc8;
      							background: #eba0ac;
      							border-radius: 10px;
      						}

      						#workspaces button.urgent {
      							color: #11111b;
      							background: #a6e3a1;
      							border-radius: 10px;
      						}

      						#workspaces button:hover {
      							background: #11111b;
      							color: #cdd6f4;
      							border-radius: 10px;
      						}

      						#custom-launch_wofi,
      						#custom-power_btn,
      						#custom-power_profile,
      						#custom-weather,
      						#window,
      						#clock,
      						#cpu,
      						#memory,
      						#battery,
      						#pulseaudio,
      						#network,
      						#bluetooth,
      						#temperature,
      						#workspaces,
      						#tray,
      						#backlight {
      							background: #1e1e2e;
      							opacity: 0.8;
      							padding: 0px 5px;
      							margin: 5px 1px;
      							border: 1px solid #181825;
      							border-radius: 10px;
      						}

      						#tray {
      							padding-right: 5px;
      						}

      						#temperature.critical {
      							color: #eba0ac;
      						}

      						#workspaces {
      							background: #1e1e2e;
      							margin-left: 10px;
      							padding-right: 0px;
      							padding-left: 5px;
      						}

      						#custom-power_profile {
      							color: #a6e3a1;
      						}

      						#window {
      							margin-left: 60px;
      							margin-right: 60px;
      						}

      						#clock {
      							color: #fab387;
      						}

      						#network {
      							color: #f9e2af;
      						}

      						#bluetooth {
      							color: #89b4fa;
      						}

      						#pulseaudio {
      							color: #89b4fa;
      						}

      						#battery {
      							color: #a6e3a1;
      						}
    '';
  };

  # Configure wofi application launcher
  programs.wofi = {
    enable = true;
    settings = {
      width = "50%";
      height = "40%";
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
    };
    style = ''
      * {
        font-family: "Cartograph CF";
        font-size: 14px;
      }

      window {
        margin: 0px;
        border: 2px solid #8aadf4;
        background-color: rgba(36, 39, 58, 0.9);
        border-radius: 10px;
      }

      #input {
        margin: 5px;
        border: none;
        color: #cad3f5;
        background-color: rgba(54, 58, 79, 0.8);
        border-radius: 10px;
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: transparent;
        border-radius: 10px;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: transparent;
        border-radius: 10px;
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: #cad3f5;
      }

      #entry:selected {
        background-color: rgba(54, 58, 79, 0.8);
        border-radius: 10px;
      }
    '';
  };

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      dynamic_background_opacity = true;
      window_padding_width = 10;
      background_opacity = "0.8";
      background_blur = 5;
      background = "#29262f";
      foreground = "#d9e6f2";
      cursor = "#d9e6f2";
      selection_background = "#073642";
      color0 = "#000000";
      color8 = "#323232";
      color1 = "#c37372";
      color9 = "#dbaaaa";
      color2 = "#72c373";
      color10 = "#aadbaa";
      color3 = "#c2c372";
      color11 = "#dadbaa";
      color4 = "#7372c3";
      color12 = "#aaaadb";
      color5 = "#c372c2";
      color13 = "#dbaada";
      color6 = "#72c2c3";
      color14 = "#aadadb";
      color7 = "#d9d9d9";
      color15 = "#ffffff";
      selection_foreground = "#29262f";
    };
  };

  # GTK theme settings
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Cartograph CF";
      size = 11;
    };
  };

  # Configure environment variables
  home.sessionVariables = {
    # Tell electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # Set default applications
    TERMINAL = "kitty";
    BROWSER = "firefox";
    EDITOR = "nvim";
    # Enable QT apps to use wayland
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # GTK theme
    GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    SWWW_TRANSITION_FPS = 60;
    SWWW_TRANSITION_STEP = 2;
    HYPRCURSOR_THEME = "rose-pine-hyprcursor";
  };
}
