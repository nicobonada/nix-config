{ pkgs, ... }:

let
  cycle-audio-profile = pkgs.writeShellApplication {
    name = "cycle-audio-profile";

    runtimeInputs = [
      pkgs.pulseaudio
      pkgs.libnotify
    ];

    text = ''
      set -euo pipefail

      HEADSET_SINK="alsa_output.usb-HP__Inc_HyperX_Cloud_Alpha_Wireless_00000001-00.analog-stereo"
      HEADSET_SOURCE="alsa_input.usb-HP__Inc_HyperX_Cloud_Alpha_Wireless_00000001-00.mono-fallback"

      DESK_SINK="alsa_output.usb-FIIO_FiiO_K11-01.analog-stereo"
      DESK_SOURCE="alsa_input.pci-0000_2f_00.4.analog-stereo"

      COMBINED_NAME="combined_output"

      get_state() {
        pactl get-default-sink
      }

      combined_exists() {
        pactl list short sinks | grep -q "$COMBINED_NAME"
      }

      create_combined() {
        if ! combined_exists; then
          pactl load-module module-combine-sink \
            sink_name="$COMBINED_NAME" \
            slaves="$HEADSET_SINK,$DESK_SINK"
        fi
      }

      remove_combined() {
        pactl list short modules \
          | grep module-combine-sink \
          | awk '{print $1}' \
          | while read -r id; do
              pactl unload-module "$id"
            done || true
      }

      move_streams() {
        while read -r id _; do
          pactl move-sink-input "$id" @DEFAULT_SINK@
        done < <(pactl list short sink-inputs)
      }

      CURRENT="$(get_state)"

      if [ "$CURRENT" = "$HEADSET_SINK" ]; then

        # 1 → 2
        remove_combined

        pactl set-default-sink "$DESK_SINK"
        pactl set-default-source "$DESK_SOURCE"

        notify-send "Audio: Desk"

      elif [ "$CURRENT" = "$DESK_SINK" ]; then

        # 2 → 3
        create_combined

        pactl set-default-sink "$COMBINED_NAME"

        notify-send "Audio: Co-op (both outputs)"

      else

        # 3 → 1
        remove_combined

        pactl set-default-sink "$HEADSET_SINK"
        pactl set-default-source "$HEADSET_SOURCE"

        notify-send "Audio: Headset"

      fi

      move_streams
    '';
  };

in
{
  environment.systemPackages = [
    cycle-audio-profile
  ];
}
