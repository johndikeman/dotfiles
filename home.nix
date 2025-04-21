{
  config,
  lib,
  pkgs,
  # nixGL,
  ...
}:
let
  sources = import ./nix/sources.nix;
  # what i'm doing to try to get this stupid fish-ai thing to work is insane
  src = pkgs.fetchFromGitHub {
    owner = "Realiserad";
    repo = "fish-ai";
    rev = "6d489f57704340fd43351dd85b941e8c5c49229f";
    sha256 = "adT8kQKiO7zD5EFHTjxofpj4sUvpu+nO+Atw/hZs0Gw=";
  };
  python = pkgs.python311;
  pythonPackages = python.pkgs;

  sslFix =
    pkg:
    pkg.overridePythonAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
        pkgs.cacert # Add CA certificates
      ];

      # Set certificate paths
      preConfigure =
        (old.preConfigure or "")
        + ''
          export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
        '';
    });

  # create a pinned pydantic-core derivation
  pydantic-core = pythonPackages.buildPythonPackage rec {
    pname = "pydantic_core";
    version = "2.20.1";
    pyproject = true;

    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "JsppXu7l+fGu6yEf/BLxC8tvceKYmYj9ph2r1l24eNQ=";
    };

    # patches = [ ./01-remove-benchmark-flags.patch ];

    cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      hash = "sha256-j9VAWV/AG+u52ji+erNUrdGX8kHlsOuYiBYbHzD0y8k=";
    };

    nativeBuildInputs = [
      pkgs.cargo
      pkgs.rustPlatform.cargoSetupHook
      pkgs.rustc
    ];

    build-system = [
      pkgs.rustPlatform.maturinBuildHook
      pythonPackages.typing-extensions
    ];

    buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.libiconv ];

    dependencies = [ pythonPackages.typing-extensions ];

    pythonImportsCheck = [ "pydantic_core" ];

    # escape infinite recursion with pydantic via dirty-equals
    doCheck = false;
    # passthru.tests.pytest = pydantic-core.overrideAttrs { doCheck = true; };

    nativeCheckInputs = [
      pkgs.pytestCheckHook
      pkgs.hypothesis
      pkgs.pytest-timeout
      pkgs.dirty-equals
      pkgs.pytest-mock
    ];

    disabledTests = [
      # RecursionError: maximum recursion depth exceeded while calling a Python object
      "test_recursive"
    ];

    disabledTestPaths = [
      # no point in benchmarking in nixpkgs build farm
      "tests/benchmarks"
    ];
  };
  pydantic = pythonPackages.pydantic.overridePythonAttrs (old: rec {
    version = "2.8.2";
    src = pythonPackages.fetchPypi {
      pname = "pydantic";
      inherit version;
      sha256 = "b2LBPQZ7B1WtHCGjS90GwMEmJaIrD8CcaxSYFmBPfCo=";
    };
    propagatedBuildInputs = [ pydantic-core ];
    dependencies = [
      pydantic-core
      pythonPackages.annotated-types
      pythonPackages.typing-extensions
    ];
  });

  mistralai = pythonPackages.buildPythonPackage rec {
    pname = "mistralai";
    version = "1.0.2";
    format = "pyproject";

    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "RvtEB9GkFhsj4bLExzVHhDP7ekGrsF+s0jJy+wXRcbU=";
    };
    propagatedBuildInputs = [
      pydantic
      (pythonPackages.buildPythonPackage rec {
        pname = "jsonpath-python";
        version = "1.0.6";
        format = "setuptools";
        src = pythonPackages.fetchPypi {
          inherit pname version;
          sha256 = "3Vvkpy2KKZXD9YPPgr880alUTP2r8tIllbZ6/wc0lmY=";
        };
      })
      pythonPackages.python-dateutil
      pythonPackages.typing-inspect
      pythonPackages.httpx
    ];

    nativeBuildInputs = [
      pythonPackages.setuptools
      pythonPackages.wheel
      pythonPackages.poetry-core
    ];
  };
  # Create explicit dependency list with versions
  dependencies = [
    (pythonPackages.openai.overridePythonAttrs (old: rec {
      version = "1.60.0";
      src = pythonPackages.fetchPypi {
        pname = "openai";
        inherit version;
        sha256 = "sha256-f6U2zUtkRxhkW4dNJwbjbbvvOLMn5CygYjJ12jR+4ak=";
      };
      doCheck = false;
      dependencies = [
        pydantic
        pythonPackages.anyio
        pythonPackages.distro
        pythonPackages.httpx
        pythonPackages.jiter
        pythonPackages.sniffio
        pythonPackages.tqdm
        pythonPackages.typing-extensions
      ];
    }))
    (pythonPackages.simple-term-menu.overridePythonAttrs (old: rec {
      version = "1.6.6";
      src = pythonPackages.fetchPypi {
        pname = "simple_term_menu";
        inherit version;
        sha256 = "mBPTb1dJ1i0gClWZseyIRpxxN4MSrcCEwAwAv7s4OJM=";
      };
    }))
    (sslFix (
      pythonPackages.buildPythonPackage rec {
        pname = "iterfzf";
        version = "1.4.0.54.3";
        format = "pyproject";
        __noChroot = true;

        src = pythonPackages.fetchPypi {
          inherit pname version;
          sha256 = "igudxPGhJtqVndYBZDvzHef6af67fDP0tuL6jtxL4uE="; # Replace with actual hash
        };

        nativeBuildInputs = [
          pythonPackages.flit-core
          pythonPackages.packaging
          pythonPackages.pyproject-hooks
          pkgs.fzf
        ];

        propagatedBuildInputs = [
          pythonPackages.typing-extensions
        ];

        # Needed for the custom build backend
        # preBuild = ''
        #  cp ${./build_dist.py} build_dist.py
        #  export FZF_PATH=${pkgs.fzf}/bin/fzf
        #'';

        # Disable tests that require network or external resources
        doCheck = false;

        meta = with lib; {
          description = "FZF-based interactive list UI for Python iterables";
          homepage = "https://github.com/ajalt/iterfzf";
          license = licenses.mit;
        };
      }
    ))
    (pythonPackages.buildPythonPackage rec {
      pname = "hugchat";
      version = "0.4.18";
      src = pythonPackages.fetchPypi {
        inherit pname version;
        sha256 = "OlAo0rSfBfU+UYXvkLErBzCQzdMGDiMjewxfzqYJbDE=";
      };
      propagatedBuildInputs = [ pythonPackages.requests ];
    })

    mistralai

    pythonPackages.binaryornot
    (pythonPackages.anthropic.overridePythonAttrs (old: rec {
      version = "0.45.0";
      doCheck = false;
      doInstallCheck = false;
      src = pythonPackages.fetchPypi {
        pname = "anthropic";
        inherit version;
        sha256 = "sha256-ToVB3DVTMgkL/FG4RUnBm2SaE6I9vWvWjh0BLghVECU=";
      };
      dependencies = [
        pythonPackages.anyio
        pythonPackages.distro
        pythonPackages.httpx
        pythonPackages.jiter
        pythonPackages.sniffio
        pydantic
        pythonPackages.tokenizers
        pythonPackages.typing-extensions
      ];
    }))
    (pythonPackages.cohere.overridePythonAttrs (old: rec {
      version = "5.13.11";
      src = pythonPackages.fetchPypi {
        pname = "cohere";
        inherit version;
        sha256 = "hdLBoorIPTR5pcHKbN+Xu1J5RxTH/eBU65Ns/q+vV/Y=";
      };
      dependencies = [
        pythonPackages.fastavro
        pythonPackages.httpx
        pythonPackages.httpx-sse
        pythonPackages.parameterized
        pydantic
        pydantic-core
        pythonPackages.requests
        pythonPackages.tokenizers
        pythonPackages.types-requests
        pythonPackages.typing-extensions
      ];
    }))
  ];

  fish-ai = pythonPackages.buildPythonApplication {
    pname = "fish_ai";
    version = "1.0.3";
    inherit src;

    format = "pyproject";
    disabled = pythonPackages.pythonOlder "3.9";

    propagatedBuildInputs = dependencies;

    nativeBuildInputs = [
      pythonPackages.setuptools
      pythonPackages.pytest
      pythonPackages.pyfakefs
    ];

    # Add required system dependencies
    buildInputs = [
      pkgs.libffi
      pkgs.openssl
    ];

    # Verify the scripts are properly installed
    checkPhase = ''
      ${python.interpreter} -m pytest src/fish_ai/tests
    '';
  };
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
    pkgs.godot_4
    (import sources.nixGL { inherit pkgs; }).nixVulkanIntel
		pkgs.blender
		pkgs.anki
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
    ".fish-ai" = {
      source = fish-ai;
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

  programs.fish = {
    enable = true;
    generateCompletions = true;
    interactiveShellInit = "theme_gruvbox dark hard";
    plugins = [
      {
        name = "fish-ai";
        src = pkgs.fetchFromGitHub {
          owner = "Realiserad";
          repo = "fish-ai";
          rev = "6d489f57704340fd43351dd85b941e8c5c49229f";
          sha256 = "adT8kQKiO7zD5EFHTjxofpj4sUvpu+nO+Atw/hZs0Gw=";
        };
      }
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
      {
        name = "fish-gruvbox";
        src = pkgs.fetchFromGitHub {
          owner = "Jomik";
          repo = "fish-gruvbox";
          rev = "master";
          sha256 = "RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
    ];
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
