{ config, lib, pkgs, ... }:

let
  theme = config.theme;
in
{
  config = lib.mkMerge [

    # Shared base — always applied regardless of theme
    {
      programs.kitty = {
        enable = true;
        font = {
          name = "MonoLisa Variable";
          size = 12;
        };
        settings = {
          background_opacity = 1;
          sync_to_monitor = true;
        };
        keybindings = {
          "ctrl+c" = "copy_or_interrupt";
          "ctrl+v" = "paste_from_clipboard";
        };
      };
    }

    # Dracula theme
    (lib.mkIf (theme == "dracula") {
      programs.kitty.settings = {
        cursor = "#f8f8f2";
        cursor_text_color = "background";
        url_color = "#8be9fd";
        visual_bell_color = "#8be9fd";
        bell_border_color = "#8be9fd";
        active_border_color = "#f8f8f2";
        inactive_border_color = "#6272a4";
        foreground = "#f8f8f2";
        background = "#282a36";
        selection_foreground = "#ffffff";
        selection_background = "#44475a";
        active_tab_foreground = "#282a36";
        active_tab_background = "#f8f8f2";
        inactive_tab_foreground = "#282a36";
        inactive_tab_background = "#6272a4";
        # black
        color0 = "#21222c";
        color8 = "#6272a4";
        # red
        color1 = "#ff5555";
        color9 = "#ff6e6e";
        # green
        color2 = "#50fa7b";
        color10 = "#69ff94";
        # yellow
        color3 = "#f1fa8c";
        color11 = "#ffffa5";
        # blue
        color4 = "#bd93f9";
        color12 = "#d6acff";
        # purple
        color5 = "#ff79c6";
        color13 = "#ff92df";
        # aqua
        color6 = "#8be9fd";
        color14 = "#a4ffff";
        # white
        color7 = "#f8f8f2";
        color15 = "#ffffff";
      };
    })

    # Gruvbox theme
    (lib.mkIf (theme == "gruvbox") {
      programs.kitty.settings = {
        cursor = "#928374";
        cursor_text_color = "background";
        url_color = "#83a598";
        visual_bell_color = "#8ec07c";
        bell_border_color = "#8ec07c";
        active_border_color = "#d3869b";
        inactive_border_color = "#665c54";
        foreground = "#ebdbb2";
        background = "#282828";
        selection_foreground = "#928374";
        selection_background = "#ebdbb2";
        active_tab_foreground = "#fbf1c7";
        active_tab_background = "#665c54";
        inactive_tab_foreground = "#a89984";
        inactive_tab_background = "#3c3836";
        # black
        color0 = "#665c54";
        color8 = "#7c6f64";
        # red
        color1 = "#cc241d";
        color9 = "#fb4934";
        # green
        color2 = "#98971a";
        color10 = "#b8bb26";
        # yellow
        color3 = "#d79921";
        color11 = "#fabd2f";
        # blue
        color4 = "#458588";
        color12 = "#83a598";
        # purple
        color5 = "#b16286";
        color13 = "#d3869b";
        # aqua
        color6 = "#689d6a";
        color14 = "#8ec07c";
        # white
        color7 = "#a89984";
        color15 = "#bdae93";
      };
    })

  ];
}
