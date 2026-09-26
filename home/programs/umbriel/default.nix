{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  umbriel = inputs.umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # Drop when upstream ships share/fish/vendor_completions.d/umbriel.fish:
  # the build-time check below then emits an empty sidecar.
  fishCompletions =
    pkgs.runCommand "umbriel-fish-completions"
      {
        nativeBuildInputs = [ pkgs.python3 ];
      }
      ''
        mkdir -p $out/share/fish/vendor_completions.d
        if [ -e ${umbriel}/share/fish/vendor_completions.d/umbriel.fish ]; then
          echo "upstream fish completions present; sidecar idle" > $out/README
          exit 0
        fi
        python3 ${./gen-fish-completions.py} ${lib.getExe umbriel} \
          > $out/share/fish/vendor_completions.d/umbriel.fish
      '';

  # Keybinds overlay Umbriel's built-ins. Unset chords stay. Niri KDL stays
  # the backup, including Mod+O for Brave.
  # Output sections live in a host file. Umbriel rejects the same monitor in
  # two files, and this home config is built once for both seats, so the
  # choice is which store file outputs.toml points at.
  toml = pkgs.formats.toml { };
  outputsFor = vrr: import ./settings/outputs.nix { inherit vrr; };
  oakhillOutputs = toml.generate "umbriel-outputs-oakhill.toml" (outputsFor true);
  seyruunOutputs = toml.generate "umbriel-outputs-seyruun.toml" (outputsFor false);
  settings = lib.foldl' lib.recursiveUpdate { } [
    (import ./settings/general.nix { inherit pkgs lib; })
    (import ./settings/input.nix)
    (import ./settings/layout.nix)
    (import ./settings/rules.nix)
    (import ./settings/keybinds.nix)
    {
      include.files = [ "~/.config/umbriel/outputs.toml" ];
    }
  ];
in
{
  imports = [ inputs.umbriel.homeModules.default ];

  programs.umbriel = {
    enable = true;
    inherit settings;
  };

  home.packages = [ fishCompletions ];

  # Before the new config.toml is linked, so a reload can see the include.
  home.activation.umbrielOutputs = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    dest="${config.home.homeDirectory}/.config/umbriel/outputs.toml"
    mkdir -p "$(dirname "$dest")"
    if [[ $(< /proc/sys/kernel/hostname) == oakhill ]]; then
      src=${oakhillOutputs}
    else
      src=${seyruunOutputs}
    fi
    old=$(readlink "$dest" || true)
    ln -sfn "$src" "$dest"
    sock="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/umbriel-wayland-0.sock"
    if [[ $old != "$src" && -S $sock ]]; then
      ${lib.getExe umbriel} msg config-reload || true
    fi
  '';
}
