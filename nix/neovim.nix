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
  home.packages = [ pkgs.neovim ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
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
