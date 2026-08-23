{ config, lib, pkgs, ... }:

let
  theme = config.theme;

  draculaColors = ''
    * {
        bg-col:  #282a36;
        bg-col-light: #282a36;
        border-col: #f8f8f2;
        selected-col: #44475a;
        blue: #8be9fd;
        fg-col: #f8f8f2;
        fg-col2: #6272a4;
        grey: #6272a4;
        width: 600;
    }
  '';

  gruvboxColors = ''
    * {
        bg-col:  #282828;
        bg-col-light: #282828;
        border-col: #ebdbb2;
        selected-col: #a89984;
        blue: #458588;
        fg-col: #ebdbb2;
        fg-col2: #d5c4a1;
        grey: #a89984;
        width: 600;
    }
  '';

  colors = if theme == "dracula" then draculaColors else gruvboxColors;

  configRasi = ''
    configuration{
        modi: "run,drun,window";
        lines: 5;
        font: "JetBrainsMono Nerd Font 14";
        show-icons: true;
        terminal: "alacritty";
        drun-display-format: "{icon} {name}";
        location: 0;
        disable-history: false;
        hide-scrollbar: true;
    display-drun: "   Apps ";
    display-run: "   Run ";
    display-emoji: "☺ Emoji";
    display-window: "   window";
    display-Network: " 󰤨  Network";
        sidebar-mode: true;
    }

    @theme "${config.home.homeDirectory}/.config/rofi/colors.rasi"

    element-text, element-icon , mode-switcher {
        background-color: inherit;
        text-color:       inherit;
    }
    window {
        height: 625px;
        border: 3px;
        border-color: @border-col;
        background-color: @bg-col;
    }
    mainbox {
        background-color: @bg-col;
    }
    inputbar {
        children: [prompt,entry];
        background-color: @bg-col;
        border-radius: 5px;
        padding: 2px;
    }
    prompt {
        background-color: @blue;
        padding: 6px;
        text-color: @bg-col;
        border-radius: 3px;
        margin: 20px 0px 0px 20px;
    }
    textbox-prompt-colon {
        expand: false;
        str: ":";
    }
    entry {
        padding: 6px;
        margin: 20px 0px 0px 10px;
        text-color: @fg-col;
        background-color: @bg-col;
        placeholder:"Search";
    }
    listview {
        border: 0px 0px 0px;
        padding: 6px 0px 0px;
        margin: 10px 0px 0px 20px;
        columns: 2;
        background-color: @bg-col;
    }
    element {
        padding: 5px;
        background-color: @bg-col;
        text-color: @fg-col  ;
    }
    element-icon {
        size: 25px;
    }
    element selected {
        background-color:  @selected-col ;
        text-color: @fg-col2  ;
    }
    mode-switcher {
        spacing: 0;
      }
    button {
        padding: 10px;
        background-color: @bg-col-light;
        text-color: @grey;
        vertical-align: 0.5;
        horizontal-align: 0.5;
    }
    button selected {
      background-color: @bg-col;
      text-color: @blue;
    }
  '';
in
{
  home.packages = [ pkgs.rofi];

  xdg.configFile = {
    "rofi/config.rasi".text = configRasi;
    "rofi/colors.rasi".text = colors;
  };
}
