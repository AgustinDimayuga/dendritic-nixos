{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.theme;

  draculaColors = {
    "notification-error-bg" = "rgba(255,85,85,1)";
    "notification-error-fg" = "rgba(248,248,242,1)";
    "notification-warning-bg" = "rgba(255,184,108,1)";
    "notification-warning-fg" = "rgba(68,71,90,1)";
    "notification-bg" = "rgba(40,42,54,1)";
    "notification-fg" = "rgba(248,248,242,1)";
    "completion-bg" = "rgba(40,42,54,1)";
    "completion-fg" = "rgba(98,114,164,1)";
    "completion-group-bg" = "rgba(40,42,54,1)";
    "completion-group-fg" = "rgba(98,114,164,1)";
    "completion-highlight-bg" = "rgba(68,71,90,1)";
    "completion-highlight-fg" = "rgba(248,248,242,1)";
    "index-bg" = "rgba(40,42,54,1)";
    "index-fg" = "rgba(248,248,242,1)";
    "index-active-bg" = "rgba(68,71,90,1)";
    "index-active-fg" = "rgba(248,248,242,1)";
    "inputbar-bg" = "rgba(40,42,54,1)";
    "inputbar-fg" = "rgba(248,248,242,1)";
    "statusbar-bg" = "rgba(40,42,54,1)";
    "statusbar-fg" = "rgba(248,248,242,1)";
    "highlight-color" = "rgba(255,184,108,0.5)";
    "highlight-active-color" = "rgba(255,121,198,0.5)";
    "default-bg" = "rgba(40,42,54,1)";
    "default-fg" = "rgba(248,248,242,1)";
    "render-loading-fg" = "rgba(40,42,54,1)";
    "render-loading-bg" = "rgba(248,248,242,1)";
    "recolor-lightcolor" = "rgba(40,42,54,1)";
    "recolor-darkcolor" = "rgba(248,248,242,1)";
  };

  gruvboxColors = {
    "notification-error-bg" = "#282828";
    "notification-error-fg" = "#fb4934";
    "notification-warning-bg" = "#282828";
    "notification-warning-fg" = "#fabd2f";
    "notification-bg" = "#282828";
    "notification-fg" = "#b8bb26";
    "completion-bg" = "#504945";
    "completion-fg" = "#ebdbb2";
    "completion-group-bg" = "#3c3836";
    "completion-group-fg" = "#928374";
    "completion-highlight-bg" = "#83a598";
    "completion-highlight-fg" = "#504945";
    "index-bg" = "#282828";
    "index-fg" = "#ebdbb2";
    "index-active-bg" = "#8ec07c";
    "index-active-fg" = "#1b1b1b";
    "inputbar-bg" = "#1b1b1b";
    "inputbar-fg" = "#458588";
    "statusbar-bg" = "#282828";
    "statusbar-fg" = "#b16286";
    "highlight-color" = "rgba(249, 188, 47, 0.5)";
    "highlight-active-color" = "rgba(253, 128, 25, 0.5)";
    "default-bg" = "#282828";
    "default-fg" = "#ebdbb2";
    "render-loading-bg" = "#1b1b1b";
    "render-loading-fg" = "#ebdbb2";
    "recolor-lightcolor" = "#1b1b1b";
    "recolor-darkcolor" = "#ebdbb2";
  };

  colors = if theme == "dracula" then draculaColors else gruvboxColors;
in
{
  programs.zathura = {
    enable = true;

    options = colors // {
      "window-title-basename" = true;
      "selection-clipboard" = "clipboard";
      "render-loading" = true;
      "recolor" = true;
      "recolor-keephue" = true;
      "adjust-open" = "width";
      "statusbar-h-padding" = 0;
      "statusbar-v-padding" = 0;
      "statusbar-basename" = true;
      "page-padding" = 5;
      "font" = "IBM Plex Sans Arabic";
      "show-signature-information" = true;
    };
  };
}
