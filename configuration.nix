# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  rose-pine-hyprcursor,
  helium,
  inputs,
  ...
}:

{
  # Custom font package definition
  nixpkgs.overlays = [
    (final: prev: {
      # Fix for cantarell-fonts build failure due to AFDKO 5.0 regression
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (python-final: python-prev: {
          afdko = python-prev.afdko.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace python/afdko/otfautohint/hinter.py \
                --replace-fail '        lo = None' "" \
                --replace-fail '        hi = None' ""
              sed -i '/for sidx, s0 in enumerate(hs0.stems\[0\]):/a \            hi = None' python/afdko/otfautohint/hinter.py
              sed -i '/for sidx, s0 in enumerate(hs0.stems\[0\]):/a \            lo = None' python/afdko/otfautohint/hinter.py
              sed -i "/elif isG == 'high':/{n;s/assert lo is not None and hi is not None/assert hi is not None/;}" python/afdko/otfautohint/hinter.py
            '';
          });
        })
      ];

      noto-fonts-color-emoji = prev.noto-fonts-color-emoji.overrideAttrs (old: {
        enableParallelBuilding = false;
      });

      cartograph-font = prev.stdenv.mkDerivation {
        name = "cartograph-font";
        src = prev.fetchFromGitHub {
          owner = "g5becks";
          repo = "Cartograph";
          rev = "master";
          sha256 = "0hwpvgmjjb04jwk6bd650cnzyba32vm3gvffz42b1xdkny5j5irz";
        };
        installPhase = ''
          mkdir -p $out/share/fonts/opentype
          cp *.otf $out/share/fonts/opentype/
        '';
      };
    })
  ];
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-macpro"; # Define your hostname.
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    libdecor
    wayland
    dbus
    dbus.lib
    fontconfig
    fontconfig.lib
    libpulseaudio
    speechd-minimal
    udev
    vulkan-loader
    libx11
    libxcursor
    libxinerama
    libxext
    libxrandr
    libxrender
    libxi
    libxfixes
    libxcb
    libxkbcommon
    fontconfig
    alsa-lib
    libdecor
    dbus
    libpulseaudio
  ];

  xdg = {
    mime.defaultApplications = {
      "inode/directory" = [ "nemo.desktop" ];
      "application/x-gnome-saved-search" = [ "nemo.desktop" ];
    };
  };
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  programs.k3b.enable = true;
  services.udisks2.enable = true;
  programs.regreet = {
    enable = true;

    # Optional: Configure regreet settings
    settings = {
      # Add any regreet-specific settings here
      # Example:
      # background = {
      #   path = "/path/to/wallpaper.jpg";
      #   fit = "Cover";
      # };
    };

    # Optional: Configure theme settings
    theme = {
      name = "Adwaita-dark"; # or your preferred theme
    };

    iconTheme = {
      name = "Adwaita";
    };

    font = {
      name = "Cartograph CF";
      size = 16;
    };

    # Optional: Add custom CSS
    # extraCss = ''
    #   window {
    #     background: rgba(0, 0, 0, 0.8);
    #   }
    # '';
  };

  # Configure greetd to use Hyprland instead of cage
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland --config /etc/greetd/hyprland.conf";
        user = "greeter";
      };
    };
  };

  # Create the Hyprland config file for the greeter
  environment.etc."greetd/hyprland.conf".text = ''
    # Launch regreet and exit Hyprland when it's done
    exec-once = ${pkgs.regreet}/bin/regreet; hyprctl dispatch exit

    # Disable Hyprland branding and splash
    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
    }

    monitor = HDMI-A-1,3840x2160,0x0,1.5

    # Optional: Set some basic input settings
    input {
      kb_layout = us
      follow_mouse = 1
      touchpad {
        natural_scroll = false
      }
    }

    # Optional: Basic window rules for regreet
    general {
      gaps_in = 0
      gaps_out = 0
      border_size = 0
    }

    # Optional: Disable animations for faster startup
    animations {
      enabled = false
    }
  '';

  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      firefox
      helium
    '';
    mode = "0755";
  };

  # Ensure the greeter user exists
  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
  };

  users.groups.greeter = { };

  programs.dconf.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb = {
  #  layout = "us";
  #  variant = "";
  #};

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.wayland.enableGnomeKeyring = true;

  security.sudo.extraRules = [
    {
      users = [ "john" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # flatpak for steam link
  services.flatpak.enable = true;
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  programs.hyprland.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.john = {
    isNormalUser = true;
    description = "john";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "cdrom"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  programs.steam = {
    enable = true; # Master switch, already covered in installation
    remotePlay.openFirewall = true; # For Steam Remote Play
    dedicatedServer.openFirewall = true; # For Source Dedicated Server hosting
    # Other general flags if available can be set here.
    gamescopeSession.enable = true;
  };

  programs.gamescope.enable = true;

  # Let Home Manager install and manage itself.
  # Enable fish shell
  programs.fish.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    pkgs.neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    pkgs.git
    pkgs.unzip
    pkgs.nix-output-monitor
    pkgs.gparted
    rose-pine-hyprcursor
    helium
  ];
  hardware.facetimehd.enable = true;
  # Font configuration
  fonts = {
    packages = with pkgs; [
      cartograph-font
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Cartograph CF" ];
        sansSerif = [ "Cartograph CF" ];
        serif = [ "Cartograph CF" ];
      };
    };
  };

  environment.variables.EDITOR = "nvim";

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [
      "john"
    ];
  };

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services.mullvad-vpn.enable = true;

  # Open ports in the firewall.
  # 8010 is used for chromecast support for vlc
  networking.firewall.allowedTCPPorts = [ 8010 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
  };
}
