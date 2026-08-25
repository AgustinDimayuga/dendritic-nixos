{
  config,
  pkgs,
  inputs,
  ...
}:
let
  theme = config.theme;
  colorScheme = if theme == "dracula" then "dracula" else "gruvbox-material-dark";
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
