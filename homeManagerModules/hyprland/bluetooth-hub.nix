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
      accent = "#83a598";
    };
  };
  p = palettes.${theme};

  css = pkgs.writeText "bluetooth-hub.css" ''
    * {
      font-family: "JetBrainsMono Nerd Font";
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
    .dim {
      opacity: 0.6;
      font-size: 10pt;
    }
    .hint {
      opacity: 0.7;
      padding: 8px 10px;
    }
    .status {
      color: ${p.accent};
      font-size: 10pt;
      padding: 2px 10px;
    }
    switch {
      background: ${p.bg};
      border: none;
      border-radius: 14px;
      min-width: 52px;
      min-height: 28px;
      box-shadow: none;
    }
    switch:checked {
      background: ${p.accent};
    }
    switch slider {
      background: ${p.fg};
      border: none;
      border-radius: 12px;
      min-width: 22px;
      min-height: 22px;
      margin: 3px;
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
    row.current label.name {
      color: ${p.accent};
    }
    button.forget {
      background: transparent;
      background-image: none;
      border: none;
      box-shadow: none;
      border-radius: 6px;
      padding: 0 8px;
      min-height: 0;
    }
    button.forget:hover {
      background: ${p.bg};
      background-image: none;
    }
    button.action {
      background: ${p.bg};
      background-image: none;
      border: none;
      box-shadow: none;
      border-radius: 8px;
      padding: 6px 14px;
    }
    button.action:hover {
      background: ${p.accent};
      background-image: none;
    }
    button.action:hover label {
      color: ${p.bg};
    }
    list, list row {
      background: transparent;
    }
    scrollbar slider {
      background: ${p.selBg};
      border-radius: 4px;
    }
  '';

  script = pkgs.writeText "bluetooth-hub.py" ''
    #!/usr/bin/env python3
    """bluetooth-hub: small popup to switch Bluetooth on or off and pair, connect or forget devices."""

    import os
    import re
    import signal
    import subprocess
    import sys

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

    BLUEZ = "org.bluez"
    ADAPTER_IFACE = "org.bluez.Adapter1"
    DEVICE_IFACE = "org.bluez.Device1"
    BATTERY_IFACE = "org.bluez.Battery1"
    AGENT_MANAGER_IFACE = "org.bluez.AgentManager1"
    PROPS_IFACE = "org.freedesktop.DBus.Properties"
    OBJMAN_IFACE = "org.freedesktop.DBus.ObjectManager"
    AGENT_PATH = "/org/bluetooth_hub/agent"
    PIDFILE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "bluetooth-hub.pid")

    # BUS is set in main(); tests can point it at a private bus instead.
    BUS = None

    AGENT_XML = """
    <node>
      <interface name="org.bluez.Agent1">
        <method name="Release"/>
        <method name="RequestPinCode">
          <arg type="o" direction="in"/>
          <arg type="s" direction="out"/>
        </method>
        <method name="DisplayPinCode">
          <arg type="o" direction="in"/>
          <arg type="s" direction="in"/>
        </method>
        <method name="RequestPasskey">
          <arg type="o" direction="in"/>
          <arg type="u" direction="out"/>
        </method>
        <method name="DisplayPasskey">
          <arg type="o" direction="in"/>
          <arg type="u" direction="in"/>
          <arg type="q" direction="in"/>
        </method>
        <method name="RequestConfirmation">
          <arg type="o" direction="in"/>
          <arg type="u" direction="in"/>
        </method>
        <method name="RequestAuthorization">
          <arg type="o" direction="in"/>
        </method>
        <method name="AuthorizeService">
          <arg type="o" direction="in"/>
          <arg type="s" direction="in"/>
        </method>
        <method name="Cancel"/>
      </interface>
    </node>
    """


    # ---------------------------------------------------------------- helpers ---


    def fire(*argv):
        """Start a command and don't wait for it."""
        try:
            Gio.Subprocess.new(
                list(argv),
                Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_SILENCE,
            )
        except GLib.Error:
            pass


    def clean_error(err):
        message = getattr(err, "message", None) or str(err)
        message = re.sub(r"^GDBus\.Error:[^:]+:\s*", "", message)
        return message or "failed"


    def bz_call(path, iface, method, args, done=None, timeout=30000):
        """Call a BlueZ method without blocking. done(result, error) runs when it finishes."""

        def finished(source, result, _data=None):
            try:
                out, err = source.call_finish(result), None
            except GLib.Error as e:
                out, err = None, e
            if done is not None:
                done(out, err)

        BUS.call(
            BLUEZ, path, iface, method, args, None,
            Gio.DBusCallFlags.NONE, timeout, None, finished, None,
        )


    def bz_call_sync(path, iface, method, args, timeout=1000):
        try:
            return BUS.call_sync(
                BLUEZ, path, iface, method, args, None,
                Gio.DBusCallFlags.NONE, timeout, None,
            )
        except GLib.Error:
            return None


    def get_objects():
        try:
            res = BUS.call_sync(
                BLUEZ, "/", OBJMAN_IFACE, "GetManagedObjects", None,
                GLib.VariantType.new("(a{oa{sa{sv}}})"),
                Gio.DBusCallFlags.NONE, 3000, None,
            )
        except GLib.Error:
            return None
        return res.unpack()[0]


    def snapshot(objects):
        """Turn BlueZ's object tree into (adapter, devices)."""
        adapter = None
        for path in sorted(objects):
            props = objects[path].get(ADAPTER_IFACE)
            if props is not None:
                adapter = {
                    "path": path,
                    "powered": bool(props.get("Powered")),
                    "discovering": bool(props.get("Discovering")),
                }
                break

        devices = []
        for path, ifaces in objects.items():
            dev = ifaces.get(DEVICE_IFACE)
            if dev is None:
                continue
            if adapter is not None and dev.get("Adapter") != adapter["path"]:
                continue
            real_name = dev.get("Name") or ""
            devices.append(
                {
                    "path": path,
                    "name": dev.get("Alias") or real_name or dev.get("Address", path),
                    # devices that never announced a name are mostly random beacons
                    "named": bool(real_name),
                    "paired": bool(dev.get("Paired")),
                    "connected": bool(dev.get("Connected")),
                    "battery": (ifaces.get(BATTERY_IFACE) or {}).get("Percentage"),
                }
            )
        return adapter, devices


    def toggle_existing_instance():
        """If a hub is already open, close it and tell the caller to exit."""
        try:
            with open(PIDFILE) as f:
                pid = int(f.read().strip())
            with open("/proc/%d/cmdline" % pid, "rb") as f:
                cmdline = f.read()
            if pid != os.getpid() and b"bluetooth-hub" in cmdline:
                os.kill(pid, signal.SIGTERM)
                return True
        except (OSError, ValueError):
            pass
        return False


    def hideable(widget):
        """Make a widget that stays hidden until we call set_visible(True) on it."""
        widget.show_all()
        widget.set_no_show_all(True)
        widget.hide()
        return widget


    # ------------------------------------------------------------------ agent ---


    class Agent:
        """Answers BlueZ's pairing questions while the popup is open."""

        def __init__(self, ask, status, name_of):
            self.ask = ask  # ask(text, invocation): show a confirm/cancel prompt
            self.status = status  # status(text): show a message
            self.name_of = name_of  # name_of(device_path): display name
            self.registration = None

        def register(self, done=None):
            node = Gio.DBusNodeInfo.new_for_xml(AGENT_XML)
            try:
                self.registration = BUS.register_object(
                    AGENT_PATH, node.interfaces[0], self.on_call, None, None
                )
            except GLib.Error:
                self.registration = None
                if done is not None:
                    done(False)
                return

            def registered(_out, err):
                if err is not None:
                    if done is not None:
                        done(False)
                    return
                bz_call(
                    "/org/bluez", AGENT_MANAGER_IFACE, "RequestDefaultAgent",
                    GLib.Variant("(o)", (AGENT_PATH,)),
                    lambda _o, e: done(e is None) if done is not None else None,
                )

            bz_call(
                "/org/bluez", AGENT_MANAGER_IFACE, "RegisterAgent",
                GLib.Variant("(os)", (AGENT_PATH, "KeyboardDisplay")),
                registered,
            )

        def unregister(self):
            bz_call_sync(
                "/org/bluez", AGENT_MANAGER_IFACE, "UnregisterAgent",
                GLib.Variant("(o)", (AGENT_PATH,)),
            )
            if self.registration is not None:
                BUS.unregister_object(self.registration)
                self.registration = None

        def on_call(self, connection, sender, path, iface, method, params, invocation, *_):
            args = params.unpack() if params is not None else ()
            try:
                self.handle(method, args, invocation)
            except Exception as err:  # never leave BlueZ waiting on a reply
                invocation.return_dbus_error("org.bluez.Error.Rejected", str(err))

        def handle(self, method, args, invocation):
            if method == "RequestConfirmation":
                device, passkey = args
                self.ask(
                    "Pair with %s?\nCode: %06d\nMake sure it matches the one on the device."
                    % (self.name_of(device), passkey),
                    invocation,
                )
            elif method == "RequestAuthorization":
                self.ask("Allow %s to pair?" % self.name_of(args[0]), invocation)
            elif method == "AuthorizeService":
                invocation.return_value(None)
            elif method == "RequestPinCode":
                self.status("Using PIN 0000 for %s" % self.name_of(args[0]))
                invocation.return_value(GLib.Variant("(s)", ("0000",)))
            elif method == "RequestPasskey":
                invocation.return_dbus_error(
                    "org.bluez.Error.Rejected", "Passkey entry is not supported"
                )
            elif method == "DisplayPasskey":
                device, passkey = args[0], args[1]
                self.status("Type %06d on %s" % (passkey, self.name_of(device)))
                invocation.return_value(None)
            elif method == "DisplayPinCode":
                self.status("Enter PIN %s on %s" % (args[1], self.name_of(args[0])))
                invocation.return_value(None)
            else:  # Release, Cancel
                self.ask(None, invocation)
                invocation.return_value(None)


    # -------------------------------------------------------------------- UI ----


    class Hub(Gtk.Window):
        def __init__(self):
            super().__init__(title="bluetooth-hub")
            self.updating = False
            self.adapter = None
            self.names = {}
            self.busy = {}
            self.signature = None
            self.refresh_id = None
            self.status_id = None
            self.prompt_invocation = None
            self.was_active = False
            self.subscriptions = []
            self.started_discovery = False

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

            # header: title + on/off switch
            header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
            title = Gtk.Label(label="Bluetooth", xalign=0)
            title.get_style_context().add_class("title")
            self.switch = Gtk.Switch()
            self.switch.set_valign(Gtk.Align.CENTER)
            self.switch.connect("notify::active", self.on_switch)
            header.pack_start(title, True, True, 0)
            header.pack_end(self.switch, False, False, 0)
            panel = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
            panel.get_style_context().add_class("panel")
            panel.pack_start(header, False, False, 0)
            card.pack_start(panel, False, False, 0)

            # shown instead of the lists when Bluetooth is off or unavailable
            self.message = hideable(Gtk.Label(label="", xalign=0))
            self.message.get_style_context().add_class("hint")
            self.message.set_line_wrap(True)
            card.pack_start(self.message, False, False, 0)

            # paired devices
            self.paired_label = hideable(self.make_section("My devices"))
            self.paired_list, self.paired_scroll = self.make_list("No paired devices")
            card.pack_start(self.paired_label, False, False, 0)
            card.pack_start(self.paired_scroll, False, False, 0)

            # devices found while scanning
            self.nearby_label = hideable(self.make_section("Nearby"))
            self.nearby_list, self.nearby_scroll = self.make_list("Searching...")
            card.pack_start(self.nearby_label, False, False, 0)
            card.pack_start(self.nearby_scroll, False, False, 0)

            # pairing confirmation
            self.prompt = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
            self.prompt.get_style_context().add_class("panel")
            self.prompt_label = Gtk.Label(label="", xalign=0)
            self.prompt_label.set_line_wrap(True)
            buttons = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            confirm = Gtk.Button(label="Pair")
            confirm.get_style_context().add_class("action")
            confirm.connect("clicked", self.on_prompt_answer, True)
            cancel = Gtk.Button(label="Cancel")
            cancel.get_style_context().add_class("action")
            cancel.connect("clicked", self.on_prompt_answer, False)
            buttons.pack_start(confirm, True, True, 0)
            buttons.pack_start(cancel, True, True, 0)
            self.prompt.pack_start(self.prompt_label, False, False, 0)
            self.prompt.pack_start(buttons, False, False, 0)
            hideable(self.prompt)
            card.pack_start(self.prompt, False, False, 0)

            # transient messages (errors, pairing progress)
            self.status = hideable(Gtk.Label(label="", xalign=0))
            self.status.get_style_context().add_class("status")
            self.status.set_line_wrap(True)
            card.pack_start(self.status, False, False, 0)

            self.agent = Agent(self.ask, self.set_status, self.device_name)

            self.connect("key-press-event", self.on_key)
            self.connect("notify::is-active", self.on_active_changed)
            self.connect("destroy", lambda *_: self.quit())

            self.subscribe()
            self.refresh()
            self.agent.register()
            if self.adapter is not None and self.adapter["powered"]:
                self.start_discovery()

        # ------------------------------------------------------------ builders --

        def make_section(self, text):
            label = Gtk.Label(label=text, xalign=0)
            label.get_style_context().add_class("section")
            return label

        def make_list(self, placeholder):
            box = Gtk.ListBox()
            box.set_selection_mode(Gtk.SelectionMode.NONE)
            box.connect("row-activated", self.on_device_activated)
            hint = Gtk.Label(label=placeholder, xalign=0)
            hint.get_style_context().add_class("hint")
            hint.show()
            box.set_placeholder(hint)
            scroll = Gtk.ScrolledWindow()
            scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
            scroll.set_max_content_height(190)
            scroll.set_propagate_natural_height(True)
            scroll.add(box)
            return box, hideable(scroll)

        def status_text(self, dev):
            if dev["path"] in self.busy:
                return self.busy[dev["path"]]
            if dev["connected"]:
                text = "Connected"
                if dev["battery"] is not None:
                    text += " · %d%%" % dev["battery"]
                return text
            return "Not connected" if dev["paired"] else "Pair"

        def make_row(self, dev):
            row = Gtk.ListBoxRow()
            row.device = dev
            box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            dot = "●" if dev["connected"] else "○"
            name = Gtk.Label(label="%s  %s" % (dot, dev["name"]), xalign=0)
            name.get_style_context().add_class("name")
            name.set_ellipsize(3)  # Pango.EllipsizeMode.END
            name.set_hexpand(True)
            box.pack_start(name, True, True, 0)
            state = Gtk.Label(label=self.status_text(dev), xalign=1)
            state.get_style_context().add_class("dim")
            box.pack_start(state, False, False, 0)
            if dev["paired"]:
                forget = Gtk.Button(label="×")
                forget.set_relief(Gtk.ReliefStyle.NONE)
                forget.set_tooltip_text("Forget this device")
                forget.get_style_context().add_class("forget")
                forget.connect("clicked", self.on_forget, dev)
                box.pack_start(forget, False, False, 0)
            row.add(box)
            row.get_style_context().add_class("row")
            if dev["connected"]:
                row.get_style_context().add_class("current")
            row.show_all()
            return row

        def fill(self, listbox, devices):
            for child in listbox.get_children():
                listbox.remove(child)
            for dev in devices:
                listbox.add(self.make_row(dev))

        # ------------------------------------------------------------- state ----

        def device_name(self, path):
            return self.names.get(path) or path.rsplit("/", 1)[-1].replace("dev_", "").replace("_", ":")

        def subscribe(self):
            flags = Gio.DBusSignalFlags.NONE
            for iface, member in (
                (PROPS_IFACE, "PropertiesChanged"),
                (OBJMAN_IFACE, "InterfacesAdded"),
                (OBJMAN_IFACE, "InterfacesRemoved"),
            ):
                self.subscriptions.append(
                    BUS.signal_subscribe(
                        BLUEZ, iface, member, None, None, flags,
                        lambda *_: self.schedule_refresh(), None,
                    )
                )

        def schedule_refresh(self):
            if self.refresh_id is None:
                self.refresh_id = GLib.timeout_add(250, self.do_scheduled_refresh)

        def do_scheduled_refresh(self):
            self.refresh_id = None
            self.refresh()
            return False

        def show_lists(self, visible):
            for widget in (
                self.paired_label,
                self.paired_scroll,
                self.nearby_label,
                self.nearby_scroll,
            ):
                widget.set_visible(visible)

        def refresh(self):
            objects = get_objects()
            if objects is None:
                self.adapter = None
                self.show_lists(False)
                self.switch.set_sensitive(False)
                self.message.set_text("Bluetooth service not found.")
                self.message.set_visible(True)
                return

            adapter, devices = snapshot(objects)
            self.adapter = adapter
            self.names = {d["path"]: d["name"] for d in devices}

            if adapter is None:
                self.show_lists(False)
                self.switch.set_sensitive(False)
                self.message.set_text("No Bluetooth adapter found.")
                self.message.set_visible(True)
                return

            self.switch.set_sensitive(True)
            self.updating = True
            self.switch.set_active(adapter["powered"])
            self.updating = False

            if not adapter["powered"]:
                self.show_lists(False)
                self.message.set_text("Bluetooth is off.")
                self.message.set_visible(True)
                self.signature = None
                return

            self.message.set_visible(False)
            self.show_lists(True)
            self.nearby_label.set_text("Nearby · scanning" if adapter["discovering"] else "Nearby")

            def order(dev):
                return (not dev["connected"], dev["name"].lower())

            paired = sorted((d for d in devices if d["paired"]), key=order)
            nearby = sorted(
                (d for d in devices if not d["paired"] and d["named"]),
                key=lambda d: d["name"].lower(),
            )
            signature = (
                tuple(
                    (d["path"], d["name"], d["paired"], d["connected"], d["battery"])
                    for d in paired + nearby
                ),
                tuple(sorted(self.busy.items())),
            )
            if signature != self.signature:
                self.signature = signature
                self.fill(self.paired_list, paired)
                self.fill(self.nearby_list, nearby)

        def set_status(self, text, timeout=8000):
            if self.status_id is not None:
                GLib.source_remove(self.status_id)
                self.status_id = None
            if not text:
                self.status.set_visible(False)
                return
            self.status.set_text(text)
            self.status.set_visible(True)
            if timeout:
                self.status_id = GLib.timeout_add(timeout, self.clear_status)

        def clear_status(self):
            self.status_id = None
            self.status.set_visible(False)
            return False

        # ------------------------------------------------------------- power ----

        def on_switch(self, switch, _pspec):
            if self.updating or self.adapter is None:
                return
            self.set_power(switch.get_active())

        def set_power(self, on, retry=True):
            args = GLib.Variant("(ssv)", (ADAPTER_IFACE, "Powered", GLib.Variant("b", on)))

            def done(_out, err):
                if err is not None:
                    message = clean_error(err)
                    if on and retry and "rfkill" in message.lower():
                        fire("rfkill", "unblock", "bluetooth")
                        GLib.timeout_add(700, self.retry_power)
                        return
                    self.set_status("Couldn't change Bluetooth: " + message)
                elif on:
                    GLib.timeout_add(800, self.delayed_discovery)
                self.schedule_refresh()

            bz_call(self.adapter["path"], PROPS_IFACE, "Set", args, done)

        def retry_power(self):
            if self.adapter is not None:
                self.set_power(True, retry=False)
            return False

        def delayed_discovery(self):
            self.start_discovery()
            return False

        def start_discovery(self):
            if self.adapter is None:
                return
            self.started_discovery = True
            bz_call(self.adapter["path"], ADAPTER_IFACE, "StartDiscovery", None)

        # ----------------------------------------------------------- devices ----

        def on_device_activated(self, _box, row):
            dev = row.device
            if dev["path"] in self.busy:
                return
            if dev["connected"]:
                self.run_action(dev["path"], "Disconnecting...", "Disconnect")
            elif dev["paired"]:
                self.run_action(dev["path"], "Connecting...", "Connect")
            else:
                self.pair(dev)

        def run_action(self, path, label, method, timeout=30000):
            self.busy[path] = label
            self.schedule_refresh()

            def done(_out, err):
                self.busy.pop(path, None)
                if err is not None:
                    self.set_status(clean_error(err))
                self.schedule_refresh()

            bz_call(path, DEVICE_IFACE, method, None, done, timeout)

        def pair(self, dev):
            path = dev["path"]
            self.busy[path] = "Pairing..."
            self.set_status("Pairing with %s..." % dev["name"], 0)
            self.schedule_refresh()

            def paired(_out, err):
                if err is not None:
                    self.busy.pop(path, None)
                    self.set_status("Pairing failed: " + clean_error(err))
                    self.schedule_refresh()
                    return
                self.set_status("Paired with %s" % dev["name"])
                trust = GLib.Variant("(ssv)", (DEVICE_IFACE, "Trusted", GLib.Variant("b", True)))
                bz_call(
                    path, PROPS_IFACE, "Set", trust,
                    lambda _o, _e: self.run_action(path, "Connecting...", "Connect"),
                )

            def go(*_):
                bz_call(path, DEVICE_IFACE, "Pair", None, paired, 90000)

            # BlueZ pairs more reliably when it isn't scanning at the same time
            if self.adapter is not None:
                bz_call(self.adapter["path"], ADAPTER_IFACE, "StopDiscovery", None, go)
            else:
                go()

        def on_forget(self, _btn, dev):
            if self.adapter is None:
                return
            path = dev["path"]
            self.busy[path] = "Removing..."
            self.schedule_refresh()

            def done(_out, err):
                self.busy.pop(path, None)
                if err is not None:
                    self.set_status(clean_error(err))
                self.schedule_refresh()

            bz_call(
                self.adapter["path"], ADAPTER_IFACE, "RemoveDevice",
                GLib.Variant("(o)", (path,)), done,
            )

        # ------------------------------------------------------ pairing prompt --

        def ask(self, text, invocation):
            """Show a confirm/cancel prompt, or (text=None) drop the current one."""
            if self.prompt_invocation is not None:
                self.prompt_invocation.return_dbus_error("org.bluez.Error.Canceled", "Canceled")
                self.prompt_invocation = None
            if text is None:
                self.prompt.set_visible(False)
                return
            self.prompt_invocation = invocation
            self.prompt_label.set_text(text)
            self.prompt.set_visible(True)

        def on_prompt_answer(self, _btn, accepted):
            invocation, self.prompt_invocation = self.prompt_invocation, None
            self.prompt.set_visible(False)
            if invocation is None:
                return
            if accepted:
                invocation.return_value(None)
            else:
                invocation.return_dbus_error("org.bluez.Error.Rejected", "Rejected")

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

        def quit(self):
            if self.prompt_invocation is not None:
                self.prompt_invocation.return_dbus_error("org.bluez.Error.Canceled", "Canceled")
                self.prompt_invocation = None
            if self.started_discovery and self.adapter is not None:
                bz_call_sync(self.adapter["path"], ADAPTER_IFACE, "StopDiscovery", None)
            self.agent.unregister()
            for sub in self.subscriptions:
                BUS.signal_unsubscribe(sub)
            self.subscriptions = []
            try:
                os.remove(PIDFILE)
            except OSError:
                pass
            Gtk.main_quit()


    def load_css():
        path = os.environ.get("BLUETOOTH_HUB_CSS")
        if not path:
            return
        provider = Gtk.CssProvider()
        try:
            provider.load_from_path(path)
        except GLib.Error as err:
            print("bluetooth-hub: bad css: %s" % err, file=sys.stderr)
            return
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER
        )


    def main():
        global BUS
        if toggle_existing_instance():
            return
        try:
            BUS = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
        except GLib.Error as err:
            print("bluetooth-hub: no system bus: %s" % err, file=sys.stderr)
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

  bluetooth-hub = pkgs.stdenv.mkDerivation {
    pname = "bluetooth-hub";
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
      install -Dm755 ${script} $out/bin/bluetooth-hub
      sed -i '1c #!${pythonEnv}/bin/python3' $out/bin/bluetooth-hub
      runHook postInstall
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix PATH : ${lib.makeBinPath [ pkgs.util-linux ]}
        --prefix LD_PRELOAD : ${pkgs.gtk-layer-shell}/lib/libgtk-layer-shell.so
        --set BLUETOOTH_HUB_CSS ${css}
      )
    '';
  };
in
{
  home.packages = [ bluetooth-hub ];
}
