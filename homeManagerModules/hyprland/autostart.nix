{ lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    on = [
      {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("waybar")
              hl.exec_cmd("sh -c 'gnome-keyring-daemon --start --components=secrets >/dev/null; exec hyprlock'")
              hl.exec_cmd("swaync")
              hl.exec_cmd("osd-daemon")
            end
          '')
        ];
      }
    ];
  };
}
