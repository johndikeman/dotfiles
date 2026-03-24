{
  config,
  lib,
  pkgs,
  # nixGL,
  ...
}:
let

  sources = import ./sources.nix;

in

{
  home.packages = [ pkgs.fish ];

  programs.fish = {
    enable = true;
    shellAliases = {
      # Some common aliases
    };
    generateCompletions = true;
    functions = {
      nix = {
        body = ''
          switch "$argv[1]"
            case build shell develop
              nom $argv
            case flake
              if test "$argv[2]" = "check"
                command nix $argv --log-format internal-json -v 2>&1 | nom --json
              else
                command nix $argv
              end
            case "*"
              command nix $argv
          end
        '';
      };
      nixos-rebuild = {
        body = ''
          sudo nixos-rebuild $argv --log-format internal-json -v 2>&1 | nom --json
        '';
      };
      replace_in_files = {
        body = ''

            set -l from "$argv[1]"
            set -l to "$argv[2]"

            # Escape special regex characters
            set -l from_esc (string escape --style=regex -- "$from")
            set -l to_esc (string escape --style=regex -- "$to")

            # Find files and run sed replacement
            find . -type f -exec sed -i "s/$from_esc/$to_esc/g" {} +
          			'';
      };
    };
    plugins = [
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
    interactiveShellInit = ''
      fish_add_path $HOME/.npm-packages/bin
    '';
  };
  home.file = {
  };
}
