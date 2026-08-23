{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    config = {
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "caps:escape";
        kb_rules = "";
        follow_mouse = 1;
        repeat_delay = 200;
        repeat_rate = 35;
        sensitivity = 0;

        touchpad = {
          natural_scroll = true;
        };
      };

      gestures = {
      };
    };
  };
}
