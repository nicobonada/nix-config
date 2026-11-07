{
  lib,
  helium,
  writeShellApplication,
}:
let
  # Bin-only: a full second Helium would collide on bin/helium and
  # helium.desktop. --class is the Wayland app-id; user-data-dir is the
  # Chromium singleton lock. Must fully quit Helium for flags to apply
  # (second launch reuses the process).
  mkProfile =
    {
      name,
      userDataDir,
      extraArgs ? [ ],
    }:
    writeShellApplication {
      inherit name;
      text = ''
        exec ${lib.getExe helium} \
          --class=${name} \
          --user-data-dir="${userDataDir}" \
          --no-first-run \
          --no-default-browser-check \
          --enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoEncoder,WaylandWindowDecorations \
          ${lib.escapeShellArgs extraArgs} \
          "$@"
      '';
    };

  cdp = port: [
    "--remote-debugging-port=${toString port}"
    "--remote-debugging-address=127.0.0.1"
    "--disable-blink-features=AutomationControlled"
  ];
in
{
  # Default / work. CDP 9222 so Grok/Playwright can attach (loopback only).
  helium-work = mkProfile {
    name = "helium-work";
    userDataDir = "$HOME/.local/share/helium-work";
    extraArgs = cdp 9222;
  };

  # Personal (ASUS on oakhill). Own CDP port so it can run next to work.
  helium-personal = mkProfile {
    name = "helium-personal";
    userDataDir = "$HOME/.local/share/helium-personal";
    extraArgs = cdp 9223;
  };

  # Separate history; not mixed with work or personal. No CDP.
  helium-scratch = mkProfile {
    name = "helium-scratch";
    userDataDir = "$HOME/.local/share/helium-scratch";
  };
}
