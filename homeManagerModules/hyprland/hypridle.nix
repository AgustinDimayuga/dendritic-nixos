{
  config,
  lib,
  pkgs,
  ...
}:

let
  testMode = true; # set to false when done testing
  t = test: normal: if testMode then test else normal;

  ddcutil = "${pkgs.ddcutil}/bin/ddcutil";

  baseListeners = [
    {
      timeout = t 15 180;
      # dim laptop panel + external monitor (each one quietly fails if not present)
      on-timeout = "brightnessctl -c backlight -s set 10%; ${ddcutil} setvcp 10 10";
      on-resume = "brightnessctl -c backlight -r; ${ddcutil} setvcp 10 100";
    }
    {
      timeout = t 30 300;
      on-timeout = "loginctl lock-session";
    }
    {
      timeout = t 35 330;
      on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
      on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
    }
  ];

  laptopListeners = [
    {
      timeout = t 45 360;
      on-timeout = "systemctl suspend-then-hibernate";
    }
  ];
in
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        # remove grace if lid close is not properly working
        lock_cmd = "pidof hyprlock || hyprlock --grace 100";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd =
          "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'"
          + lib.optionalString config.hyprland-laptop.enable "; ${lib.getExe config.clamshell.package} hotplug";
      };

      listener = baseListeners ++ lib.optionals config.hyprland-laptop.enable laptopListeners;
    };
  };
}
