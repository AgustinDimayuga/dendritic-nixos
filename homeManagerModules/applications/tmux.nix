{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.theme;

  draculaExtraConfig = ''


    set-option -g status-position bottom



    setw -g clock-mode-colour '#BD93F9'
    setw -g mode-style 'fg=#F8F8F2 bg=#44475A bold'
    set -g pane-border-style 'fg=#44475A bg=#21222C'
    set -g pane-active-border-style 'fg=#FFB86C bg=#282A36'

    set -g status-style 'bg=#21222C fg=#F8F8F2 dim'

    set -g status-right '#{prefix_highlight} #[fg=#191A21,bg=#BD93F9,bold] %d/%m #[fg=#191A21,bg=#FF79C6,bold] %I:%M:%S '

    setw -g window-status-current-style 'fg=#50FA7B bg=#44475A bold'
    setw -g window-status-current-format ' #I#[fg=#6272A4]:#[fg=#F8F8F2]#W#[fg=#F1FA8C]#F '
    setw -g window-status-style 'fg=#6272A4 bg=#21222C none'
    setw -g window-status-format ' #I#[fg=#3B4048]:#[fg=#F8F8F2]#W#[fg=#6272A4]#F '
    setw -g window-status-bell-style 'fg=#F8F8F2 bg=#FF5555 bold'

    set -g message-style 'fg=#191A21 bg=#BD93F9 bold'
    set -g message-command-style 'fg=#8BE9FD bg=#191A21'

    set -g @prefix_highlight_fg '#191A21'
    set -g @prefix_highlight_bg '#F1FA8C,bold'
    set -g @prefix_highlight_show_copy_mode 'on'
    set -g @prefix_highlight_copy_mode_attr 'fg=#191A21,bg=#F1FA8C,bold'
  '';

  gruvboxExtraConfig = ''
    set-option -g status-position top

    setw -g clock-mode-colour colour135
    setw -g mode-style 'fg=colour196 bg=colour238 bold'
    set -g pane-border-style 'fg=colour238 bg=colour235'
    set -g pane-active-border-style 'fg=colour208 bg=colour236'

    set -g status-style 'bg=#8ec07c fg=colour235 bold'

    set -g status-right '#{prefix_highlight} #[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '

    setw -g window-status-current-style 'fg=colour172 bg=colour238 bold'
    setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour226]#F '
    setw -g window-status-style 'fg=colour138 bg=colour235 none'
    setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
    setw -g window-status-bell-style 'fg=colour255 bg=colour1 bold'

    set -g message-style 'fg=colour232 bg=colour166 bold'
    set -g message-command-style 'fg=blue bg=black'

    set -g @prefix_highlight_fg 'black'
    set -g @prefix_highlight_bg 'yellow,bold'
    set -g @prefix_highlight_show_copy_mode 'on'
    set -g @prefix_highlight_copy_mode_attr 'fg=black,bg=yellow,bold'
  '';

  catppuccinExtraConfig = ''
    # --> Catppuccin (Macchiato)
    set -ogq @thm_bg "#24273a"
    set -ogq @thm_fg "#cad3f5"

    set -ogq @thm_rosewater "#f4dbd6"
    set -ogq @thm_flamingo "#f0c6c6"
    set -ogq @thm_pink "#f5bde6"
    set -ogq @thm_mauve "#c6a0f6"
    set -ogq @thm_red "#ed8796"
    set -ogq @thm_maroon "#ee99a0"
    set -ogq @thm_peach "#f5a97f"
    set -ogq @thm_yellow "#eed49f"
    set -ogq @thm_green "#a6da95"
    set -ogq @thm_teal "#8bd5ca"
    set -ogq @thm_sky "#91d7e3"
    set -ogq @thm_sapphire "#7dc4e4"
    set -ogq @thm_blue "#8aadf4"
    set -ogq @thm_lavender "#b7bdf8"

    set -ogq @thm_subtext_1 "#a5adcb"
    set -ogq @thm_subtext_0 "#b8c0e0"
    set -ogq @thm_overlay_2 "#939ab7"
    set -ogq @thm_overlay_1 "#8087a2"
    set -ogq @thm_overlay_0 "#6e738d"
    set -ogq @thm_surface_2 "#5b6078"
    set -ogq @thm_surface_1 "#494d64"
    set -ogq @thm_surface_0 "#363a4f"
    set -ogq @thm_mantle "#1e2030"
    set -ogq @thm_crust "#181926"

    set-option -g status-position bottom

    setw -g clock-mode-colour '#c6a0f6'
    setw -g mode-style 'fg=#cad3f5 bg=#5b6078 bold'
    set -g pane-border-style 'fg=#494d64 bg=#1e2030'
    set -g pane-active-border-style 'fg=#b7bdf8 bg=#24273a'

    set -g status-style 'bg=#181926 fg=#cad3f5 dim'

    set -g status-right '#{prefix_highlight} #[fg=#181926,bg=#c6a0f6,bold] %d/%m #[fg=#181926,bg=#f5bde6,bold] %I:%M:%S '

    setw -g window-status-current-style 'fg=#a6da95 bg=#5b6078 bold'
    setw -g window-status-current-format ' #I#[fg=#6e738d]:#[fg=#cad3f5]#W#[fg=#eed49f]#F '
    setw -g window-status-style 'fg=#6e738d bg=#181926 none'
    setw -g window-status-format ' #I#[fg=#363a4f]:#[fg=#cad3f5]#W#[fg=#6e738d]#F '
    setw -g window-status-bell-style 'fg=#cad3f5 bg=#ed8796 bold'

    set -g message-style 'fg=#181926 bg=#c6a0f6 bold'
    set -g message-command-style 'fg=#8bd5ca bg=#181926'

    set -g @prefix_highlight_fg '#181926'
    set -g @prefix_highlight_bg '#eed49f,bold'
    set -g @prefix_highlight_show_copy_mode 'on'
    set -g @prefix_highlight_copy_mode_attr 'fg=#181926,bg=#eed49f,bold'
  '';

  catppuccinMochaExtraConfig = ''
    # --> Catppuccin (Mocha)
    set -ogq @thm_bg "#1e1e2e"
    set -ogq @thm_fg "#cdd6f4"

    set -ogq @thm_rosewater "#f5e0dc"
    set -ogq @thm_flamingo "#f2cdcd"
    set -ogq @thm_pink "#f5c2e7"
    set -ogq @thm_mauve "#cba6f7"
    set -ogq @thm_red "#f38ba8"
    set -ogq @thm_maroon "#eba0ac"
    set -ogq @thm_peach "#fab387"
    set -ogq @thm_yellow "#f9e2af"
    set -ogq @thm_green "#a6e3a1"
    set -ogq @thm_teal "#94e2d5"
    set -ogq @thm_sky "#89dceb"
    set -ogq @thm_sapphire "#74c7ec"
    set -ogq @thm_blue "#89b4fa"
    set -ogq @thm_lavender "#b4befe"

    set -ogq @thm_subtext_1 "#bac2de"
    set -ogq @thm_subtext_0 "#a6adc8"
    set -ogq @thm_overlay_2 "#9399b2"
    set -ogq @thm_overlay_1 "#7f849c"
    set -ogq @thm_overlay_0 "#6c7086"
    set -ogq @thm_surface_2 "#585b70"
    set -ogq @thm_surface_1 "#45475a"
    set -ogq @thm_surface_0 "#313244"
    set -ogq @thm_mantle "#181825"
    set -ogq @thm_crust "#11111b"

    set-option -g status-position bottom

    setw -g clock-mode-colour '#cba6f7'
    setw -g mode-style 'fg=#cdd6f4 bg=#585b70 bold'
    set -g pane-border-style 'fg=#45475a bg=#181825'
    set -g pane-active-border-style 'fg=#b4befe bg=#1e1e2e'

    set -g status-style 'bg=#11111b fg=#cdd6f4 dim'

    set -g status-right '#{prefix_highlight} #[fg=#11111b,bg=#cba6f7,bold] %d/%m #[fg=#11111b,bg=#f5c2e7,bold] %I:%M:%S '

    setw -g window-status-current-style 'fg=#a6e3a1 bg=#585b70 bold'
    setw -g window-status-current-format ' #I#[fg=#6c7086]:#[fg=#cdd6f4]#W#[fg=#f9e2af]#F '
    setw -g window-status-style 'fg=#6c7086 bg=#11111b none'
    setw -g window-status-format ' #I#[fg=#313244]:#[fg=#cdd6f4]#W#[fg=#6c7086]#F '
    setw -g window-status-bell-style 'fg=#cdd6f4 bg=#f38ba8 bold'

    set -g message-style 'fg=#11111b bg=#cba6f7 bold'
    set -g message-command-style 'fg=#94e2d5 bg=#11111b'

    set -g @prefix_highlight_fg '#11111b'
    set -g @prefix_highlight_bg '#f9e2af,bold'
    set -g @prefix_highlight_show_copy_mode 'on'
    set -g @prefix_highlight_copy_mode_attr 'fg=#11111b,bg=#f9e2af,bold'
  '';

  sharedConfig = ''
    bind | split-window -h
    bind - split-window -v
    unbind '"'
    unbind %

    set mouse on

    set-window-option -g mode-keys vi
    bind-key -T copy-mode-vi v send -X begin-selection
    bind-key -T copy-mode-vi y send -X copy-selection

    bind -r m resize-pane -Z

    set -g base-index 1
    setw -g pane-base-index 1

    set -g status-justify left
    set -g status-interval 2
    set -g status-left ""
    set -g status-right-length 50
    set -g status-left-length 20
  '';
in
{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    terminal =
      if theme == "dracula" then
        "tmux-256color"
      else if theme == "catppuccin-macchiato" then
        "tmux-256color"
      else if theme == "catppuccin-mocha" then
        "tmux-256color"
      else
        "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      prefix-highlight
      vim-tmux-navigator

      cpu
      battery
    ];

    extraConfig =
      sharedConfig
      + (
        if theme == "dracula" then
          draculaExtraConfig
        else if theme == "catppuccin-macchiato" then
          catppuccinExtraConfig
        else if theme == "catppuccin-mocha" then
          catppuccinMochaExtraConfig
        else
          gruvboxExtraConfig
      );
  };
}
