{ config, pkgs, ... }:

let
  theme = config.theme;

  themeSettings = {
    dracula = {
      colorTheme = "Dracula Theme";
      extension = pkgs.vscode-marketplace.dracula-theme.theme-dracula;
    };
    gruvbox = {
      colorTheme = "Gruvbox Dark Soft";
      extension = pkgs.vscode-marketplace.jdinhlife.gruvbox;
    };
  };

  current = themeSettings.${theme};
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      userSettings = {
        "workbench.colorTheme" = current.colorTheme;
        "editor.fontFamily" = "MonoLisa Variable";
        "editor.fontSize" = 14;
        "editor.formatOnSave" = true;
        "files.autoSave" = "onFocusChange";
        "terminal.integrated.fontFamily" = "MonoLisa Variable";
      };

      extensions = [
        current.extension
      ];
    };
  };
}
