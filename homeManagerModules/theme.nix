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
      "catppuccin-mocha"
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
        else if theme == "catppuccin-macchiato" then
          {
            package = pkgs.catppuccin-gtk.override {
              variant = "macchiato";
              accents = [ "mauve" ];
            };
            name = "catppuccin-macchiato-mauve-standard";
          }
        else
          {
            package = pkgs.catppuccin-gtk.override {
              variant = "mocha";
              accents = [ "mauve" ];
            };
            name = "catppuccin-mocha-mauve-standard";
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
        else if theme == "catppuccin-macchiato" then
          {
            package = pkgs.catppuccin-papirus-folders.override {
              flavor = "macchiato";
              accent = "mauve";
            };
            name = "Papirus-Dark";
          }
        else
          {
            package = pkgs.catppuccin-papirus-folders.override {
              flavor = "mocha";
              accent = "mauve";
            };
            name = "Papirus-Dark";
          };
    };
  };
}
