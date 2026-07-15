{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    # Essential utilities
    waybar # Status bar
    wofi # Application launcher
    dunst # Notification daemon
    libnotify # Notification library
    awww # Wallpaper
    wl-clipboard # Clipboard manager
    cliphist # clipboard history
    slurp # Screen area selection
    pamixer # Audio control
    brightnessctl # Brightness control
    networkmanagerapplet # Network manager tray
    blueman # Bluetooth manager
    swaylock-effects # Screen locker
    swayidle # Idle management
    kitty # Terminal emulator
    polkit_gnome # Authentication agent
    qt5.qtwayland # QT wayland support
    qt6.qtwayland # QT6 wayland support
    adwaita-icon-theme # Icon theme
    papirus-icon-theme # Additional icon theme
    catppuccin-gtk # GTK theme
    hyprshutdown
    hyprpwcenter
    hyprsunset
    # Fonts are managed in configuration.nix

    (pkgs.writeShellApplication {
      name = "swww-randomize.sh";
      runtimeInputs = [ awww ];
      text = builtins.readFile ../scripts/swww-randomize.sh;
    })
    (pkgs.writeShellApplication {
      name = "modcopypaste.sh";
      runtimeInputs = [ pkgs.jq pkgs.hyprland pkgs.coreutils ];
      text = builtins.readFile ../scripts/modcopypaste.sh;
    })
    (pkgs.writeShellApplication {
      name = "brightnessbuttons.sh";
      runtimeInputs = [
        libnotify
        brightnessctl
        bc
      ];
      text = builtins.readFile ../scripts/brightnessbuttons.sh;
    })
    (pkgs.writeShellApplication {
      name = "powermenu.sh";
      runtimeInputs = [
        wofi
        hyprshutdown
      ];
      text = builtins.readFile ../scripts/powermenu.sh;
    })
    (pkgs.writeShellApplication {
      name = "window-switcher.sh";
      runtimeInputs = [
        jq
        wofi
        gawk
      ];
      text = builtins.readFile ../scripts/window-switcher.sh;
    })
    (pkgs.writeShellApplication {
      name = "firefox-history.sh";
      runtimeInputs = [
        sqlite
        wofi
        libnotify
        gawk
      ];
      text = builtins.readFile ../scripts/firefox-history.sh;
    })
  ];

  # Enable Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
    };
    configType = "lua";
    settings = { };

    extraConfig = builtins.readFile ./main.lua;

    xwayland = {
      enable = true;
    };
  };

  xdg.configFile."hypr/colors.lua".source = pkgs.replaceVars ./colors.lua.in {
    base00 = config.colorScheme.palette.base00;
    base01 = config.colorScheme.palette.base01;
    base02 = config.colorScheme.palette.base02;
    base03 = config.colorScheme.palette.base03;
    base04 = config.colorScheme.palette.base04;
    base05 = config.colorScheme.palette.base05;
    base06 = config.colorScheme.palette.base06;
    base07 = config.colorScheme.palette.base07;
    base08 = config.colorScheme.palette.base08;
    base09 = config.colorScheme.palette.base09;
    base0A = config.colorScheme.palette.base0A;
    base0B = config.colorScheme.palette.base0B;
    base0C = config.colorScheme.palette.base0C;
    base0D = config.colorScheme.palette.base0D;
    base0E = config.colorScheme.palette.base0E;
    base0F = config.colorScheme.palette.base0F;
  };

  services.hyprsunset = {
    enable = true;
    profile = [
      {
        time = "7:30";
      }
      {
        time = "21:00";
        temperature = 5000;
        gamma = 0.8;
      }
      {
        time = "22:00";
        temperature = 3000;
        gamma = 0.8;
      }
    ];
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
          "custom/powermenu"
        ];

        "custom/powermenu" = {
          format = "🌖";
          on-click = "powermenu.sh";
        };

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
          format = "{usage}% cpu";
          tooltip = false;
        };

        "memory" = {
          format = "{}% mem";
        };

        "battery" = {
          states = {
            "good" = 95;
            "warning" = 30;
            "critical" = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ⚡{icon}";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [
            "🪫"
            "🪫"
            "🔋"
            "🔋"
            "🔋"
          ];
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
          on-click = "hyprpwcenter";
        };

        "tray" = {
          icon-size = 18;
          spacing = 10;
        };
      };
    };
    style = pkgs.replaceVars ../css/waybar.css (
      {
        shadow_x = "-3px";
        shadow_y = "3px";
      }
      // lib.attrsets.filterAttrs (
        name: value:
        lib.strings.hasInfix name "base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F"
      ) config.colorScheme.palette
    );
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
    style = pkgs.replaceVars ../css/wofi.css (
      lib.attrsets.filterAttrs (
        name: value:
        lib.strings.hasInfix name "base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F"
      ) config.colorScheme.palette
    );
  };

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      dynamic_background_opacity = true;
      window_padding_width = 10;
      background_opacity = "0.9";
      background_blur = 5;
      background = "#${config.colorScheme.palette.base00}";
      foreground = "#${config.colorScheme.palette.base05}";
      cursor = "#${config.colorScheme.palette.base0A}";
      selection_background = "#${config.colorScheme.palette.base05}";
      # https://github.com/kdrag0n/base16-kitty/blob/master/templates/default.mustache
      color0 = "#${config.colorScheme.palette.base00}";
      color8 = "#${config.colorScheme.palette.base03}";
      color1 = "#${config.colorScheme.palette.base08}";
      color9 = "#${config.colorScheme.palette.base09}";
      color2 = "#${config.colorScheme.palette.base0B}";
      color10 = "#${config.colorScheme.palette.base0A}";
      color3 = "#${config.colorScheme.palette.base0A}";
      color11 = "#${config.colorScheme.palette.base02}";
      color4 = "#${config.colorScheme.palette.base0D}";
      color12 = "#${config.colorScheme.palette.base04}";
      color5 = "#${config.colorScheme.palette.base0E}";
      color13 = "#${config.colorScheme.palette.base06}";
      color6 = "#${config.colorScheme.palette.base0C}";
      color14 = "#${config.colorScheme.palette.base0F}";
      color7 = "#${config.colorScheme.palette.base05}";
      color15 = "#${config.colorScheme.palette.base07}";

      selection_foreground = "#${config.colorScheme.palette.base00}";
    };
  };

  # GTK theme settings
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        variant = "mocha";
      };
    };
    gtk4.theme = config.gtk.theme;
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
    # make firefox use wayland?
    MOZ_ENABLE_WAYLAND = "1";
    # Set default applications
    TERMINAL = "kitty";
    BROWSER = "firefox";
    EDITOR = "nvim";
    # Enable QT apps to use wayland
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # GTK theme
    GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
    AWWW_TRANSITION_FPS = 60;
    AWWW_TRANSITION_STEP = 2;
    HYPRCURSOR_THEME = "rose-pine-hyprcursor";
  };
}
