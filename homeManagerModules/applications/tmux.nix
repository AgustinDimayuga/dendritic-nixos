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
    terminal = if theme == "dracula" then "tmux-256color" else "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      prefix-highlight
      vim-tmux-navigator

      cpu
      battery
    ];

    extraConfig =
      sharedConfig + (if theme == "dracula" then draculaExtraConfig else gruvboxExtraConfig);
  };
}
