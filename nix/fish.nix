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
    generateCompletions = true;
    interactiveShellInit = "theme_gruvbox dark hard";
    functions = {
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
  };
  home.file = {
  };
}
