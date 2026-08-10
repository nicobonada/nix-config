{
  config,
  pkgs,
  lib,
  ...
}:
let
  gui = config.programs._1password-gui.package;
  # nixpkgs patches 1password / BrowserSupport / op-ssh-sign but not 1password-mcp.
  onePasswordMcpRaw = pkgs.runCommand "1password-mcp-raw" { nativeBuildInputs = [ pkgs.patchelf ]; } ''
    mkdir -p $out/bin
    cp ${gui}/share/1password/1password-mcp $out/bin/1password-mcp-raw
    chmod +w $out/bin/1password-mcp-raw
    interp=$(patchelf --print-interpreter ${gui}/share/1password/1password)
    rpath=$(patchelf --print-rpath ${gui}/share/1password/1password)
    patchelf --set-interpreter "$interp" --set-rpath "$rpath" $out/bin/1password-mcp-raw
  '';
  # Official binary speaks NDJSON; Grok MCP host uses Content-Length frames.
  onePasswordMcp = pkgs.writeShellApplication {
    name = "1password-mcp";
    runtimeInputs = [
      pkgs.python3
      onePasswordMcpRaw
    ];
    text = ''
      export ONEPASSWORD_MCP_RAW="${onePasswordMcpRaw}/bin/1password-mcp-raw"
      exec python3 ${../../scripts/1password-mcp-adapter.py}
    '';
  };
in
{
  # Human desktop + CLI (niri/Noctalia): setgid op, BrowserSupport, polkit owners.
  # Session polkit agent: Noctalia shell.polkit_agent (not polkit-gnome).
  # Agent: official Environments MCP via 1password-mcp (adapter on PATH).
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "nico" ];
  };

  environment.systemPackages = lib.mkIf config.programs._1password-gui.enable [
    onePasswordMcp
  ];
}
