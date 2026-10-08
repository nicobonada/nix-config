{
  coreutils,
  gamemode,
  runCommand,
  writeShellApplication,
}:

let
  # Steam Linux Runtime 4.0. The manifest format takes this app id,
  # not the runtime's name. Steam reads it when Steam starts and
  # prepares that runtime before this script runs. A Proton whose
  # own manifest asks for another id is refused.
  runtimeAppId = "4183110";

  launcher = writeShellApplication {
    name = "proton-gamemode";
    runtimeInputs = [ coreutils ];
    text = ''
      declare -A seen

      best=""
      best_mtime=-1

      shopt -s nullglob
      for root in \
        "$HOME/.local/share/Steam/compatibilitytools.d" \
        "$HOME/.steam/root/compatibilitytools.d"
      do
        if [[ ! -d $root ]]; then
          continue
        fi
        for dir in "$root"/*; do
          if [[ ! -d $dir ]]; then
            continue
          fi
          real=$(realpath "$dir")
          if [[ -n ''${seen[$real]:-} ]]; then
            continue
          fi
          seen[$real]=1
          if [[ ! -x $real/proton || ! -f $real/toolmanifest.vdf ]]; then
            continue
          fi
          manifest=$(<"$real/toolmanifest.vdf")
          # A doubled single quote is a Nix escape, so these quotes stay paired.
          if [[ $manifest != *'compatmanager_layer_name'*'"proton"'* ]]; then
            continue
          fi
          mtime=$(stat -c %Y "$real")
          if ((mtime > best_mtime)); then
            best=$real
            best_mtime=$mtime
          fi
        done
      done

      if [[ -z $best ]]; then
        echo "proton-gamemode: no Proton in compatibilitytools.d. Install one with protonup-rs." >&2
        exit 1
      fi

      manifest=$(<"$best/toolmanifest.vdf")
      appid=""
      if [[ $manifest =~ require_tool_appid[^0-9]*([0-9]+) ]]; then
        appid=''${BASH_REMATCH[1]}
      fi
      if [[ $appid != "${runtimeAppId}" ]]; then
        echo "proton-gamemode: $best asks for runtime ''${appid:-<none>}, this tool is built for ${runtimeAppId}." >&2
        exit 1
      fi

      exec ${gamemode}/bin/gamemoderun "$best/proton" "$@"
    '';
  };
in
runCommand "proton-gamemode"
  {
    outputs = [
      "out"
      "steamcompattool"
    ];
    passthru = {
      inherit launcher runtimeAppId;
    };
  }
  ''
    echo "Use programs.steam.extraCompatPackages. This package is not a PATH tool." > "$out"

    mkdir -p "$steamcompattool"
    cp ${launcher}/bin/proton-gamemode "$steamcompattool/proton-gamemode"

    cat > "$steamcompattool/compatibilitytool.vdf" <<'EOF'
    "compatibilitytools"
    {
      "compat_tools"
      {
        "proton-gamemode"
        {
          "install_path" "."
          "display_name" "GameMode"
          "from_oslist" "windows"
          "to_oslist" "linux"
        }
      }
    }
    EOF

    cat > "$steamcompattool/toolmanifest.vdf" <<'EOF'
    "manifest"
    {
      "version" "2"
      "commandline" "/proton-gamemode %verb%"
      "require_tool_appid" "${runtimeAppId}"
      "use_sessions" "1"
      "compatmanager_layer_name" "proton"
    }
    EOF
  ''
