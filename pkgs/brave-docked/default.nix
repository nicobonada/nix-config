{
  writeShellApplication,
  brave,
}:
# Recreation Brave on the ASUS (oakhill). Own process + user-data-dir so
# --class becomes a distinct Wayland app-id (Chromium singleton lock).
# Unwrapped brave: the CDP wrapper binds :9222, already used by work Brave.
writeShellApplication {
  name = "brave-docked";
  runtimeInputs = [ brave ];
  text = ''
    exec brave \
      --class=brave-docked \
      --user-data-dir="$HOME/.local/share/brave-docked" \
      --no-first-run \
      --no-default-browser-check \
      "$@"
  '';
}
