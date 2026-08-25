{ lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    on = {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
                    function()
                      hl.exec_cmd("waybar")
                      hl.exec_cmd("hyprlock")
          	          hl.exec_cmd("swaync")
                    end
        '')
      ];
    };
  };
}
