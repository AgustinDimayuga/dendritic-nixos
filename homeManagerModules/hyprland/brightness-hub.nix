{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.theme;

  palettes = {
    dracula = {
      bg = "#282a36";
      panel = "#44475a";
      border = "#f8f8f2";
      selBg = "#44475a";
      fg = "#f8f8f2";
      accent = "#f1fa8c";
    };
    gruvbox = {
      bg = "#282828";
      panel = "#3c3836";
      border = "#ebdbb2";
      selBg = "#504945";
      fg = "#ebdbb2";
      accent = "#fe8019";
    };
    catppuccin-macchiato = {
      bg = "#24273a";
      panel = "#494d64";
      border = "#cad3f5";
      selBg = "#494d64";
      fg = "#cad3f5";
      accent = "#eed49f";
    };
  };
  p = palettes.${theme};

  css = pkgs.writeText "brightness-hub.css" ''
    * {
      font-family: "MonoLisaText Trial";
      font-size: 13pt;
      color: ${p.fg};
    }
    window, window.background {
      background: transparent;
    }
    .card {
      background: ${p.bg};
      border: 2px solid ${p.border};
      border-radius: 12px;
      padding: 12px;
    }
    .panel {
      background: ${p.panel};
      border-radius: 8px;
      padding: 12px;
    }
    .title {
      font-weight: bold;
    }
    .pct {
      color: ${p.accent};
      font-weight: bold;
    }
    scale trough {
      background: ${p.bg};
      min-height: 10px;
      border-radius: 5px;
      border: none;
    }
    scale highlight {
      background: ${p.accent};
      border-radius: 5px;
      border: none;
    }
    scale slider {
      background: ${p.fg};
      min-width: 20px;
      min-height: 20px;
      margin: -6px;
      border-radius: 10px;
      border: none;
      box-shadow: none;
    }
  '';

  script = pkgs.writeText "brightness-hub.py" ''
    #!/usr/bin/env python3
    """brightness-hub: small popup with draggable display and keyboard backlight sliders."""

    import os
    import signal
    import subprocess
    import sys
    import time

    # gtk-layer-shell must be preloaded (see the Nix wrapper). Drop it from the
    # environment so the helper programs we spawn don't inherit it.
    os.environ.pop("LD_PRELOAD", None)

    import gi

    gi.require_version("Gtk", "3.0")
    gi.require_version("Gdk", "3.0")
    from gi.repository import Gdk, Gio, GLib, Gtk

    try:
        gi.require_version("GtkLayerShell", "0.1")
        from gi.repository import GtkLayerShell
    except (ValueError, ImportError):
        GtkLayerShell = None

    # Same curve as the XF86MonBrightness binds in keybinds.nix, so the slider
    # and the hotkeys agree. Make this an empty list for a plain linear slider
    # (which also matches the raw percentage waybar's backlight module shows).
    DISPLAY_ARGS = []
    PIDFILE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "brightness-hub.pid")


    # ---------------------------------------------------------------- helpers ---


    def run(*argv):
        try:
            return subprocess.run(argv, capture_output=True, text=True, timeout=3).stdout
        except (OSError, subprocess.SubprocessError):
            return ""


    def fire(*argv):
        """Start a command and don't wait for it."""
        try:
            Gio.Subprocess.new(
                list(argv),
                Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_SILENCE,
            )
        except GLib.Error:
            pass


    def get_percent(args):
        # machine-readable: name,class,current,percent%,max
        parts = run("brightnessctl", "-m", *args).strip().split(",")
        if len(parts) >= 5:
            try:
                return int(parts[3].rstrip("%"))
            except ValueError:
                pass
        return None


    def find_kbd_backlight():
        for line in run("brightnessctl", "-l", "-m", "-c", "leds").splitlines():
            name = line.split(",")[0]
            if "kbd_backlight" in name:
                return name
        return None


    def toggle_existing_instance():
        """If a hub is already open, close it and tell the caller to exit."""
        try:
            with open(PIDFILE) as f:
                pid = int(f.read().strip())
            with open("/proc/%d/cmdline" % pid, "rb") as f:
                cmdline = f.read()
            if pid != os.getpid() and b"brightness-hub" in cmdline:
                os.kill(pid, signal.SIGTERM)
                return True
        except (OSError, ValueError):
            pass
        return False


    # -------------------------------------------------------------------- UI ----


    class Slider:
        """A titled panel with a draggable slider bound to one brightnessctl device."""

        def __init__(self, title, args, minimum):
            self.args = list(args)
            self.minimum = minimum
            self.updating = False
            self.dragging = False
            self.pending = None
            self.flush_id = None
            self.last_user_change = 0.0

            self.box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
            self.box.get_style_context().add_class("panel")

            header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
            label = Gtk.Label(label=title, xalign=0)
            label.get_style_context().add_class("title")
            self.pct = Gtk.Label(label="--", xalign=1)
            self.pct.get_style_context().add_class("pct")
            header.pack_start(label, True, True, 0)
            header.pack_end(self.pct, False, False, 0)

            self.scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, minimum, 100, 1)
            self.scale.set_draw_value(False)
            self.scale.set_increments(5, 10)
            self.scale.set_hexpand(True)
            self.scale.connect("value-changed", self.on_changed)
            self.scale.connect("button-press-event", self.on_press)
            self.scale.connect("button-release-event", self.on_release)

            self.box.pack_start(header, False, False, 0)
            self.box.pack_start(self.scale, False, False, 0)

        def refresh(self):
            value = get_percent(self.args)
            if value is None:
                return
            recently_touched = time.monotonic() - self.last_user_change < 0.6
            if self.dragging or recently_touched:
                return
            self.updating = True
            self.scale.set_value(max(self.minimum, min(value, 100)))
            self.updating = False
            self.pct.set_text("%d%%" % value)

        def on_changed(self, scale):
            if self.updating:
                return
            self.pending = int(round(scale.get_value()))
            self.last_user_change = time.monotonic()
            self.pct.set_text("%d%%" % self.pending)
            if self.flush_id is None:
                self.flush_id = GLib.timeout_add(40, self.flush)

        def flush(self):
            self.flush_id = None
            if self.pending is None:
                return False
            value, self.pending = self.pending, None
            fire("brightnessctl", *self.args, "set", "%d%%" % value)
            return False

        def on_press(self, *_):
            self.dragging = True
            return False

        def on_release(self, *_):
            self.dragging = False
            if self.flush_id is not None:
                GLib.source_remove(self.flush_id)
                self.flush_id = None
            self.flush()
            return False


    class Hub(Gtk.Window):
        def __init__(self):
            super().__init__(title="brightness-hub")
            self.was_active = False

            self.set_resizable(False)
            self.set_size_request(360, -1)
            self.set_app_paintable(True)
            visual = self.get_screen().get_rgba_visual()
            if visual is not None:
                self.set_visual(visual)

            if GtkLayerShell is not None and GtkLayerShell.is_supported():
                GtkLayerShell.init_for_window(self)
                GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
                GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
                GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
                GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 8)
                GtkLayerShell.set_margin(self, GtkLayerShell.Edge.RIGHT, 8)
                GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.ON_DEMAND)
            else:
                self.set_decorated(False)
                self.set_type_hint(Gdk.WindowTypeHint.DIALOG)

            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
            card.get_style_context().add_class("card")
            self.add(card)

            # never let the display slider reach 0 so the screen can't go black
            self.sliders = [Slider("Display", DISPLAY_ARGS, 1)]

            # keyboard backlight (only when the hardware exposes one)
            kbd = find_kbd_backlight()
            if kbd:
                self.sliders.append(Slider("Keyboard", ["-d", kbd], 0))

            for slider in self.sliders:
                card.pack_start(slider.box, False, False, 0)

            self.connect("key-press-event", self.on_key)
            self.connect("notify::is-active", self.on_active_changed)
            self.connect("destroy", lambda *_: self.quit())

            self.poll()
            # pick up changes made by the hotkeys while the popup is open
            GLib.timeout_add(500, self.poll)

        def poll(self):
            for slider in self.sliders:
                slider.refresh()
            return True

        def on_key(self, _w, event):
            if event.keyval == Gdk.KEY_Escape:
                self.quit()
                return True
            return False

        def on_active_changed(self, *_):
            if self.is_active():
                self.was_active = True
            elif self.was_active:
                self.quit()

        def quit(self):
            try:
                os.remove(PIDFILE)
            except OSError:
                pass
            Gtk.main_quit()


    def load_css():
        path = os.environ.get("BRIGHTNESS_HUB_CSS")
        if not path:
            return
        provider = Gtk.CssProvider()
        try:
            provider.load_from_path(path)
        except GLib.Error as err:
            print("brightness-hub: bad css: %s" % err, file=sys.stderr)
            return
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER
        )


    def main():
        if toggle_existing_instance():
            return
        with open(PIDFILE, "w") as f:
            f.write(str(os.getpid()))
        load_css()
        hub = Hub()
        GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGTERM, hub.quit)
        GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, hub.quit)
        hub.show_all()
        Gtk.main()


    if __name__ == "__main__":
        main()
  '';

  pythonEnv = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);

  brightness-hub = pkgs.stdenv.mkDerivation {
    pname = "brightness-hub";
    version = "1.0";
    dontUnpack = true;
    dontBuild = true;

    nativeBuildInputs = [
      pkgs.wrapGAppsHook3
      pkgs.gobject-introspection
    ];
    buildInputs = [
      pkgs.gtk3
      pkgs.gtk-layer-shell
      pkgs.glib
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 ${script} $out/bin/brightness-hub
      sed -i '1c #!${pythonEnv}/bin/python3' $out/bin/brightness-hub
      runHook postInstall
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix PATH : ${lib.makeBinPath [ pkgs.brightnessctl ]}
        --prefix LD_PRELOAD : ${pkgs.gtk-layer-shell}/lib/libgtk-layer-shell.so
        --set BRIGHTNESS_HUB_CSS ${css}
      )
    '';
  };
in
{
  home.packages = [ brightness-hub ];
}
