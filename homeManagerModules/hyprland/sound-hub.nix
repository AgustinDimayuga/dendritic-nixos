{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.theme;

  draculaColors = ''
    * {
        bg-col:  #282a36;
        panel: #44475a;
        border-col: #f8f8f2;
        selected-col: #44475a;
        sel-text: #8be9fd;
        fg-col: #f8f8f2;
        fg-col2: #6272a4;
    }
  '';

  gruvboxColors = ''
    * {
        bg-col:  #282828;
        panel: #3c3836;
        border-col: #ebdbb2;
        selected-col: #a89984;
        sel-text: #282828;
        fg-col: #ebdbb2;
        fg-col2: #d5c4a1;
    }
  '';

  colors = if theme == "dracula" then draculaColors else gruvboxColors;

  layout = ''
    * {
        font: "JetBrainsMono Nerd Font 13";
        background-color: transparent;
        text-color: @fg-col;
    }
    window {
        location: northeast;
        anchor: northeast;
        x-offset: -8px;
        y-offset: 40px;
        width: 360px;
        border: 2px;
        border-color: @border-col;
        border-radius: 12px;
        background-color: @bg-col;
    }
    mainbox {
        children: [ message, listview ];
        padding: 12px;
        spacing: 10px;
        background-color: @bg-col;
    }
    message {
        padding: 12px;
        border-radius: 8px;
        background-color: @panel;
    }
    textbox {
        text-color: @fg-col;
        background-color: transparent;
    }
    listview {
        lines: 5;
        columns: 1;
        dynamic: true;
        scrollbar: false;
        spacing: 4px;
        background-color: @bg-col;
    }
    element {
        padding: 8px 10px;
        border-radius: 8px;
        background-color: @bg-col;
        text-color: @fg-col;
    }
    element selected {
        background-color: @selected-col;
        text-color: @sel-text;
    }
    element-text {
        background-color: inherit;
        text-color: inherit;
    }
  '';

  sound-hub = pkgs.writeShellApplication {
    name = "sound-hub";
    runtimeInputs = [
      pkgs.rofi
      pkgs.wireplumber
      pkgs.pipewire
      pkgs.jq
      pkgs.gawk
      pkgs.procps
      pkgs.pavucontrol
    ];
    text = ''
      theme="$HOME/.config/rofi/sound-hub.rasi"

      # A second click on the bar closes the hub
      if pgrep -f "rofi.*sound-hub.rasi" >/dev/null; then
        pkill -f "rofi.*sound-hub.rasi"
        exit 0
      fi

      while true; do
        vol_line=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        pct=$(awk '{ printf "%d", $2 * 100 }' <<<"$vol_line")
        muted=false
        if [[ "$vol_line" == *MUTED* ]]; then muted=true; fi

        if $muted; then state="Muted"; else state="$pct%"; fi

        filled=$(( pct > 100 ? 20 : pct * 20 / 100 ))
        bar=""
        for ((i = 0; i < 20; i++)); do
          if (( i < filled )); then bar+="█"; else bar+="░"; fi
        done

        current=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | awk 'NR == 1 { gsub(",", "", $2); print $2 }')

        sel=0
        ids=()
        entries=()
        while IFS=$'\t' read -r id desc; do
          if [[ "$id" == "$current" ]]; then
            sel=''${#ids[@]}
            entries+=("●  $desc")
          else
            entries+=("○  $desc")
          fi
          ids+=("$id")
        done < <(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Node") | select(.info.props["media.class"] == "Audio/Sink") | "\(.id)\t\(.info.props["node.description"] // .info.props["node.name"])"')

        if $muted; then entries+=("   Unmute"); else entries+=("   Mute"); fi
        entries+=("   Sound settings")

        mesg="<b>Sound</b>   $state"$'\n'"$bar"$'\n'"<span size=\"small\">←/→ volume   Ctrl+M mute</span>"

        rc=0
        choice=$(printf '%s\n' "''${entries[@]}" | rofi -dmenu -i -format i -p "" \
          -theme "$theme" \
          -mesg "$mesg" \
          -selected-row "$sel" \
          -kb-accept-entry "Control+j,Return,KP_Enter" \
          -kb-move-char-back "Control+b" \
          -kb-move-char-forward "Control+f" \
          -kb-custom-1 "Left" \
          -kb-custom-2 "Right" \
          -kb-custom-3 "Control+m") || rc=$?

        case "$rc" in
          0)
            n=''${#ids[@]}
            if (( choice < n )); then
              wpctl set-default "''${ids[$choice]}"
            elif (( choice == n )); then
              wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            else
              setsid -f pavucontrol >/dev/null 2>&1
              exit 0
            fi
            ;;
          10)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
            ;;
          11)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
            ;;
          12)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            ;;
          *)
            exit 0
            ;;
        esac
      done
    '';
  };
in
{
  home.packages = [ sound-hub ];

  xdg.configFile."rofi/sound-hub.rasi".text = colors + layout;
}
