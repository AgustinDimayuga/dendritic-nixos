{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    hyprland-desktop.enable = lib.mkEnableOption "enable Hyprland config for desktop (external monitor)";
    hyprland-laptop.enable = lib.mkEnableOption "enable Hyprland config for laptop (built-in display)";
  };

  config = lib.mkMerge [

    # Shared base — ALWAYS on, no condition needed
    {
      programs.kitty.enable = true; # required for the default Hyprland config
      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.package = null;
      wayland.windowManager.hyprland.settings = {
        # shared/default settings — binds, general, decoration, etc.
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-hyprland # or your preferred backend
        ];
        config.common.default = "*";
      };
    }

    # Desktop-only: specific monitor + resolution + refresh rate
    (lib.mkIf config.hyprland-desktop.enable {
      wayland.windowManager.hyprland.settings.monitor = [
        {
          output = "DP-3";
          mode = "2560x1440@360";
          position = "auto-left";
          scale = 1;
        }
      ];
    })

    # Laptop-only: force built-in display
    (lib.mkIf config.hyprland-laptop.enable {
      wayland.windowManager.hyprland.settings.monitor = [
        {
          output = "eDP-1";
          mode = "preferred";
          position = "auto";
          scale = 2;
        }
      ];
    })

  ];

  # Optional, hint Electron apps to use Wayland:
  # home.sessionVariables.NIXOS_OZONE_WL = "1";
}
