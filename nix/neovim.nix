{
  config,
  lib,
  pkgs,
  # nixGL,
  ...
}:
let

  sources = import ./sources.nix;
  prettier-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "prettier.nvim";
    version = "2025-04-08";
    src = pkgs.fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "prettier.nvim";
      rev = "ca6452de1accc68a1062e72f58679caa488b501a";
      hash = "sha256-pRGvsH9erN2rS3SkEGpz9F53W4HYYc4fqu/8CxE45SA=";
    };
    meta.hydraPlatforms = [ ];
  };

  vim-svelte-plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-svelte-plugin";
    version = "2025-04-07";
    src = pkgs.fetchFromGitHub {
      owner = "leafOfTree";
      repo = "vim-svelte-plugin";
      rev = "f80ff67a94e3ac279fe55ecdf55ad7342f4a5228";
      hash = "sha256-iOingO5LYAtcqXJliOvNtQPe1xDsHlCwmLTvdkkOlhU=";
    };
    meta.hydraPlatforms = [ ];
  };

  stylua-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "stylua-nvim";
    version = "2022-05-05";
    src = pkgs.fetchFromGitHub {
      owner = "ckipp01";
      repo = "stylua-nvim";
      rev = "ce59a353f02938cba3e0285e662fcd3901cd270f";
      hash = "sha256-GfqzyJTpwrh1NZqA7rVQ8TW6CYQL7F0/lUjZL5wZyeI=";
    };
    meta.hydraPlatforms = [ ];
    dependencies = [ pkgs.stylua ];
  };

  model-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "model.nvim";
    version = "2025-01-25";
    src = pkgs.fetchFromGitHub {
      owner = "gsuuon";
      repo = "model.nvim";
      rev = "aac9525e0ce9fa074807f43f2537ad73b88010a5";
      hash = "sha256-fsXn/MGP9NAXBXmTlW9y/QUNqKkKSKOJhIfNGg/PZNg=";
    };
    meta.hydraPlatforms = [ ];
  };

  workspaces-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "workspaces.nvim";
    version = "2024-10-08";
    src = pkgs.fetchFromGitHub {
      owner = "natecraddock";
      repo = "workspaces.nvim";
      rev = "55a1eb6f5b72e07ee8333898254e113e927180ca";
      hash = "sha256-a3f0NUYooMxrZEqLer+Duv6/ktq5MH2qUoFHD8z7fZA=";
    };
    meta.hydraPlatforms = [ ];
  };
in
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      gitsigns-nvim
      gruvbox-nvim
      FTerm-nvim
      nvim-lspconfig
      blink-cmp
      rustaceanvim
      nvim-treesitter
      null-ls-nvim
      prettier-nvim
      plenary-nvim
      lsp-colors-nvim
      trouble-nvim
      vim-svelte-plugin
      telescope-nvim
      stylua-nvim
      model-nvim
      comment-nvim
      nvim-ts-context-commentstring
      marks-nvim
			workspaces-nvim
    ];
    extraLuaConfig = ''
                  vim.g.mapleader = " " -- Need to set leader before lazy for correct keybindings
                  require("lazy").setup({
            				spec = {
            								-- Import plugins from lua/plugins
            								{ import = "plugins" },
            							},
                    performance = {
         reset_packpath = false,
                      rtp = {
                          reset = false,
                        }
                      },
                    dev = {
                      path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
      								patterns = {""},
                    },
                    install = {
                      -- Safeguard in case we forget to install a plugin with Nix
                      missing = false,
                    },
                  })
    '';
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ../dotfiles/nvim/lua;
  };
}
