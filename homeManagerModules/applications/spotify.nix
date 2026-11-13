{
  config,
  pkgs,
  inputs,
  ...
}:
let
  theme = config.theme;
  colorScheme =
    if theme == "dracula" then
      "dracula"
    else if theme == "catppuccin-macchiato" then
      "catppuccin-macchiato"
    else if theme == "catppuccin-mocha" then
      "catppuccin-mocha"
    else if theme == "gruvbox-light" then
      # spicetify-colorful has no light Gruvbox scheme, so reuse the dark one.
      "gruvbox-material-dark"
    else
      "gruvbox-material-dark";
in
{
  programs.spicetify = {
    enable = true;
    theme = {
      name = "colorful";
      src = "${inputs.spicetify-colorful}/src";
      injectCss = true;
      injectThemeJs = true;
      replaceColors = true;
      homeConfig = true;
      overwriteAssets = false;
    };
    colorScheme = colorScheme;
  };
}
