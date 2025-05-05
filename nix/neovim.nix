{
  config,
  lib,
  pkgs,
  # nixGL,
  ...
}:
let

  sources = import ./sources.nix;
  prettier-nvim = pkgs.buildVimPlugin {
    pname = "prettier.nvim";
    version = "2025-04-08";
    src = pkgs.fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "prettier.mvim";
      rev = "ca6452de1accc68a1062e72f58679caa488b501a";
      sha256 = "1rvlx21kw8865dg6q97hx9i2s1n8mn1nyhn0m7dkx625pghsx3js";
    };
    meta.hydraPlatforms = [ ];
  };

  vim-svelte-plugin = pkgs.buildVimPlugin {
    pname = "vim-svelte-plugin";
    version = "2025-04-07";
    src = pkgs.fetchFromGitHub {
      owner = "leafOfTree";
      repo = "vim-svelte-plugin";
      rev = "f80ff67a94e3ac279fe55ecdf55ad7342f4a5228";
      sha256 = "1rvlx21kw8865dg6q97hx9i2s1n8mn1nyhn0m7dkx625pghsx3js";
    };
    meta.hydraPlatforms = [ ];
  };

  stylua-nvim = pkgs.buildVimPlugin {
    pname = "stylua-nvim";
    version = "2022-05-05";
    src = pkgs.fetchFromGitHub {
      owner = "ckipp01";
      repo = "stylua-nvim";
      rev = "ce59a353f02938cba3e0285e662fcd3901cd270f";
      sha256 = "1rvlx21kw8865dg6q97hx9i2s1n8mn1nyhn0m7dkx625pghsx3js";
    };
    meta.hydraPlatforms = [ ];
    dependencies = [ pkgs.stylua ];
  };

  model-nvim = pkgs.buildVimPlugin {
    pname = "model.nvim";
    version = "2025-01-25";
    src = pkgs.fetchFromGitHub {
      owner = "gsuuon";
      repo = "model.nvim";
      rev = "aac9525e0ce9fa074807f43f2537ad73b88010a5";
      sha256 = "1rvlx21kw8865dg6q97hx9i2s1n8mn1nyhn0m7dkx625pghsx3js";
    };
    meta.hydraPlatforms = [ ];
  };

  workspaces-nvim = pkgs.buildVimPlugin {
    pname = "workspaces.nvim";
    version = "2024-10-08";
    src = pkgs.fetchFromGitHub {
      owner = "natecraddock";
      repo = "workspaces.nvim";
      rev = "55a1eb6f5b72e07ee8333898254e113e927180ca";
      sha256 = "1rvlx21kw8865dg6q97hx9i2s1n8mn1nyhn0m7dkx625pghsx3js";
    };
    meta.hydraPlatforms = [ ];
  };
in
{
  home.packages = [ pkgs.neovim ];
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
                      path = "${pkgs.vimUtils.packDir config.home-manager.users.USERNAME.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
      								patterns = {""},
                    },
                    install = {
                      -- Safeguard in case we forget to install a plugin with Nix
                      missing = false,
                    },
                  })
    '';
    enable = true;
    package = pkgs.neovim-nightly;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ../dotfiles/nvim/lua;
  };
}
