{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.theme;

  themeSettings = {
    dracula = {
      colorTheme = "Dracula Theme";
      extension = pkgs.open-vsx.dracula-theme.theme-dracula;
      colors = {
        "editor.background" = "#1e1f29";
        "sideBar.background" = "#1e1f29";
        "panel.background" = "#1e1f29";
        "terminal.background" = "#1e1f29";
        "editorGroupHeader.tabsBackground" = "#191a23";
        "tab.activeBackground" = "#1e1f29";
        "tab.inactiveBackground" = "#191a23";
        "tab.border" = "#00000000";
        "tab.activeBorder" = "#00000000";
        "tab.activeBorderTop" = "#bd93f9";
        "editorGroup.border" = "#00000000";
        "editorLineNumber.foreground" = "#4b5263";
        "editor.lineHighlightBackground" = "#ffffff0a";
      };
    };
    gruvbox = {
      colorTheme = "Gruvbox Dark Soft";
      extension = pkgs.open-vsx.jdinhlife.gruvbox;
      colors = {
        "editor.background" = "#262626";
        "sideBar.background" = "#262626";
        "panel.background" = "#262626";
        "terminal.background" = "#262626";
        "editorGroupHeader.tabsBackground" = "#1d2021";
        "tab.activeBackground" = "#262626";
        "tab.inactiveBackground" = "#1d2021";
        "tab.border" = "#00000000";
        "tab.activeBorder" = "#00000000";
        "tab.activeBorderTop" = "#fabd2f";
        "editorGroup.border" = "#00000000";
        "editor.lineHighlightBackground" = "#ffffff0a";
      };
    };
  };

  current = themeSettings.${theme};

  # languages Prettier should format (JS, Next.js, Express, Tailwind projects)
  prettierLangs = [
    "javascript"
    "javascriptreact"
    "typescript"
    "typescriptreact"
    "json"
    "jsonc"
    "css"
    "html"
  ];
  prettierFormatters = lib.genAttrs (map (l: "[${l}]") prettierLangs) (_: {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  });

  jdk = pkgs.jdk21;
in
{
  # language servers and toolchains the extensions talk to
  home.packages = with pkgs; [
    go
    gopls
    delve
    gotools
    nodejs
    python3
    ruff
    nixd
    nixfmt
    jdk
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.vscodium = {
    enable = true;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = [
        current.extension

        # vim
        pkgs.open-vsx.vscodevim.vim

        pkgs.open-vsx.mkhl.direnv
        # go
        pkgs.open-vsx.golang.go

        # nix
        pkgs.open-vsx.jnoortheen.nix-ide

        # javascript / typescript / next.js / express / tailwind
        pkgs.open-vsx.esbenp.prettier-vscode
        pkgs.open-vsx.dbaeumer.vscode-eslint
        pkgs.open-vsx.bradlc.vscode-tailwindcss
        pkgs.open-vsx.formulahendry.auto-rename-tag

        # python
        pkgs.open-vsx.ms-pyright.pyright
        pkgs.open-vsx.charliermarsh.ruff
        pkgs.open-vsx.formulahendry.code-runner

        # java
        pkgs.open-vsx.redhat.java
        pkgs.open-vsx.vscjava.vscode-java-debug
      ];

      userSettings = {
        # theme + font
        "workbench.colorTheme" = current.colorTheme;
        "workbench.colorCustomizations" = current.colors;
        "editor.fontFamily" = "MonoLisa Variable";
        "editor.fontSize" = 16;
        "editor.fontLigatures" = true;
        "editor.lineHeight" = 1.7;
        "terminal.integrated.fontFamily" = "MonoLisa Variable";

        # remove chrome: no title bar, menu, activity bar, status bar, minimap
        "window.titleBarStyle" = "native";
        "window.customTitleBarVisibility" = "never";
        "window.menuBarVisibility" = "hidden";
        "window.commandCenter" = false;
        "window.confirmBeforeClose" = "always";
        "window.menuStyle" = "custom";
        "workbench.layoutControl.enabled" = false;
        "workbench.activityBar.location" = "hidden";
        "workbench.statusBar.visible" = false;
        "editor.minimap.enabled" = false;
        "breadcrumbs.enabled" = false;
        "workbench.startupEditor" = "none";
        "workbench.tips.enabled" = false;

        # clean editor
        "editor.scrollbar.vertical" = "hidden";
        "editor.scrollbar.horizontal" = "hidden";
        "editor.overviewRulerBorder" = false;
        "editor.hideCursorInOverviewRuler" = true;
        "editor.glyphMargin" = false;
        "editor.folding" = false;
        "editor.guides.indentation" = false;
        "editor.renderLineHighlight" = "all";
        "editor.lineNumbersMinChars" = 3;
        "editor.padding.top" = 16;
        "editor.padding.bottom" = 16;
        "problems.decorations.enabled" = false;
        "workbench.editor.decorations.badges" = false;
        "workbench.editor.decorations.colors" = false;

        # smooth feel
        "editor.smoothScrolling" = true;
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.cursorBlinking" = "smooth";
        "workbench.list.smoothScrolling" = true;
        "terminal.integrated.smoothScrolling" = true;

        # editing
        "editor.bracketPairColorization.enabled" = true;
        "editor.formatOnSave" = true;
        "files.autoSave" = "off";
        "files.hotExit" = "off";
        "editor.lineNumbers" = "relative";
        "editor.quickSuggestions" = {
          other = "on";
          comments = "off";
          strings = "on"; # needed for Tailwind class completion
        };

        # vim
        "vim.useSystemClipboard" = true;
        "vim.hlsearch" = true;
        "vim.incsearch" = true;
        "vim.leader" = "<space>";
        "vim.handleKeys" = {
          "<C-p>" = false; # keep quick open
          "<C-b>" = false; # keep sidebar toggle
        };
        "vim.normalModeKeyBindingsNonRecursive" = [
          {
            before = [
              "<leader>"
              "e"
            ];
            commands = [ "workbench.view.explorer" ];
          }
          {
            before = [
              "<leader>"
              "f"
            ];
            commands = [ "workbench.action.quickOpen" ];
          }
          {
            before = [
              "<leader>"
              "/"
            ];
            commands = [ "workbench.action.findInFiles" ];
          }
          {
            before = [
              "<leader>"
              "b"
            ];
            commands = [ "workbench.action.toggleSidebarVisibility" ];
          }
        ];

        # go (tools come from nix, so don't let the extension download its own)
        "go.toolsManagement.autoUpdate" = false;
        "gopls" = {
          "ui.semanticTokens" = true;
        };

        # nix
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = [
          "nixfmt"
          "-"
        ];
        "nix.serverSettings" = {
          nixd.formatting.command = [
            "nixfmt"
            "-"
          ];
        };
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };

        # python
        "[python]" = {
          "editor.defaultFormatter" = "charliermarsh.ruff";
        };
        "code-runner.runInTerminal" = true;
        "code-runner.saveFileBeforeRun" = true;
        "code-runner.executorMap" = {
          python = "python3 -u";
        };

        # java
        "java.jdt.ls.java.home" = "${jdk}/lib/openjdk";
        "java.configuration.runtimes" = [
          {
            name = "JavaSE-21";
            path = "${jdk}/lib/openjdk";
            default = true;
          }
        ];

        # js / ts
        "typescript.updateImportsOnFileMove.enabled" = "always";
      }
      // prettierFormatters;
      # caps lock (remapped to esc in hyprland) -> escape inside vscodium
      keybindings = [
        {
          key = "capslock";
          command = "extension.vim_escape";
          when = "editorTextFocus && vim.active && !inDebugRepl";
        }
        {
          key = "capslock";
          command = "workbench.action.closeQuickOpen";
          when = "inQuickOpen";
        }
        {
          key = "capslock";
          command = "hideSuggestWidget";
          when = "suggestWidgetVisible && textInputFocus";
        }
      ];
    };
  };
}
