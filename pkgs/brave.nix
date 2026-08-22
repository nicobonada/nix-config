{
  lib,
  brave,
  runCommand,
}:
let
  # Bin-only: a full second Brave would collide on bin/brave and
  # brave-browser.desktop. --class is the Wayland app-id; user-data-dir is
  # the Chromium singleton lock. Must fully quit Brave for flags to apply
  # (second launch reuses the process).
  mkProfile =
    {
      name,
      userDataDir,
      extraArgs ? [ ],
    }:
    let
      pkg = brave.override {
        commandLineArgs = lib.concatStringsSep " " (
          [
            "--class=${name}"
            "--user-data-dir=${userDataDir}"
            "--no-first-run"
            "--no-default-browser-check"
          ]
          ++ extraArgs
        );
      };
    in
    runCommand name { meta.mainProgram = name; } ''
      mkdir -p $out/bin
      ln -s ${lib.getExe pkg} $out/bin/${name}
    '';

  cdp = port: [
    "--remote-debugging-port=${toString port}"
    "--remote-debugging-address=127.0.0.1"
    "--disable-blink-features=AutomationControlled"
  ];
in
{
  # Default / work. CDP 9222 so Grok/Playwright can attach (loopback only).
  brave-work = mkProfile {
    name = "brave-work";
    userDataDir = "$HOME/.local/share/brave-work";
    extraArgs = cdp 9222;
  };

  # Personal (ASUS on oakhill). Own CDP port so it can run next to work.
  brave-personal = mkProfile {
    name = "brave-personal";
    userDataDir = "$HOME/.local/share/brave-personal";
    extraArgs = cdp 9223;
  };

  # Separate history; not mixed with work or personal. No CDP.
  brave-scratch = mkProfile {
    name = "brave-scratch";
    userDataDir = "$HOME/.local/share/brave-scratch";
  };
}
