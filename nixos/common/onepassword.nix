{
  config,
  pkgs,
  lib,
  ...
}:
let
  gui = config.programs._1password-gui.package;
  # nixpkgs patches 1password / BrowserSupport / op-ssh-sign but not 1password-mcp.
  # Without the same interpreter+rpath, NixOS stub-ld rejects the binary.
  # Official MCP is Environments-only (names + .env mounts; no secret values to the model).
  onePasswordMcp = pkgs.runCommand "1password-mcp" { nativeBuildInputs = [ pkgs.patchelf ]; } ''
    mkdir -p $out/bin
    cp ${gui}/share/1password/1password-mcp $out/bin/1password-mcp
    chmod +w $out/bin/1password-mcp
    interp=$(patchelf --print-interpreter ${gui}/share/1password/1password)
    rpath=$(patchelf --print-rpath ${gui}/share/1password/1password)
    patchelf --set-interpreter "$interp" --set-rpath "$rpath" $out/bin/1password-mcp
  '';
in
{
  # Human desktop + CLI (niri/Noctalia): setgid op, BrowserSupport, polkit owners.
  # Session polkit agent: Noctalia shell.polkit_agent (not polkit-gnome).
  # Agent secrets path: official Environments MCP (1password-mcp), not Service Account.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "nico" ];
  };

  environment.systemPackages = lib.mkIf config.programs._1password-gui.enable [
    onePasswordMcp
  ];
}
