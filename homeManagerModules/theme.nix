{ config, lib, pkgs, ... }:

let
  theme = config.theme;
in
{
  options.theme = lib.mkOption {
    type = lib.types.enum [ "dracula" "gruvbox" ];
    default = "dracula";
    description = "Global color theme applied across all themed apps.";
  };

  config = {
    gtk = {
      enable = true;

      theme = if theme == "dracula" then {
        package = pkgs.dracula-theme;
        name = "Dracula";
      } else {
        package = pkgs.gruvbox-gtk-theme;
        name = "Gruvbox";
      };

      iconTheme = if theme == "dracula" then {
        package = pkgs.dracula-icon-theme;
        name = "Dracula";
      } else {
        package = pkgs.gruvbox-dark-icons-gtk;
        name = "Gruvbox-Dark";
      };
    };
  };
}
