{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    }
    {
      services.getty.autologinUser = "agustin";
      environment.loginShellInit = ''
        if [ "$(tty)" = "/dev/tty1" ]; then
          exec start-hyprland
        fi
      '';
    }
    {
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
    }
  ];
}
