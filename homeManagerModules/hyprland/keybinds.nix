{ pkgs, lib, ... }:

let
  lua = lib.generators.mkLuaInline;

  terminal = "kitty";
  fileManager = "dolphin";
  menu = "rofi -show drun";
  browser = "firefox";

  dsp = {
    exec = cmd: lua ''hl.dsp.exec_cmd("${cmd}")'';
    close = lua "hl.dsp.window.close()";
    exit = lua "hl.dsp.exit()";
    float = lua ''hl.dsp.window.float({ action = "toggle" })'';
    fullscreen = lua "hl.dsp.window.fullscreen()";
    pseudo = lua "hl.dsp.window.pseudo()";
    focus = dir: lua ''hl.dsp.focus({ direction = "${dir}" })'';
    focusWorkspace = ws: lua ''hl.dsp.focus({ workspace = "${toString ws}" })'';
    moveToWorkspace = ws: lua ''hl.dsp.window.move({ workspace = "${toString ws}" })'';
    toggleSpecial = name: lua ''hl.dsp.workspace.toggle_special("${name}")'';
    moveToSpecial = name: lua ''hl.dsp.window.move({ workspace = "special:${name}" })'';
    drag = lua "hl.dsp.window.drag()";
    resize = lua "hl.dsp.window.resize()";
  };

  bind = keys: dispatcher: { _args = [ keys dispatcher ]; };
  bindOpts = keys: dispatcher: opts: { _args = [ keys dispatcher opts ]; };

  workspaceBinds = lib.concatMap (i:
    let key = if i == 10 then "0" else toString i;
    in [
      (bind "SUPER + ${key}" (dsp.focusWorkspace i))
      (bind "SUPER + SHIFT + ${key}" (dsp.moveToWorkspace i))
    ]
  ) (lib.range 1 10);
in
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      (bind "SUPER + U" (dsp.exec "pkill -USR1 waybar"))
	  # Screenshots
	  (bind "ALT + SHIFT + 4" (dsp.exec "hyprshot -m region"))

      (bind "SUPER + Return" (dsp.exec terminal))
      (bind "SUPER + E" (dsp.exec fileManager))
      (bind "SUPER + Space" (dsp.exec menu))
      (bind "SUPER + B" (dsp.exec browser))
      (bind "SUPER + N" (dsp.exec "firefox --new-window https://www.notion.so"))
      (bind "SUPER + M" (dsp.exec "firefox --new-window https://outlook.office.com/"))

      (bind "SUPER + Q" dsp.close)
      (bind "SUPER + P" dsp.exit)
      (bind "SUPER + V" dsp.float)
      (bind "SUPER + F" dsp.fullscreen)
      (bind "SUPER + P" dsp.pseudo)

      (bind "SUPER + H" (dsp.focus "left"))
      (bind "SUPER + L" (dsp.focus "right"))
      (bind "SUPER + K" (dsp.focus "up"))
      (bind "SUPER + J" (dsp.focus "down"))

      (bind "SUPER + S" (dsp.toggleSpecial "magic"))
      (bind "SUPER + SHIFT + S" (dsp.moveToSpecial "magic"))

      (bind "SUPER + mouse_down" (dsp.focusWorkspace "e+1"))
      (bind "SUPER + mouse_up" (dsp.focusWorkspace "e-1"))

      # Mouse drag/resize — folded in from old bindm, using mouse = true option
      (bindOpts "SUPER + mouse:272" dsp.drag { mouse = true; })
      (bindOpts "SUPER + mouse:273" dsp.resize { mouse = true; })

      # Media/volume keys — folded in from old bindel/bindl
      (bindOpts "XF86AudioRaiseVolume" (dsp.exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+") { locked = true; repeating = true; })
      (bindOpts "XF86AudioLowerVolume" (dsp.exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") { locked = true; repeating = true; })
      (bindOpts "XF86AudioMute" (dsp.exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") { locked = true; })
      (bindOpts "XF86AudioMicMute" (dsp.exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") { locked = true; })
      (bindOpts "XF86MonBrightnessUp" (dsp.exec "brightnessctl -e4 -n2 set 5%+") { locked = true; repeating = true; })
      (bindOpts "XF86MonBrightnessDown" (dsp.exec "brightnessctl -e4 -n2 set 5%-") { locked = true; repeating = true; })

      (bindOpts "XF86AudioNext" (dsp.exec "playerctl next") { locked = true; })
      (bindOpts "XF86AudioPause" (dsp.exec "playerctl play-pause") { locked = true; })
      (bindOpts "XF86AudioPlay" (dsp.exec "playerctl play-pause") { locked = true; })
      (bindOpts "XF86AudioPrev" (dsp.exec "playerctl previous") { locked = true; })
    ] ++ workspaceBinds;
  };
}
