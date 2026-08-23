{ config, lib, pkgs, ... }:

let
  theme = config.theme;

  draculaStyle = ''
    * {
      border: none;
      border-radius: 0px;
      font-family: MonoLisa Variable;
      font-weight: bold;
      font-size: 15px;
      min-height: 0;
    }

    #custom-calcurse {
      background: #44475a;
      color: #f8f8f2;
      padding: 0 0.6em;
      margin: 4px;
      border-radius: 6px;
    }

    window#waybar {
      background: #282a36;
      color: #f8f8f2;
    }

    tooltip {
      background: #21222c;
      border-radius: 10px;
      border-width: 2px;
      border-style: solid;
      border-color: #282a36;
    }

    #workspaces button {
      padding: 0 0.4em;
      color: #6272a4;
      border-radius: 6px;
      margin-right: 2px;
      margin-left: 2px;
      margin-top: 2px;
      margin-bottom: 2px;
    }

    #workspaces button.active {
      color: #f8f8f2;
      background: #44475a;
    }

    #workspaces button.focused {
      color: #f8f8f2;
      background: #44475a;
    }

    #workspaces button.urgent {
      color: #282a36;
      background: #ff5555;
    }

    #workspaces button:hover {
      background: #3e4452;
      color: #bd93f9;
    }

    #custom-power,
    #date,
    #backlight,
    #idle_inhibitor,
    #pulseaudio,
    #network,
    #workspaces,
    #mpd,
    #temperature,
    #clock,
    #tray,
    #battery {
      background: #44475a;
      padding: 0 0.5em;
      margin-right: 4px;
      margin-left: 4px;
      margin-top: 4px;
      margin-bottom: 4px;
      border-radius: 6px;
    }

    #tray {
      margin-right: 6px;
    }

    #network {
      margin-right: 6px;
    }

    #pulseaudio {
      margin-right: 6px;
    }

    #custom-power {
      color: #ff5555;
      background: #44475a;
    }

    #clock {
      margin-right: 6px;
    }

    #mpd {
      background: #44475a;
      background-image: linear-gradient(62deg, #44475a 0%, #3e4452 100%);
      color: #f8f8f2;
    }

    #mpd.playing {
      background: #44475a;
      background-image: linear-gradient(
        62deg,
        #44475a 0%,
        rgba(80, 250, 123, 0) 100%
      );
      color: #50fa7b;
    }

    #mpd.paused {
      background: #44475a;
      background-image: linear-gradient(
        62deg,
        #44475a 0%,
        rgba(255, 85, 85, 0) 100%
      );
      color: #ff79c6;
    }

    #taskbar {
      background: #282a36;
      padding: 0 0.6em;
      margin-right: 10px;
      margin-left: 4px;
      margin-top: 4px;
      margin-bottom: 4px;
      border-radius: 6px;
      color: #f8f8f2;
    }

    #taskbar button {
      border-radius: 6px;
      background: #44475a;
      color: #6272a4;
      margin-right: 6px;
    }

    #taskbar button.minimized {
      border-radius: 6px;
      background: #44475a;
      color: #6272a4;
    }

    #taskbar button.active {
      border-radius: 6px;
      background: #44475a;
      color: #bd93f9;
    }

    @keyframes gradient {
      0% { background-position: 0% 50%; }
      50% { background-position: 100% 30%; }
      100% { background-position: 0% 50%; }
    }

    @keyframes gradient_f {
      0% { background-position: 0% 200%; }
      50% { background-position: 200% 0%; }
      100% { background-position: 400% 200%; }
    }

    @keyframes gradient_f_nh {
      0% { background-position: 0% 200%; }
      100% { background-position: 200% 200%; }
    }

    #custom-music.low {
      background: rgb(148, 226, 213);
      background: linear-gradient(
        52deg,
        rgba(148, 226, 213, 1) 0%,
        rgba(137, 220, 235, 1) 19%,
        rgba(116, 199, 236, 1) 43%,
        rgba(137, 180, 250, 1) 56%,
        rgba(180, 190, 254, 1) 80%,
        rgba(186, 187, 241, 1) 100%
      );
      background-size: 300% 300%;
      text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
      animation: gradient 15s ease infinite;
      font-weight: bold;
      color: #ffffff;
    }

    #custom-music.random {
      background: rgb(148, 226, 213);
      background: radial-gradient(
        circle,
        rgba(148, 226, 213, 1) 0%,
        rgba(156, 227, 191, 1) 21%,
        rgba(249, 226, 175, 1) 34%,
        rgba(158, 227, 186, 1) 35%,
        rgba(163, 227, 169, 1) 59%,
        rgba(148, 226, 213, 1) 74%,
        rgba(164, 227, 167, 1) 74%,
        rgba(166, 227, 161, 1) 100%
      );
      background-size: 400% 400%;
      animation: gradient_f 4s ease infinite;
      text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
      font-weight: bold;
      color: #ffffff;
    }

    #custom-music.critical {
      background: rgb(235, 160, 172);
      background: linear-gradient(
        52deg,
        rgba(235, 160, 172, 1) 0%,
        rgba(243, 139, 168, 1) 30%,
        rgba(231, 130, 132, 1) 48%,
        rgba(250, 179, 135, 1) 77%,
        rgba(249, 226, 175, 1) 100%
      );
      background-size: 300% 300%;
      animation: gradient 15s cubic-bezier(0.55, -0.68, 0.48, 1.68) infinite;
      text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
      font-weight: bold;
      color: #ffffff;
    }

    #custom-music.Playing {
      background: radial-gradient(
        circle,
        rgba(80, 250, 123, 120) 0%,
        rgba(68, 71, 90, 1) 15%,
        rgba(80, 250, 123, 120) 75%,
        rgba(80, 250, 123, 120) 100%
      );
      background-size: 400% 400%;
      animation: gradient_f 9s cubic-bezier(0.72, 0.39, 0.21, 1) infinite;
      text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
      font-weight: bold;
      color: #f8f8f2;
    }

    #custom-music.Paused,
    #custom-music.Stopped {
      background: #6272a4;
    }
  '';

  gruvboxStyle = ''
    * {
      border: none;
      border-radius: 0px;
      font-family: JetBrainsMono Nerd Font;
      font-weight: bold;
      font-size: 15px;
      min-height: 0;
    }

    #custom-calcurse {
      background: #32302f;
      color: #ebdbb2;
      padding: 0 0.6em;
      margin: 4px;
      border-radius: 6px;
    }
    window#waybar {
      background: #1d2021;
      color: #ebdbb2;
    }

    tooltip {
      background: #282828;
      border-radius: 10px;
      border-width: 2px;
      border-style: solid;
      border-color: #1d2021;
    }
    #workspaces button {
      padding: 0 0.4em;
      color: #504945;
      border-radius: 6px;
      margin-right: 2px;
      margin-left: 2px;
      margin-top: 2px;
      margin-bottom: 2px;
    }

    #workspaces button.active {
      color: #ebdbb2;
      background: #4e635b;
    }

    #workspaces button.focused {
      color: #ebdbb2;
      background: #4e635b;
    }

    #workspaces button.urgent {
      color: #1d2021;
      background: #fb4934;
    }

    #workspaces button:hover {
      background: #4e635b;
      color: #ebdbb2;
    }

    #custom-power,
    #date,
    #backlight,
    #idle_inhibitor,
    #pulseaudio,
    #network,
    #workspaces,
    #mpd,
    #temperature,
    #clock,
    #tray,
    #battery {
      background: #32302f;
      padding: 0 0.5em;
      margin-right: 4px;
      margin-left: 4px;
      margin-top: 4px;
      margin-bottom: 4px;
      border-radius: 6px;
    }

    #tray {
      margin-right: 6px;
    }

    #network {
      color: #ebdbb2;
      margin-right: 6px;
    }

    #pulseaudio {
      margin-right: 6px;
      color: #ebdbb2;
    }

    #custom-power {
      color: #fb4934;
      background: #32302f;
    }

    #clock {
      color: #ebdbb2;
      margin-right: 6px;
    }

    #mpd {
      background: #32302f;
      background-image: linear-gradient(62deg, #32302f 0%, #3d3d3d 100%);
      color: #ebdbb2;
    }

    #mpd.playing {
      background: #32302f;
      background-image: linear-gradient(62deg, #32302f 0%, rgba(184,187,38,00) 100%);
      color: #ebdbb2;
    }

    #mpd.paused {
      background: #32302f;
      background-image: linear-gradient(62deg, #32302f 0%, rgba(251,73,52,00) 100%);
      color: #ebdbb2;
    }

    #taskbar {
      background: #1d2021;
      padding: 0 0.6em;
      margin-right: 10px;
      margin-left: 4px;
      margin-top: 4px;
      margin-bottom: 4px;
      border-radius: 6px;
      color: #ebdbb2;
    }

    #taskbar button {
      border-radius: 6px;
      background: #32302f;
      color: #a89984;
      margin-right: 6px;
    }

    #taskbar button.minimized {
      border-radius: 6px;
      background: #32302f;
      color: #a89984;
    }

    #taskbar button.active {
      border-radius: 6px;
      background: #4e635b;
      color: #ebdbb2;
    }

    @keyframes gradient {
      0% { background-position: 0% 50%; }
      50% { background-position: 100% 30%; }
      100% { background-position: 0% 50%; }
    }

    @keyframes gradient_f {
      0% { background-position: 0% 200%; }
      50% { background-position: 200% 0%; }
      100% { background-position: 400% 200%; }
    }

    @keyframes gradient_f_nh {
      0% { background-position: 0% 200%; }
      100% { background-position: 200% 200%; }
    }

    #custom-music.low {
      background: rgb(148, 226, 213);
      background: linear-gradient(52deg, rgba(148, 226, 213, 1) 0%, rgba(137, 220, 235, 1) 19%, rgba(116, 199, 236, 1) 43%, rgba(137, 180, 250, 1) 56%, rgba(180, 190, 254, 1) 80%, rgba(186, 187, 241, 1) 100%);
      background-size: 300% 300%;
      text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
      animation: gradient 15s ease infinite;
      font-weight: bold;
      color: #fff;
    }

    #custom-music.random {
      background: rgb(148, 226, 213);
      background: radial-gradient(circle, rgba(148, 226, 213, 1) 0%, rgba(156, 227, 191, 1) 21%, rgba(249, 226, 175, 1) 34%, rgba(158, 227, 186, 1) 35%, rgba(163, 227, 169, 1) 59%, rgba(148, 226, 213, 1) 74%, rgba(164, 227, 167, 1) 74%, rgba(166, 227, 161, 1) 100%);
      background-size: 400% 400%;
      animation: gradient_f 4s ease infinite;
      text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
      font-weight: bold;
      color: #fff;
    }

    #custom-music.critical {
      background: rgb(235, 160, 172);
      background: linear-gradient(52deg, rgba(235, 160, 172, 1) 0%, rgba(243, 139, 168, 1) 30%, rgba(231, 130, 132, 1) 48%, rgba(250, 179, 135, 1) 77%, rgba(249, 226, 175, 1) 100%);
      background-size: 300% 300%;
      animation: gradient 15s cubic-bezier(.55, -0.68, .48, 1.68) infinite;
      text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
      font-weight: bold;
      color: #fff;
    }

    #custom-music.Playing {
      background: rgb(104, 157, 106);
      background: radial-gradient(circle, rgba(104, 157, 106, 120) 0%,rgba(78,99,91,1) 15%, rgba(66, 123, 88, 120) 25%,rgba(66,123,88,120) 75%, rgba(104,157,106,120) 100%);
      background-size: 400% 400%;
      animation: gradient_f 9s cubic-bezier(.72, .39, .21, 1) infinite;
      text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
      font-weight: bold;
      color: #ebdbb2;
    }

    #custom-music.Paused,
    #custom-music.Stopped {
      background: #427b58;
    }
  '';
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;

        "modules-left" = [
          "hyprland/workspaces"
          "custom/calcurse"
        ];

        "modules-center" = [
          "clock"
        ];

        "modules-right" = [
          "tray"
          "idle_inhibitor"
          "temperature"
          "backlight"
          "pulseaudio"
          "battery"
        ];

        "hyprland/taskbar" = {
          format = "{icon} {app_id}";
          "icon-size" = 14;
          "icon-theme" = "Papirus";
          "tooltip-format" = "{title}";
          "on-click" = "activate";
          "on-click-middle" = "close";
          "on-click-right" = "minimize-raise";
          "ignore-list" = [ "kitty" ];
          "app_ids-mapping" = { };
        };

        "hyprland/workspaces" = {
          "disable-scroll" = true;
          "sort-by-number" = true;
          "on-click" = "activate";
        };

        tray = {
          "icon-size" = 16;
          spacing = 10;
        };

        "clock#time" = {
          interval = 1;
          format = "  {:%H:%M:%S} ";
          tooltip = false;
        };

        "clock#date" = {
          interval = 10;
          format = "  {:%e %b %y} ";
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        clock = {
          interval = 1;
          format = "{:%I:%M %p  %A %b %d}";
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          tooltip = true;
        };

        "custom/music" = {
          format = "{icon}{}";
          "format-icons" = {
            Playing = " ";
            Paused = "󰏥 ";
            Stopped = "&#x202d;󰙦 ";
          };
          escape = true;
          tooltip = true;
          exec = "~/.config/waybar/scripts/caway.sh -e";
          "return-type" = "json";
          "on-click" = "playerctl play-pause";
          "on-scroll-up" = "playerctl previous";
          "on-scroll-down" = "playerctl next";
          "on-click-right" = "g4music";
          "max-length" = 35;
        };

        network = {
          interval = 1;
          "format-wifi" = "󰒢";
          "format-ethernet" = "󰈀  {ifname}";
          "format-linked" = "󰒢 {essid} (No IP)";
          "format-disconnected" = "󰒢 Disconnected";
          "format-alt" = "{ifname} ({ipaddr})";
          "on-click-right" = "exec nm-connection-editor";
        };

        pulseaudio = {
          "scroll-step" = 1;
          format = "{icon} {volume}%";
          "format-muted" = "󰖁 Muted";
          "format-icons" = {
            headphone = "  ";
            "hands-free" = "  ";
            headset = "  ";
            phone = "  ";
            portable = "  ";
            car = "  ";
            default = [ "" "" "" ];
          };
          states = {
            warning = 85;
          };
          "on-scroll-up" = "volume.sh --dec";
          "on-scroll-down" = "volume.sh --inc";
          "smooth-scrolling-threshold" = 5;
          tooltip = false;
          "on-click" = "volume.sh --toggle";
          "on-click-right" = "pavucontrol";
        };

        idle_inhibitor = {
          format = "{icon}";
          "format-icons" = {
            activated = "󰈈 ";
            deactivated = "󰈉 ";
          };
          tooltip = false;
        };

        "custom/calcurse" = {
          format = "{}";
          exec = "~/.config/calcurse/countdown.sh";
          interval = 10;
          tooltip = false;
        };

        temperature = {
          "hwmon-path" = "/sys/class/hwmon/hwmon3/temp1_input";
          "critical-threshold" = 85;
          interval = 1;
          format = "<span font='12' rise='-2500'>󰔏</span> {temperatureC}°C";
          tooltip = false;
        };

        backlight = {
          format = "󰃠 {percent}%";
          "on-scroll-up" = "brightness.sh --dec";
          "on-scroll-down" = "brightness.sh --inc";
          "smooth-scrolling-threshold" = 5;
        };

        battery = {
          interval = 10;
          states = {
            warning = 20;
            critical = 10;
          };
          format = "{icon} {capacity}%";
          "format-icons" = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂁" "󰂂" "󰁹" ];
          "format-full" = "{icon} {capacity}%";
          "format-charging" = "󰂄 {capacity}%";
          tooltip = true;
        };

        "custom/power" = {
          format = " ⏻ ";
          "on-click" = "~/.config/hypr/scripts/rofi-power";
        };

        "custom/playerctl" = {
          format = "<span font='10' rise='-1000'>󰎈</span>  {} ";
          "format-icons" = {
            Playing = "󰐊";
            Paused = "󰏤";
          };
          escape = true;
          "return-type" = "json";
          "max-length" = 40;
          "on-click" = "playerctl play-pause";
          "on-click-right" = "playerctl stop";
          "on-click-middle" = "killall spotify";
          "smooth-scrolling-threshold" = 10;
          "on-scroll-up" = "playerctl next";
          "on-scroll-down" = "playerctl previous";
          exec = ''playerctl -a metadata --format '{"text": "{{markup_escape(title)}} - {{artist}}", "tooltip": "{{status}} : {{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
        };

        mpd = {
          format = " {stateIcon}   {artist} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})    ";
          "format-disconnected" = " Disconnected  ";
          "format-stopped" = " Stopped  ";
          interval = 2;
          "consume-icons" = {
            on = " ";
          };
          "random-icons" = {
            off = ''<span color="#fb4934"> </span>'';
            on = " ";
          };
          "repeat-icons" = {
            on = " ";
          };
          "single-icons" = {
            on = "1 ";
          };
          "state-icons" = {
            paused = "";
            playing = "";
          };
          "on-click" = "playerctl play-pause";
          "on-scroll-up" = "playerctl next";
          "on-scroll-down" = "playerctl previous";
          "tooltip-format" = "MPD (connected)";
          "tooltip-format-disconnected" = "MPD (disconnected)";
        };
      };
    };

    style = if theme == "dracula" then draculaStyle else gruvboxStyle;
  };
}
