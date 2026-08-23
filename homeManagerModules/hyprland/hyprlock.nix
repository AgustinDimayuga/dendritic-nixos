{ lib, pkgs, ... }:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
      };

      background = [
        {
          monitor = "";
          path = "~/.dotfiles/wallpapers/nixos.png";
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
          color = "rgba(ebdbb2ff)";
          font_size = 110;
          font_family = "CaskaydiaCove Nerd Font";
          position = "0, -200";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "$LAYOUT";
          color = "rgba(928374ff)";
          font_size = 16;
          font_family = "CaskaydiaCove Nerd Font";
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
          outer_color = "rgba(3c3836ff)";
          inner_color = "rgba(282828ff)";
          font_color = "rgba(ebdbb2ff)";
          check_color = "rgba(98971aff)";
          fail_color = "rgba(cc241dff)";
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
