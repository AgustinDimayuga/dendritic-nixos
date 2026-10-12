{
  config,
  lib,
  pkgs,
  ...
}:
let
  internal = "eDP-1";
  # Internal keyboard name; check with `hyprctl devices`
  keyboard = "at-translated-set-2-keyboard";

  clamshell = pkgs.writeShellApplication {
    name = "clamshell";
    runtimeInputs = [
      pkgs.jq
      pkgs.gawk
      pkgs.coreutils
    ];
    text = ''
      internal="${internal}"
      keyboard="${keyboard}"
      cache="''${XDG_RUNTIME_DIR:-/tmp}/clamshell-devices"

      lid_closed() {
        [ "$(busctl --system get-property org.freedesktop.login1 \
          /org/freedesktop/login1 org.freedesktop.login1.Manager LidClosed \
          | awk '{print $2}')" = "true" ]
      }

      set_devices() { # $1 = true | false
        if [ "$1" = false ]; then
          hyprctl devices -j | jq -r --arg kb "$keyboard" '
            [ (.mice[]      | select(.name | test("pixa3854|touchpad"; "i")) | .name),
              (.touch[]?    | .name),
              (.keyboards[] | select(.name == $kb)                           | .name) ] | .[]' \
            >> "$cache" || true
        fi
        [ -f "$cache" ] || return 0
        sort -u "$cache" | while read -r dev; do
          hyprctl eval "hl.device({ name = \"$dev\", enabled = $1 })" >/dev/null
        done
        if [ "$1" = true ]; then rm -f "$cache"; fi
      }

      case "''${1:-apply}" in
        hotplug)
          # Give monitors a moment to settle after plug/unplug/wake
          sleep 1
          exec "$0" apply
          ;;
        apply)
          monitors="$(hyprctl monitors -j)"
          total="$(jq length <<<"$monitors")"
          externals="$(jq --arg i "$internal" '[.[] | select(.name != $i)] | length' <<<"$monitors")"
          internal_active="$(jq --arg i "$internal" 'any(.[]; .name == $i)' <<<"$monitors")"

          # Zero active monitors (e.g. unplugged while asleep in clamshell):
          # bring input back directly, then reload to re-enable the internal panel
          if [ "$total" -eq 0 ]; then
            set_devices true
            hyprctl reload
            exit 0
          fi

          if lid_closed && [ "$externals" -gt 0 ]; then
            set_devices false
            if [ "$internal_active" = true ]; then
              hyprctl eval "hl.monitor({ output = \"$internal\", disabled = true })"
            fi
          else
            set_devices true
            if [ "$internal_active" = false ]; then
              hyprctl eval 'hl.monitor({ output = "${internal}", mode = "2880x1920@120", position = "auto-left", scale = 2, disabled = false })'
            fi
          fi
          ;;
      esac
    '';
  };
  exe = lib.getExe clamshell;
  lua = lib.generators.mkLuaInline;
in
{
  options.clamshell.package = lib.mkOption {
    type = lib.types.package;
    internal = true;
    default = clamshell;
  };

  config = lib.mkIf config.hyprland-laptop.enable {
    wayland.windowManager.hyprland.settings = {
      bind = [
        # Fires on both lid close and lid open; the script checks the actual state
        {
          _args = [
            "switch:Lid Switch"
            (lua ''hl.dsp.exec_cmd("${exe} apply")'')
            { locked = true; }
          ];
        }
      ];

      on = [
        {
          _args = [
            "monitor.added"
            (lua ''function() hl.exec_cmd("${exe} hotplug") end'')
          ];
        }
        {
          _args = [
            "monitor.removed"
            (lua ''function() hl.exec_cmd("${exe} hotplug") end'')
          ];
        }
        # Saving the config re-enables the disabled panel, so re-apply
        {
          _args = [
            "config.reloaded"
            (lua ''function() hl.exec_cmd("${exe} hotplug") end'')
          ];
        }
      ];
    };
  };
}
