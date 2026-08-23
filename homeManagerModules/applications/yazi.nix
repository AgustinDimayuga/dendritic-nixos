{ config, lib, pkgs, inputs, ... }:

let
  theme = config.theme;

  flavorName = {
    dracula = "dracula";
    gruvbox = "gruvbox-dark";
  };
in
{
  xdg.configFile."yazi/flavors/dracula.yazi".source = "${inputs.yazi-flavors}/dracula.yazi";
  xdg.configFile."yazi/flavors/gruvbox-dark.yazi".source = inputs.yazi-gruvbox-flavor;

  programs.yazi = {
    enable = true;
    package = pkgs.yazi;

    settings = {
      opener = {
        zathura = [
          { run = ''zathura "$@"''; orphan = true; for = "unix"; }
        ];
      };

      open = {
        prepend_rules = [
          { url = "*.pdf"; use = "zathura"; }
        ];
      };
    };

    theme = {
      flavor = {
        dark = flavorName.${theme};
      };
    };
  };
}
