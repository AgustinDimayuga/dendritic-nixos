{
  config,
  lib,
  pkgs,
  ...
}:

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
          size = 14;
        };
        settings = {
          background_opacity = .80;
          sync_to_monitor = true;
          window_padding_width = 25;
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

    # Catppuccin Macchiato theme
    (lib.mkIf (theme == "catppuccin-macchiato") {
      programs.kitty.settings = {
        foreground = "#cad3f5";
        background = "#24273a";
        selection_foreground = "#24273a";
        selection_background = "#f4dbd6";
        cursor = "#f4dbd6";
        cursor_text_color = "#24273a";
        scrollbar_handle_color = "#939ab7";
        scrollbar_track_color = "#494d64";
        url_color = "#f4dbd6";
        visual_bell_color = "#eed49f";
        bell_border_color = "#eed49f";
        active_border_color = "#b7bdf8";
        inactive_border_color = "#6e738d";
        active_tab_foreground = "#181926";
        active_tab_background = "#c6a0f6";
        inactive_tab_foreground = "#cad3f5";
        inactive_tab_background = "#1e2030";
        tab_bar_background = "#181926";
        mark1_foreground = "#24273a";
        mark1_background = "#b7bdf8";
        mark2_foreground = "#24273a";
        mark2_background = "#c6a0f6";
        mark3_foreground = "#24273a";
        mark3_background = "#7dc4e4";
        # black
        color0 = "#494d64";
        color8 = "#5b6078";
        # red
        color1 = "#ed8796";
        color9 = "#ed8796";
        # green
        color2 = "#a6da95";
        color10 = "#a6da95";
        # yellow
        color3 = "#eed49f";
        color11 = "#eed49f";
        # blue
        color4 = "#8aadf4";
        color12 = "#8aadf4";
        # magenta
        color5 = "#f5bde6";
        color13 = "#f5bde6";
        # cyan
        color6 = "#8bd5ca";
        color14 = "#8bd5ca";
        # white
        color7 = "#b8c0e0";
        color15 = "#a5adcb";
      };
    })

  ];
}
