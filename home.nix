{ config, lib, pkgs, ... }:
let  
  sources = import ./nix/sources.nix;
  poetry2nix = import sources.poetry2nix { inherit pkgs; };
in
{
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
    pkgs.neovim
    pkgs.gh
		pkgs.nodejs_23
		pkgs.git
		pkgs.cargo
		pkgs.rustc
		pkgs.prettierd
		pkgs.xkeysnail
		pkgs.fish
		pkgs.python312
		pkgs.python312Packages.pip
		pkgs.glibc
		pkgs.gcc
		pkgs.gcc.cc.lib
		pkgs.xclip
    # # It is sometimes useful to fine-tune packages, for example, by applying
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
    "${config.xdg.configHome}/nvim" = {
			source = dotfiles/nvim;
			recursive = true;
    };
    
    "${config.xdg.configHome}/touchegg" = {
			source = dotfiles/touchegg;
			recursive = true;
    };

    "${config.xdg.configHome}/xkeysnail" = {
			source = dotfiles/xkeysnail;
			recursive = true;
    };
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };
	programs.fish = {
		enable = true;
		plugins = [
		 {
		 		name = "fish-ai";
        src = pkgs.fetchFromGitHub {
          owner = "Realiserad";
          repo = "fish-ai";
          rev = "6d489f57704340fd43351dd85b941e8c5c49229f";
					sha256 = "adT8kQKiO7zD5EFHTjxofpj4sUvpu+nO+Atw/hZs0Gw=";
        };}
			{
				name = "fisher";
				src = pkgs.fetchFromGitHub {
					owner = "jorgebucaran";
					repo = "fisher";
					rev = "a6bf0e5b9e356d57d666bc6def114f16f1e5e209";
					sha256 = "VC8LMjwIvF6oG8ZVtFQvo2mGdyAzQyluAGBoK8N2/QM=";
				};
			}
			{
				name = "nix-env.fish";
				src = pkgs.fetchFromGitHub {
					owner = "lilyball";
					repo = "nix-env.fish";
					rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
					sha256 = "RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
				};
			}
		];
		shellInit = ''
      # Fish requires explicit handling of colon-separated vars
      set -gx LD_LIBRARY_PATH "${pkgs.gcc.cc.lib}/lib" $LD_LIBRARY_PATH
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
		LD_LIBRARY_PATH = "${pkgs.gcc.cc.lib}/lib:{$LD_LIBRARY_PATH}";
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
	home.activation.ensureXkeysnail = lib.hm.dag.entryAfter ["writeBoundary"] ''
		${pkgs.glib}/bin/gsettings set org.gnome.mutter overlay-key "" 
	'';
}
