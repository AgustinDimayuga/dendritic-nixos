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
            gaps_in = 8;
            gaps_out = 14;
            border_size = 1;
            resize_on_border = false;
            allow_tearing = false;
            layout = "dwindle";
          };

          decoration = {
            rounding = 20;
            rounding_power = 7;
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
              enabled = true;
              range = 20;
              render_power = 30;
              color = "rgb(1B1B1B)";
            };

            blur = {
              enabled = true;
              brightness = 0.8;
              contrast = 2;
              noise = 0;
              vibrancy = 0.35;
              vibrancy_darkness = 0.35;

              size = 13;
              passes = 2;
              new_optimizations = true;
              special = false;
            };
          };
          animations = {
            enabled = true;
          };

          dwindle = {
            preserve_split = true;
          };

          scrolling = {
            column_width = 0.65;
            focus_fit_method = 1;
            explicit_column_widths = "0.65, 1.0";
            fullscreen_on_one_column = true;
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
          # springs for movement
          {
            _args = [
              "md3_spatial_fast"
              {
                type = "spring";
                mass = 1;
                stiffness = 600;
                dampening = 49;
              }
            ];
          }
          {
            _args = [
              "md3_spatial_default"
              {
                type = "spring";
                mass = 1;
                stiffness = 300;
                dampening = 30;
              }
            ];
          }
          {
            _args = [
              "md3_spatial_slow"
              {
                type = "spring";
                mass = 1;
                stiffness = 160;
                dampening = 25;
              }
            ];
          }

          # springs for fades and other effects
          {
            _args = [
              "md3_effects_fast"
              {
                type = "spring";
                mass = 1;
                stiffness = 3800;
                dampening = 123;
              }
            ];
          }
          {
            _args = [
              "md3_effects_default"
              {
                type = "spring";
                mass = 1;
                stiffness = 1600;
                dampening = 80;
              }
            ];
          }
          {
            _args = [
              "md3_effects_slow"
              {
                type = "spring";
                mass = 1;
                stiffness = 800;
                dampening = 57;
              }
            ];
          }

          # beziers for layers
          {
            _args = [
              "md3_standard"
              {
                type = "bezier";
                points = lib.generators.mkLuaInline "{ {0.2, 0.0}, {0.0, 1.0} }";
              }
            ];
          }
          {
            _args = [
              "md3_emphasized_accel"
              {
                type = "bezier";
                points = lib.generators.mkLuaInline "{ {0.3, 0.0}, {0.8, 0.15} }";
              }
            ];
          }
        ];

        animation = [
          {
            leaf = "windows";
            enabled = true;
            speed = 5;
            spring = "md3_spatial_default";
          }
          {
            leaf = "windowsIn";
            enabled = true;
            speed = 5;
            spring = "md3_spatial_default";
            style = "popin 92%";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 2;
            spring = "md3_spatial_default";
            style = "popin 92%";
          }
          {
            leaf = "windowsMove";
            enabled = true;
            speed = 5;
            spring = "md3_spatial_default";
          }

          {
            leaf = "layers";
            enabled = true;
            speed = 3;
            bezier = "md3_standard";
            style = "fade";
          }
          {
            leaf = "layersIn";
            enabled = true;
            speed = 3;
            bezier = "md3_standard";
            style = "fade";
          }
          {
            leaf = "layersOut";
            enabled = true;
            speed = 2.5;
            bezier = "md3_emphasized_accel";
            style = "fade";
          }

          {
            leaf = "fade";
            enabled = true;
            speed = 2;
            spring = "md3_effects_default";
          }
          {
            leaf = "fadeOut";
            enabled = true;
            speed = 2;
            spring = "md3_spatial_default";
          }

          {
            leaf = "workspaces";
            enabled = true;
            speed = 5;
            spring = "md3_spatial_default";
            style = "slide";
          }
          {
            leaf = "specialWorkspace";
            enabled = true;
            speed = 3.5;
            spring = "md3_spatial_default";
            style = "slidevert";
          }
        ];
      };
    }

    # Dracula theme — border colors
    (lib.mkIf (theme == "dracula") {
      wayland.windowManager.hyprland.settings.config.general = {
        col = {
          active_border = "rgb(45403d)";
          inactive_border = "rgba(45403d99)";
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

    # Catppuccin Macchiato theme — border colors
    (lib.mkIf (theme == "catppuccin-macchiato") {
      wayland.windowManager.hyprland.settings.config.general = {
        col = {
          # active_border = "rgb(b7bdf8)";
          # inactive_border = "rgba(6e738d99)";

          active_border = "rgb(45403d)";
          inactive_border = "rgba(45403d99)";
        };
      };
    })

  ];
}
