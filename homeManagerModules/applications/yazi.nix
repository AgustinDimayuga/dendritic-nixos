{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  theme = config.theme;

  flavorName = {
    dracula = "dracula";
    gruvbox = "gruvbox-dark";
    catppuccin-macchiato = "catppuccin-macchiato";
    catppuccin-mocha = "catppuccin-mocha";
    gruvbox-light = "gruvbox-light";
  };
in
{
  xdg.configFile."yazi/flavors/dracula.yazi".source = "${inputs.yazi-flavors}/dracula.yazi";
  xdg.configFile."yazi/flavors/gruvbox-dark.yazi".source = inputs.yazi-gruvbox-flavor;
  xdg.configFile."yazi/flavors/catppuccin-macchiato.yazi".source =
    "${inputs.yazi-flavors}/catppuccin-macchiato.yazi";
  xdg.configFile."yazi/flavors/catppuccin-mocha.yazi".source =
    "${inputs.yazi-flavors}/catppuccin-mocha.yazi";
  xdg.configFile."yazi/flavors/gruvbox-light.yazi".source = inputs.yazi-gruvbox-light-flavor;

  programs.yazi = {
    enable = true;
    package = pkgs.yazi;

    settings = {
      opener = {
        zathura = [
          {
            run = ''zathura "$@"'';
            orphan = true;
            for = "unix";
          }
        ];
      };

      open = {
        prepend_rules = [
          {
            url = "*.pdf";
            use = "zathura";
          }
        ];
      };
    };

    theme = {
      flavor = {
        # set both `dark` and `light` to the active flavor so yazi always uses
        # it regardless of whether it detects a dark or light terminal
        # background (only relevant now that gruvbox-light is light).
        dark = flavorName.${theme};
        light = flavorName.${theme};
      };
    };
  };
}
