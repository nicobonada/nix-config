{ pkgs, ... }:

let
  toggle-audio-profile = pkgs.writeShellApplication {
    name = "toggle-audio-profile";

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

      CURRENT="$(pactl get-default-sink)"

      if [ "$CURRENT" = "$HEADSET_SINK" ]; then
        pactl set-default-sink "$DESK_SINK"
        pactl set-default-source "$DESK_SOURCE"
        notify-send "Audio: Desk (FiiO + PCI mic)"
      else
        pactl set-default-sink "$HEADSET_SINK"
        pactl set-default-source "$HEADSET_SOURCE"
        notify-send "Audio: Headset (HyperX)"
      fi

      # Move active playback streams
      while read -r id _; do
        pactl move-sink-input "$id" @DEFAULT_SINK@
      done < <(pactl list short sink-inputs)

      # Move active recording streams
      while read -r id _; do
        pactl move-source-output "$id" @DEFAULT_SOURCE@
      done < <(pactl list short source-outputs)
    '';
  };

in
{
  environment.systemPackages = [
    toggle-audio-profile
  ];
}
