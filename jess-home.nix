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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # KDE Plasma
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  environment.plasma6.excludePackages = with pkgs.plasma6; [
    elisa
    kwrite
  ];

  programs.kdeconnect.enable = true;

  home.file.".config/kdeglobals".text = ''
    [General]
    BrowserApplication=google-chrome.desktop
  '';

  home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".text = ''
    [Containments][1][Applets][2][Configuration][General]
    launchers=applications:google-chrome.desktop,applications:discord.desktop
  '';
}
