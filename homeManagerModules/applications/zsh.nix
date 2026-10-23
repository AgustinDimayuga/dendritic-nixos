{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.theme;

  # Pinned statically (not a flake input) since these are small, rarely-updated
  # community oh-my-zsh theme files, not full projects we track upstream.
  draculaZshThemeSrc = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "zsh";
    rev = "a3e27d47ea2ed1e3b435f44aa71caf71d3219af6";
    sha256 = "1si457c4x11bz54lhpqlgzkd29pvwm8bzr6gizs03xpwf0gx8wxs";
  };

  catppuccinZshThemeSrc = pkgs.fetchFromGitHub {
    owner = "JannoTjarks";
    repo = "catppuccin-zsh";
    rev = "a5d1ba4caa62af97c61c00b66ea8b3bc724c8c7a";
    sha256 = "01kp0lhrfhp66782nf3lzfafrpa3cdr2nlh5jxv0b4bqmvrb1ay3";
  };

  # oh-my-zsh custom/ dir: both themes live side by side, selected at runtime
  # via `theme`/`extraConfig` below.
  ohMyZshCustom = pkgs.runCommand "oh-my-zsh-custom" { } ''
    mkdir -p $out/themes/lib
    cp ${draculaZshThemeSrc}/dracula.zsh-theme $out/themes/dracula.zsh-theme
    cp ${draculaZshThemeSrc}/lib/async.zsh $out/themes/lib/async.zsh

    mkdir -p $out/themes/catppuccin-flavors
    cp ${catppuccinZshThemeSrc}/catppuccin.zsh-theme $out/themes/catppuccin.zsh-theme
    cp ${catppuccinZshThemeSrc}/catppuccin-flavors/*.zsh $out/themes/catppuccin-flavors/
  '';

  # https://github.com/dracula/zsh-syntax-highlighting
  draculaHighlighting = ''
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
    typeset -gA ZSH_HIGHLIGHT_STYLES

    ZSH_HIGHLIGHT_STYLES[comment]='fg=#6272A4'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#50FA7B'
    ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#50FA7B'
    ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#50FA7B'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#50FA7B'
    ZSH_HIGHLIGHT_STYLES[command]='fg=#50FA7B'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=#50FA7B,italic'
    ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#FFB86C,italic'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#FFB86C'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#FFB86C'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#BD93F9'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8BE9FD'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#8BE9FD'
    ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#8BE9FD'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=#F1FA8C'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=#F1FA8C'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#F1FA8C'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#FF5555'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#F1FA8C'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#FF5555'
    ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#F1FA8C'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#FF5555'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[assign]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF5555'
    ZSH_HIGHLIGHT_STYLES[path]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#FF79C6'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#BD93F9'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#FF5555'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[arg0]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[default]='fg=#F8F8F2'
    ZSH_HIGHLIGHT_STYLES[cursor]='standout'
  '';

  # https://github.com/catppuccin/zsh-syntax-highlighting/blob/main/themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh
  catppuccinMacchiatoHighlighting = ''
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
    typeset -gA ZSH_HIGHLIGHT_STYLES

    ZSH_HIGHLIGHT_STYLES[comment]='fg=#5b6078'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6da95'
    ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#a6da95'
    ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#a6da95'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#a6da95'
    ZSH_HIGHLIGHT_STYLES[command]='fg=#a6da95'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6da95,italic'
    ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#f5a97f,italic'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#f5a97f'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#f5a97f'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#c6a0f6'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6da95'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#a6da95'
    ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#a6da95'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ed8796'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#ed8796'
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#ed8796'
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#ed8796'
    ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=#eed49f'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=#eed49f'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#eed49f'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#ee99a0'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#eed49f'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#ee99a0'
    ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#eed49f'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#ee99a0'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[assign]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ee99a0'
    ZSH_HIGHLIGHT_STYLES[path]='fg=#cad3f5,underline'
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#ed8796,underline'
    ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#cad3f5,underline'
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#ed8796,underline'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#c6a0f6'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#ee99a0'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[arg0]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[default]='fg=#cad3f5'
    ZSH_HIGHLIGHT_STYLES[cursor]='fg=#cad3f5'
  '';

  # https://github.com/catppuccin/zsh-syntax-highlighting/blob/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh
  catppuccinMochaHighlighting = ''
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
    typeset -gA ZSH_HIGHLIGHT_STYLES

    ZSH_HIGHLIGHT_STYLES[comment]='fg=#585b70'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic'
    ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#fab387,italic'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fab387'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fab387'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#cba6f7'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f38ba8'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#f38ba8'
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#f38ba8'
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#f38ba8'
    ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=#f9e2af'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=#f9e2af'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f9e2af'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#eba0ac'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f9e2af'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#eba0ac'
    ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#f9e2af'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#eba0ac'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[assign]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#eba0ac'
    ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#f38ba8,underline'
    ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#cdd6f4,underline'
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#f38ba8,underline'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#cba6f7'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#eba0ac'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[arg0]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[cursor]='fg=#cdd6f4'
  '';

  # Gruvbox doesn't have an official zsh-syntax-highlighting theme in use here,
  # so it falls through to the plugin's own defaults.
  syntaxHighlighting =
    if theme == "dracula" then
      draculaHighlighting
    else if theme == "catppuccin-macchiato" then
      catppuccinMacchiatoHighlighting
    else if theme == "catppuccin-mocha" then
      catppuccinMochaHighlighting
    else
      "";

  # Gruvbox keeps the plain oh-my-zsh "robbyrussell" prompt (no official theme provided here).
  ohMyZshTheme =
    if theme == "dracula" then
      "dracula"
    else if theme == "catppuccin-macchiato" || theme == "catppuccin-mocha" then
      "catppuccin"
    else
      "robbyrussell";

  # CATPPUCCIN_FLAVOR/DRACULA_DISPLAY_CONTEXT are read at theme-source time,
  # so they must be set via oh-my-zsh's extraConfig (which runs before
  # `source $ZSH/oh-my-zsh.sh`), not in initContent (which runs after).
  # DRACULA_DISPLAY_CONTEXT=1 shows "%n " (username) right before the
  # directory segment, same spot Catppuccin's %n already shows it.
  ohMyZshThemeExtraConfig =
    if theme == "dracula" then
      "DRACULA_DISPLAY_CONTEXT=1"
    else if theme == "catppuccin-macchiato" then
      ''CATPPUCCIN_FLAVOR="macchiato"''
    else if theme == "catppuccin-mocha" then
      ''CATPPUCCIN_FLAVOR="mocha"''
    else
      "";

  ohMyZshExtraConfig = ohMyZshThemeExtraConfig;

  # robbyrussell (Gruvbox's oh-my-zsh theme) has no username toggle, so we
  # redefine PROMPT after it's sourced, inserting a username segment before
  # the directory segment, to match Dracula/Catppuccin. This is robbyrussell's
  # own PROMPT definition with %n added in.
  gruvboxPromptOverride = ''
    PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[yellow]%}%n%{$reset_color%} %{$fg[cyan]%}%c%{$reset_color%}"
    PROMPT+=' $(git_prompt_info)'
  '';

  # Accent color for the (dev-shell) tag, from each theme's palette
  devShellColor =
    if theme == "dracula" then
      "#8BE9FD" # Dracula cyan
    else if theme == "catppuccin-macchiato" then
      "#8bd5ca" # Macchiato teal
    else if theme == "catppuccin-mocha" then
      "#94e2d5" # Mocha teal
    else
      "#8ec07c"; # Gruvbox aqua

  # Tag the prompt when inside `nix develop` (IN_NIX_SHELL is set by nix).
  devShellPrompt = ''
    if [[ -n "$IN_NIX_SHELL" ]]; then
      PROMPT+='%F{${devShellColor}}❄%f '
    fi
  '';

  promptOverride = if theme == "gruvbox" then gruvboxPromptOverride else "";
in
{
  programs.zsh = {
    enable = true;
    initContent =
      syntaxHighlighting
      + promptOverride
      + devShellPrompt
      + ''
        bindkey -v
        export EDITOR=nvim
        export PATH="$HOME/.emacs.d/bin:$PATH"
      '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "web-search"
      ];
      custom = toString ohMyZshCustom;
      theme = ohMyZshTheme;
      extraConfig = ohMyZshExtraConfig;
    };
  };
}
