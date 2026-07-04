{
  config,
  lib,
  pkgs,
  # nixGL,
  ...
}:
let

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
    version = "unstable-2024-06-09";
    src = pkgs.fetchFromGitHub {
      owner = "numtostr";
      repo = "Comment.nvim";
      rev = "e30b7f2008e52442154b66f7c519bfd2f1e32acb";
      sha256 = "0dyz78j0kj3j99y5g8wncl7794g6z2qs05gfg9ddxaa4xswhyjc7";
    };
    meta.homepage = "https://github.com/numtostr/comment.nvim/";
    meta.hydraPlatforms = [ ];
  };

  milli-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "milli.nvim";
    version = "unstable-2026-04-29";
    src = pkgs.fetchFromGitHub {
      owner = "Amansingh-afk";
      repo = "milli.nvim";
      rev = "6a19fe9ab2a068b7ce384cea277c24672add161e";
      sha256 = "1w4b3lzddbh6cmg78mwayc1yam97mkyjy1cwi5j44gg88kn816wb";
    };
  };
  myPlugins = with pkgs.vimPlugins; [
    lazy-nvim
    gitsigns-nvim
    gruvbox-nvim
    nvim-lspconfig
    blink-cmp
    rustaceanvim
    nvim-treesitter.withAllGrammars
    plenary-nvim
    lsp-colors-nvim
    trouble-nvim
    vim-svelte-plugin
    telescope-nvim
    stylua-nvim
    comment-nvim
    nvim-ts-context-commentstring
    marks-nvim
    workspaces-nvim
    conform-nvim
    render-markdown-nvim
    vim-fugitive
    # dashboard-nvim
    persistence-nvim
    snacks-nvim
    nvim-web-devicons
    milli-nvim
    nvim-notify
    nui-nvim
    noice-nvim
    tiny-inline-diagnostic-nvim
  ];

  packDir = pkgs.vimUtils.packDir {
    myNeovimPackages = {
      start = myPlugins;
    };
  };
in
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # install language servers
  home.packages = [
    pkgs.nixd
    pkgs.lua-language-server
    pkgs.pyright
    pkgs.typescript-language-server
    pkgs.svelte-language-server
    pkgs.ripgrep # dependency for the telescope live-grep finder
    pkgs.stylua
  ];

  programs.neovim = {
    plugins = myPlugins;
    initLua = ''
               vim.opt.packpath:prepend("${packDir}")
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
                   path = "${packDir}/pack/myNeovimPackages/start",
                   patterns = {"."},
                   fallback = true,
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
