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
  config = lib.mkMerge [

    # Shared base — look and feel settings that don't vary by theme
    {
      wayland.windowManager.hyprland.settings = {
        config = {
          general = {
            gaps_in = 5;
            gaps_out = 8;
            border_size = 2;
            resize_on_border = false;
            allow_tearing = false;
            layout = "dwindle";
          };

          decoration = {
            rounding = 10;
            rounding_power = 2;
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = "rgb(1B1B1B)";
            };

            blur = {
              enabled = true;
              size = 1;
              passes = 3;
              vibrancy = 0.1696;
            };
          };

          animations = {
            enabled = true;
          };

          dwindle = {
            preserve_split = true;
          };

          master = {
            new_status = "master";
          };

          misc = {
            force_default_wallpaper = -1;
            disable_hyprland_logo = false;
          };
        };

        curve = [
          {
            _args = [
              "easeOutQuint"
              {
                type = "bezier";
                points = lib.generators.mkLuaInline "{ {0.23, 1}, {0.32, 1} }";
              }
            ];
          }
          {
            _args = [
              "easeInOutCubic"
              {
                type = "bezier";
                points = lib.generators.mkLuaInline "{ {0.65, 0.05}, {0.36, 1} }";
              }
            ];
          }
          {
            _args = [
              "linear"
              {
                type = "bezier";
                points = lib.generators.mkLuaInline "{ {0, 0}, {1, 1} }";
              }
            ];
          }
          {
            _args = [
              "almostLinear"
              {
                type = "bezier";
                points = lib.generators.mkLuaInline "{ {0.5, 0.5}, {0.75, 1} }";
              }
            ];
          }
          {
            _args = [
              "quick"
              {
                type = "bezier";
                points = lib.generators.mkLuaInline "{ {0.15, 0}, {0.1, 1} }";
              }
            ];
          }
        ];

        animation = [
          {
            leaf = "global";
            enabled = true;
            speed = 10;
            bezier = "linear";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 5.39;
            bezier = "easeOutQuint";
          }
          {
            leaf = "windows";
            enabled = true;
            speed = 4.79;
            bezier = "easeOutQuint";
          }
          {
            leaf = "windowsIn";
            enabled = true;
            speed = 4.1;
            bezier = "easeOutQuint";
            style = "popin 87%";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 1.49;
            bezier = "linear";
            style = "popin 87%";
          }
          {
            leaf = "fadeIn";
            enabled = true;
            speed = 1.73;
            bezier = "almostLinear";
          }
          {
            leaf = "fadeOut";
            enabled = true;
            speed = 1.46;
            bezier = "almostLinear";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 3.03;
            bezier = "quick";
          }
          {
            leaf = "layers";
            enabled = true;
            speed = 3.81;
            bezier = "easeOutQuint";
          }
          {
            leaf = "layersIn";
            enabled = true;
            speed = 4;
            bezier = "easeOutQuint";
            style = "fade";
          }
          {
            leaf = "layersOut";
            enabled = true;
            speed = 1.5;
            bezier = "linear";
            style = "fade";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 1.94;
            bezier = "almostLinear";
            style = "fade";
          }
          {
            leaf = "workspacesIn";
            enabled = true;
            speed = 1.21;
            bezier = "almostLinear";
            style = "fade";
          }
          {
            leaf = "workspacesOut";
            enabled = true;
            speed = 1.94;
            bezier = "almostLinear";
            style = "fade";
          }
        ];
      };
    }

    # Dracula theme — border colors
    (lib.mkIf (theme == "dracula") {
      wayland.windowManager.hyprland.settings.config.general = {
        col = {
          active_border = "rgb(ff79c6)";
          inactive_border = "rgb(44475a)";
        };
      };
    })

    # Gruvbox theme — border colors
    (lib.mkIf (theme == "gruvbox") {
      wayland.windowManager.hyprland.settings.config.general = {
        col = {
          active_border = "rgb(ebdbb2)";
          inactive_border = "rgb(0a0c0f)";
        };
      };
    })

  ];
}
