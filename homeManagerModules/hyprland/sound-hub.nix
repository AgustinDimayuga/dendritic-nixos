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
      accent = "#8be9fd";
    };
    gruvbox = {
      bg = "#282828";
      panel = "#3c3836";
      border = "#ebdbb2";
      selBg = "#504945";
      fg = "#ebdbb2";
      accent = "#fabd2f";
    };
    catppuccin-macchiato = {
      bg = "#24273a";
      panel = "#494d64";
      border = "#cad3f5";
      selBg = "#494d64";
      fg = "#cad3f5";
      accent = "#91d7e3";
    };
    catppuccin-mocha = {
      bg = "#1e1e2e";
      panel = "#45475a";
      border = "#cdd6f4";
      selBg = "#45475a";
      fg = "#cdd6f4";
      accent = "#89dceb";
    };
  };
  p = palettes.${theme};

  css = pkgs.writeText "sound-hub.css" ''
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
    .section {
      opacity: 0.6;
      font-size: 10pt;
      padding: 4px 10px 0 10px;
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
    .row, row.row {
      background: transparent;
      background-image: none;
      border: none;
      box-shadow: none;
      border-radius: 8px;
      padding: 8px 10px;
    }
    button.row:hover, row.row:hover {
      background: ${p.selBg};
      background-image: none;
    }
    row.current label {
      color: ${p.accent};
    }
    list, list row {
      background: transparent;
    }
  '';

  script = pkgs.writeText "sound-hub.py" ''
    #!/usr/bin/env python3
    """sound-hub: small popup with a draggable volume slider and output device list."""

    import json
    import os
    import re
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

    SINK = "@DEFAULT_AUDIO_SINK@"
    SOURCE = "@DEFAULT_AUDIO_SOURCE@"
    PIDFILE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "sound-hub.pid")


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


    def get_volume(target=SINK):
        out = run("wpctl", "get-volume", target)
        m = re.search(r"([0-9]+(?:\.[0-9]+)?)", out)
        vol = int(round(float(m.group(1)) * 100)) if m else 0
        return vol, "MUTED" in out


    def get_default_id(target):
        m = re.match(r"\s*id (\d+)", run("wpctl", "inspect", target))
        return int(m.group(1)) if m else None


    def get_nodes(media_class):
        try:
            nodes = json.loads(run("pw-dump") or "[]")
        except ValueError:
            return []
        found = []
        for node in nodes:
            if node.get("type") != "PipeWire:Interface:Node":
                continue
            props = (node.get("info") or {}).get("props") or {}
            if props.get("media.class") != media_class:
                continue
            name = props.get("node.description") or props.get("node.name") or str(node["id"])
            found.append((node["id"], name))
        return found


    def toggle_existing_instance():
        """If a hub is already open, close it and tell the caller to exit."""
        try:
            with open(PIDFILE) as f:
                pid = int(f.read().strip())
            with open("/proc/%d/cmdline" % pid, "rb") as f:
                cmdline = f.read()
            if pid != os.getpid() and b"sound-hub" in cmdline:
                os.kill(pid, signal.SIGTERM)
                return True
        except (OSError, ValueError):
            pass
        return False


    # -------------------------------------------------------------------- UI ----


    class Hub(Gtk.Window):
        def __init__(self):
            super().__init__(title="sound-hub")
            self.updating = False
            self.dragging = False
            self.muted = False
            self.pending = None
            self.flush_id = None
            self.refresh_id = None
            self.last_user_change = 0.0
            self.was_active = False
            self.watcher = None

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

            # header: title + percentage
            header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
            title = Gtk.Label(label="Sound", xalign=0)
            title.get_style_context().add_class("title")
            self.pct = Gtk.Label(label="--", xalign=1)
            self.pct.get_style_context().add_class("pct")
            header.pack_start(title, True, True, 0)
            header.pack_end(self.pct, False, False, 0)

            # the slider
            self.scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
            self.scale.set_draw_value(False)
            self.scale.set_increments(5, 10)
            self.scale.set_hexpand(True)
            self.scale.connect("value-changed", self.on_scale_changed)
            self.scale.connect("button-press-event", self.on_press)
            self.scale.connect("button-release-event", self.on_release)

            panel = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
            panel.get_style_context().add_class("panel")
            panel.pack_start(header, False, False, 0)
            panel.pack_start(self.scale, False, False, 0)
            card.pack_start(panel, False, False, 0)

            # output devices
            card.pack_start(self.make_section("Output"), False, False, 0)
            self.devices = self.make_device_list()
            card.pack_start(self.devices, False, False, 0)

            # input devices (hidden when there is no microphone)
            self.input_label = self.make_section("Input")
            self.inputs = self.make_device_list()
            for widget in (self.input_label, self.inputs):
                widget.set_no_show_all(True)
                card.pack_start(widget, False, False, 0)

            # mute + settings
            self.mute_btn = self.make_button("Mute", self.on_mute_clicked)
            self.mic_btn = self.make_button("Mute microphone", self.on_mic_mute_clicked)
            self.mic_btn.show_all()  # before no_show_all, so its label is shown too
            self.mic_btn.set_no_show_all(True)
            settings_btn = self.make_button("Sound settings", self.on_settings_clicked)
            card.pack_start(self.mute_btn, False, False, 0)
            card.pack_start(self.mic_btn, False, False, 0)
            card.pack_start(settings_btn, False, False, 0)

            self.connect("key-press-event", self.on_key)
            self.connect("notify::is-active", self.on_active_changed)
            self.connect("destroy", lambda *_: self.quit())

            self.refresh()
            self.start_watcher()

        # ------------------------------------------------------------ builders --

        def make_section(self, text):
            label = Gtk.Label(label=text, xalign=0)
            label.get_style_context().add_class("section")
            return label

        def make_device_list(self):
            box = Gtk.ListBox()
            box.set_selection_mode(Gtk.SelectionMode.NONE)
            box.connect("row-activated", self.on_device_clicked)
            return box

        def make_button(self, text, handler):
            btn = Gtk.Button()
            label = Gtk.Label(label=text, xalign=0)
            btn.add(label)
            btn.set_relief(Gtk.ReliefStyle.NONE)
            btn.get_style_context().add_class("row")
            btn.connect("clicked", handler)
            btn.label = label
            return btn

        def rebuild_devices(self, box, nodes, current):
            for child in box.get_children():
                box.remove(child)
            for node_id, name in nodes:
                is_current = node_id == current
                row = Gtk.ListBoxRow()
                row.node_id = node_id
                label = Gtk.Label(label=("●  " if is_current else "○  ") + name, xalign=0)
                label.set_ellipsize(3)  # Pango.EllipsizeMode.END
                row.add(label)
                row.get_style_context().add_class("row")
                if is_current:
                    row.get_style_context().add_class("current")
                row.show_all()
                box.add(row)

        # ------------------------------------------------------------- state ----

        def refresh(self):
            vol, muted = get_volume()
            self.muted = muted
            recently_touched = time.monotonic() - self.last_user_change < 0.4
            if not self.dragging and not recently_touched:
                self.updating = True
                self.scale.set_value(min(vol, 100))
                self.updating = False
                self.pct.set_text("Muted" if muted else "%d%%" % vol)
            self.mute_btn.label.set_text("Unmute" if muted else "Mute")
            self.rebuild_devices(self.devices, get_nodes("Audio/Sink"), get_default_id(SINK))

            sources = get_nodes("Audio/Source")
            self.rebuild_devices(self.inputs, sources, get_default_id(SOURCE))
            _vol, mic_muted = get_volume(SOURCE)
            self.mic_btn.label.set_text("Unmute microphone" if mic_muted else "Mute microphone")
            for widget in (self.input_label, self.inputs, self.mic_btn):
                widget.set_visible(bool(sources))
            return False

        def schedule_refresh(self):
            if self.refresh_id is None:
                self.refresh_id = GLib.timeout_add(150, self.do_scheduled_refresh)

        def do_scheduled_refresh(self):
            self.refresh_id = None
            return self.refresh()

        # ----------------------------------------------------------- slider -----

        def on_scale_changed(self, scale):
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
            if self.muted:
                fire("wpctl", "set-mute", SINK, "0")
                self.muted = False
                self.mute_btn.label.set_text("Mute")
            fire("wpctl", "set-volume", SINK, "%.2f" % (value / 100.0))
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

        # ----------------------------------------------------------- buttons ----

        def on_device_clicked(self, _box, row):
            fire("wpctl", "set-default", str(row.node_id))
            GLib.timeout_add(150, self.do_scheduled_refresh)

        def on_mute_clicked(self, _btn):
            fire("wpctl", "set-mute", SINK, "toggle")
            GLib.timeout_add(150, self.do_scheduled_refresh)

        def on_mic_mute_clicked(self, _btn):
            fire("wpctl", "set-mute", SOURCE, "toggle")
            GLib.timeout_add(150, self.do_scheduled_refresh)

        def on_settings_clicked(self, _btn):
            try:
                subprocess.Popen(
                    ["pavucontrol"],
                    start_new_session=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
            except OSError:
                pass
            self.quit()

        # ---------------------------------------------------- window behaviour ---

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

        # ------------------------------------------------- device hotplug --------

        def start_watcher(self):
            try:
                self.watcher = Gio.Subprocess.new(
                    ["pactl", "subscribe"],
                    Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_SILENCE,
                )
            except GLib.Error:
                return
            self.stream = Gio.DataInputStream.new(self.watcher.get_stdout_pipe())
            self.stream.read_line_async(GLib.PRIORITY_DEFAULT, None, self.on_event_line)

        def on_event_line(self, stream, result):
            try:
                line, _length = stream.read_line_finish_utf8(result)
            except GLib.Error:
                return
            if line is None:
                return
            if re.search(r" on (sink|source|card|server) ", line):
                self.schedule_refresh()
            stream.read_line_async(GLib.PRIORITY_DEFAULT, None, self.on_event_line)

        def quit(self):
            if self.watcher is not None:
                self.watcher.force_exit()
                self.watcher = None
            try:
                os.remove(PIDFILE)
            except OSError:
                pass
            Gtk.main_quit()


    def load_css():
        path = os.environ.get("SOUND_HUB_CSS")
        if not path:
            return
        provider = Gtk.CssProvider()
        try:
            provider.load_from_path(path)
        except GLib.Error as err:
            print("sound-hub: bad css: %s" % err, file=sys.stderr)
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

  sound-hub = pkgs.stdenv.mkDerivation {
    pname = "sound-hub";
    version = "2.0";
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
      install -Dm755 ${script} $out/bin/sound-hub
      sed -i '1c #!${pythonEnv}/bin/python3' $out/bin/sound-hub
      runHook postInstall
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix PATH : ${
          lib.makeBinPath [
            pkgs.wireplumber
            pkgs.pipewire
            pkgs.pulseaudio
            pkgs.pavucontrol
          ]
        }
        --prefix LD_PRELOAD : ${pkgs.gtk-layer-shell}/lib/libgtk-layer-shell.so
        --set SOUND_HUB_CSS ${css}
      )
    '';
  };
in
{
  home.packages = [ sound-hub ];
}
