{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jess";
  home.homeDirectory = "/home/jess";

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
    pkgs.xclip
    pkgs.vlc
    pkgs.blender
    pkgs.anki
    pkgs.spotify
    pkgs.google-chrome
    pkgs.discord
    pkgs.yaru-theme
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
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
  #  /etc/profiles/per-user/jess/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {

    # EDITOR = "emacs";
    SHELL = "fish";
  };

  dconf.enable = true;

  dconf.settings = {
    "org/cinnamon/desktop/interface" = {
      "gtk-theme" = "Yaru-pink-dark";
      "icon-theme" = "Yaru-pink";
      "cursor-theme" = "Yaru-pink";
      "cursor-size" = 24;
    };

    "org/cinnamon/theme" = {
      "name" = "Yaru-pink-dark";
    };

    "org.cinnamon" = {
      "enabled-applets" = [
        "panel1:left:0:menu@cinnamon.org"
        "panel1:left:1:show-desktop@cinnamon.org"
        "panel1:left:2:grouped-window-list@cinnamon.org"
        "panel1:right:0:systray@cinnamon.org"
        "panel1:right:1:xapp-status@cinnamon.org"
        "panel1:right:2:notifications@cinnamon.org"
        "panel1:right:3:printers@cinnamon.org"
        "panel1:right:4:removable-drives@cinnamon.org"
        "panel1:right:5:keyboard@cinnamon.org"
        "panel1:right:6:favorites@cinnamon.org"
        "panel1:right:7:clock@cinnamon.org"
      ];
    };

    "org/cinnamon/applets/grouped-window-list" = {
      "pinned-apps" = [
        "google-chrome.desktop"
        "discord.desktop"
      ];
    };
  };

  programs.home-manager.enable = true;
}
