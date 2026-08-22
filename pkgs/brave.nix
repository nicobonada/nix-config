{
  lib,
  brave,
  runCommand,
}:
{
  # Brave with loopback CDP so Grok/Playwright MCP can attach to the *same*
  # session (read open tabs). Port is 127.0.0.1 only — full browser control
  # for anything that can hit that port on this machine.
  # Must fully quit Brave for flags to apply (second launch reuses the process).
  brave-with-cdp = brave.override {
    commandLineArgs = lib.concatStringsSep " " [
      "--remote-debugging-port=9222"
      "--remote-debugging-address=127.0.0.1"
      "--disable-blink-features=AutomationControlled"
    ];
  };

  # Recreation Brave on the ASUS (oakhill). Own process + user-data-dir so
  # --class becomes a distinct Wayland app-id (Chromium singleton lock).
  # Bin only: installing the full second Brave would collide with
  # brave-with-cdp (bin/brave, brave-browser.desktop).
  brave-docked =
    let
      pkg = brave.override {
        commandLineArgs = lib.concatStringsSep " " [
          "--class=brave-docked"
          "--user-data-dir=$HOME/.local/share/brave-docked"
          "--no-first-run"
          "--no-default-browser-check"
        ];
      };
    in
    runCommand "brave-docked" { meta.mainProgram = "brave-docked"; } ''
      mkdir -p $out/bin
      ln -s ${lib.getExe pkg} $out/bin/brave-docked
    '';
}
