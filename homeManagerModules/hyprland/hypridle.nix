{
  config,
  lib,
  pkgs,
  ...
}:

let
  baseListeners = [
    {
      timeout = 180;
      on-timeout = "brightnessctl -s set 10";
      on-resume = "brightnessctl -r";
    }
    {
      timeout = 300;
      on-timeout = "loginctl lock-session";
    }
    {
      timeout = 330;
      on-timeout = "hyprctl dispatch dpms off";
      on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
    }
  ];

  laptopListeners = [
    {
      timeout = 360;
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
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = baseListeners ++ lib.optionals config.hyprland-laptop.enable laptopListeners;
    };
  };
}
