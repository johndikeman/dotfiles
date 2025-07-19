{
  config,
  lib,
  pkgs,
  # nixGL,
  ...
}:
let
  sources = import ./nix/sources.nix;
in
{
  imports = [
    ./nix/fish.nix
    ./nix/neovim.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dikeman";
  home.homeDirectory = "/home/dikeman";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    pkgs.gh
    pkgs.nodejs_22
    pkgs.git
    pkgs.cargo
    pkgs.rustc
    pkgs.prettierd
    pkgs.xkeysnail
    pkgs.python312
    pkgs.python312Packages.pip
    pkgs.xclip
    pkgs.maturin
    pkgs.niv
    pkgs.ncdu
    pkgs.nixfmt-rfc-style
    pkgs.obsidian
    pkgs.tmux
    pkgs.google-cloud-sdk
    pkgs.libevent # dependencies for playwright for some reason
    pkgs.flite
    pkgs.mullvad-vpn
    pkgs.uv
    pkgs.terraform
    pkgs.black
    pkgs.qbittorrent
    pkgs.vlc
    (import sources.nixGL { inherit pkgs; }).nixVulkanIntel
    (import sources.nixGL { inherit pkgs; }).nixGLIntel
    pkgs.blender
    pkgs.anki
    pkgs.calibre
    # nixGL.nixVulkanIntel
    # (pkgs.godot_4.overrideAttrs (old: rec {
    #   version = "4.5-dev1";
    #   commitHash = "97241ffea6df579347653a8ce0c75db44e28f0c8"; # Replace with the actual commit hash
    #   src = pkgs.fetchFromGitHub {
    #     owner = "godotengine";
    #     repo = "godot";
    #     rev = commitHash;
    #     sha256 = "adT8kQKiO7zD5EFHTjxofpj4sUvpu+nO+Atw/hZs0Gw="; # Replace with the actual source hash
    #   };
    # }))
    # # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    "${config.xdg.configHome}/touchegg" = {
      source = dotfiles/touchegg;
      recursive = true;
    };

    "${config.xdg.configHome}/xkeysnail" = {
      source = dotfiles/xkeysnail;
      recursive = true;
    };
    "${config.xdg.configHome}/containers" = {
      source = dotfiles/containers;
      recursive = true;
    };
    "${config.xdg.configHome}/nixpkgs" = {
      source = dotfiles/nixpkgs;
      recursive = true;
    };
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.tmux = {
    enable = true;
    shell = "/home/dikeman/.nix-profile/bin/fish";
    prefix = "C-a";
    keyMode = "vi"; # Optional: Use vi-style key bindings
    baseIndex = 1; # Start window numbering at 1
    escapeTime = 0; # Faster escape sequence detection

    plugins = with pkgs.tmuxPlugins; [
      sensible # Common sensbile defaults
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'  # Closest to Gruvbox dark
        '';
      }
    ];

    extraConfig = ''
      # Improve colors
      set -g default-terminal "screen-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Gruvbox-inspired color scheme (fallback if Catppuccin isn't preferred)
      set -g pane-border-style "fg=#665c54"
      set -g pane-active-border-style "fg=#a89984"
      set -g status-style "bg=#1d2021,fg=#a89984"
      set -g window-status-current-style "bg=#3c3836,fg=#a89984"
      set -g message-style "bg=#3c3836,fg=#a89984"
      set -g status-right "#[bg=#1d2021,fg=#a89984] %H:%M | %d-%b-%y "

      # Mouse support
      set -g mouse on

      # Reload config with r
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
    '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dikeman/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    SHELL = "fish";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git.enable = true;
  programs.git.userEmail = "jrobdikeman@gmail.com";
  programs.git.userName = "john";

  # Systemd service to auto-start xkeysnail
  systemd.user.services.xkeysnail = {
    Unit = {
      Description = "xkeysnail Keyboard Remapper";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      # needed to edit sudoers to remove the need for a password for this program
      # https://stackoverflow.com/questions/21659637/how-to-fix-sudo-no-tty-present-and-no-askpass-program-specified-error
      ExecStart = "sudo ${pkgs.xkeysnail}/bin/xkeysnail --quiet ${~/.config/xkeysnail/config.py}";
      Restart = "on-failure";
      # Run with sudo (required for key grabbing)
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Disable GNOME's Super key overlay (to avoid conflicts)
  home.activation.ensureXkeysnail = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    		${pkgs.glib}/bin/gsettings set org.gnome.mutter overlay-key "" 
    	'';
}
