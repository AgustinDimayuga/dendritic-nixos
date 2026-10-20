{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.theme;
in
{
  options.theme = lib.mkOption {
    type = lib.types.enum [
      "dracula"
      "gruvbox"
      "catppuccin-macchiato"
    ];
    default = "dracula";
    description = "Global color theme applied across all themed apps.";
  };

  config = {
    gtk = {
      enable = true;

      theme =
        if theme == "dracula" then
          {
            package = pkgs.dracula-theme;
            name = "Dracula";
          }
        else if theme == "gruvbox" then
          {
            package = pkgs.gruvbox-gtk-theme;
            name = "Gruvbox-Dark";
          }
        else
          {
            package = pkgs.catppuccin-gtk.override {
              variant = "macchiato";
              accents = [ "mauve" ];
            };
            name = "catppuccin-macchiato-mauve-standard";
          };

      iconTheme =
        if theme == "dracula" then
          {
            package = pkgs.dracula-icon-theme;
            name = "Dracula";
          }
        else if theme == "gruvbox" then
          {
            package = pkgs.gruvbox-dark-icons-gtk;
            name = "Gruvbox-Dark";
          }
        else
          {
            package = pkgs.catppuccin-papirus-folders.override {
              flavor = "macchiato";
              accent = "mauve";
            };
            name = "Papirus-Dark";
          };
    };
  };
}
