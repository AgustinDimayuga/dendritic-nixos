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
    catppuccin-macchiato = ../assets/wallpapers/catppuccin.png;
    catppuccin-mocha = ../assets/wallpapers/catppuccin.png;
  };

  wallpaper = toString wallpaperFile.${theme};

  draculaColors = {
    label = "rgba(f8f8f2ff)";
    labelDim = "rgba(6272a4ff)";
    outer = "rgba(44475aff)";
    inner = "rgba(282a36ff)";
    font = "rgba(f8f8f2ff)";
    check = "rgba(50fa7bff)";
    fail = "rgba(ff5555ff)";
  };

  gruvboxColors = {
    label = "rgba(ebdbb2ff)";
    labelDim = "rgba(928374ff)";
    outer = "rgba(3c3836ff)";
    inner = "rgba(282828ff)";
    font = "rgba(ebdbb2ff)";
    check = "rgba(98971aff)";
    fail = "rgba(cc241dff)";
  };

  catppuccinColors = {
    label = "rgba(cad3f5ff)";
    labelDim = "rgba(a5adcbff)";
    outer = "rgba(b7bdf8ff)";
    inner = "rgba(24273aff)";
    font = "rgba(cad3f5ff)";
    check = "rgba(a6da95ff)";
    fail = "rgba(ed8796ff)";
  };

  catppuccinMochaColors = {
    label = "rgba(cdd6f4ff)";
    labelDim = "rgba(a6adc8ff)";
    outer = "rgba(b4befeff)";
    inner = "rgba(1e1e2eff)";
    font = "rgba(cdd6f4ff)";
    check = "rgba(a6e3a1ff)";
    fail = "rgba(f38ba8ff)";
  };

  c =
    if theme == "dracula" then
      draculaColors
    else if theme == "catppuccin-macchiato" then
      catppuccinColors
    else if theme == "catppuccin-mocha" then
      catppuccinMochaColors
    else
      gruvboxColors;
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
      };

      auth = {
        fingerprint = {
          enabled = true;
        };
      };

      background = [
        {
          monitor = "";
          path = wallpaper;
          blur_passes = 1;
          blur_size = 8;
          noise = 0.015;
          contrast = 0.90;
          brightness = 0.52;
          vibrancy = 0.17;
          vibrancy_darkness = 0.0;
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          color = c.label;
          font_size = 110;
          font_family = "MonoLisaText Trial";
          position = "0, -200";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "$LAYOUT";
          color = c.labelDim;
          font_size = 16;
          font_family = "MonoLisaText Trial";
          position = "0, 320";
          halign = "center";
          valign = "center";
        }
      ];

      "input-field" = [
        {
          monitor = "";
          size = "260, 60";
          outline_thickness = 3;
          outer_color = c.outer;
          inner_color = c.inner;
          font_color = c.font;
          check_color = c.check;
          fail_color = c.fail;
          dots_size = 0.33;
          dots_spacing = 0.18;
          dots_center = false;
          dots_rounding = -1;
          hide_input = false;
          fade_on_empty = true;
          fade_timeout = 900;
          rounding = 12;
          placeholder_text = "<i>••••••••</i>";
          position = "0, 50";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
