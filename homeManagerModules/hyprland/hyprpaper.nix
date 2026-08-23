{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.theme;

  wallpaperFile = {
    dracula = ../assets/wallpapers/nixos.png;
    gruvbox = ../assets/wallpapers/gruvbox-dark-blue.png;
  };

  wallpaper = toString wallpaperFile.${theme};
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ wallpaper ];
      wallpaper = [
        {
          monitor = "";
          path = wallpaper;
          fit_mode = "cover";
        }
      ];
    };
  };
}
