{
  config,
  lib,
  pkgs,
  # nixGL,
  ...
}:
let

  sources = import ./sources.nix;

  conform-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "conform.nvim";
    version = "2025-04-20";
    src = pkgs.fetchFromGitHub {
      owner = "stevearc";
      repo = "conform.nvim";
      rev = "372fc521f8421b7830ea6db4d6ea3bae1c77548c";
      hash = "sha256-J/GKqn2VHv/ydaFXWCFduV2B7iwZzHtUvFArszxf2Cw=";
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

	comment-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "Comment.nvim";
    version = "2024-06-09";
    src = pkgs.fetchFromGitHub {
      owner = "numtostr";
      repo = "Comment.nvim";
      rev = "e30b7f2008e52442154b66f7c519bfd2f1e32acb";
      sha256 = "0dyz78j0kj3j99y5g8wncl7794g6z2qs05gfg9ddxaa4xswhyjc7";
    };
    meta.homepage = "https://github.com/numtostr/comment.nvim/";
    meta.hydraPlatforms = [ ];
  };

in
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

	# install language servers
	home.packages = [
		pkgs.nil
		pkgs.lua-language-server
		pkgs.pyright
		pkgs.typescript-language-server
		pkgs.svelte-language-server
		pkgs.ripgrep # dependency for the telescope live-grep finder
	];

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
			conform-nvim
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

                require "config"
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
