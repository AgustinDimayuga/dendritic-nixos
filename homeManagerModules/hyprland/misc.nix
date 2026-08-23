{ config, lib, pkgs, ... }:
{
  home.packages = [
    pkgs.hyprshot
  ];

  home.sessionVariables = {
    HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
  };

  wayland.windowManager.hyprland.settings.env = [
    { _args = [ "HYPRSHOT_DIR" "${config.home.homeDirectory}/Pictures/Screenshots" ]; }
  ];

  services.swaync.enable = true;
}
