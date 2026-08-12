{
  symlinkJoin,
  makeWrapper,
  brave,
}:
# Brave with loopback CDP so Grok/Playwright MCP can attach to the *same*
# session (read open tabs). Port is 127.0.0.1 only — full browser control
# for anything that can hit that port on this machine.
# Must fully quit Brave for flags to apply (second launch reuses the process).
symlinkJoin {
  name = "brave-with-cdp";
  paths = [ brave ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/brave \
      --add-flags "--remote-debugging-port=9222" \
      --add-flags "--remote-debugging-address=127.0.0.1" \
      --add-flags "--disable-blink-features=AutomationControlled"
  '';
}
