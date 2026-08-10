{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs._1password-gui;
  gui = cfg.package;

  # Local stand-in for NixOS/nixpkgs#537630 until it lands:
  #   - ids.gids.onepassword-mcp = 31003
  #   - users.groups.onepassword-mcp
  #   - security.wrappers."1password-mcp" (setgid)
  #   - package patchelf of the MCP binary
  # Upstream will also add programs._1password-gui.mcpServer.enable; we always
  # enable the setgid path here because we use Environments MCP with Grok.
  #
  # nixpkgs still does not patchelf 1password-mcp (only main app + BrowserSupport
  # + op-ssh-sign). PR patches it in the package; until then, a thin derivation
  # supplies a store path the security wrapper can setgid.
  onePasswordMcpPatched = pkgs.runCommand "1password-mcp-patched" {
    nativeBuildInputs = [ pkgs.patchelf ];
  } ''
    mkdir -p $out/share/1password
    cp ${gui}/share/1password/1password-mcp $out/share/1password/1password-mcp
    chmod +w $out/share/1password/1password-mcp
    interp=$(patchelf --print-interpreter ${gui}/share/1password/1password)
    rpath=$(patchelf --print-rpath ${gui}/share/1password/1password)
    patchelf --set-interpreter "$interp" --set-rpath "$rpath" \
      $out/share/1password/1password-mcp
  '';

  # Thin bridge around the setgid MCP binary:
  #   - Always spawn /run/wrappers/bin/1password-mcp (peer GID checks).
  #   - Auto-detect host framing (NDJSON vs legacy Content-Length). Current
  #     Grok Build uses rmcp AsyncRwTransport → NDJSON; older notes that Grok
  #     spoke Content-Length were wrong and caused 30–60s startup timeouts.
  onePasswordMcpForGrok = pkgs.writeShellApplication {
    name = "1password-mcp-grok";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      export ONEPASSWORD_MCP_RAW=/run/wrappers/bin/1password-mcp
      export PYTHONUNBUFFERED=1
      exec python3 -u ${../../scripts/1password-mcp-adapter.py}
    '';
  };
in
{
  # Human desktop + CLI (niri/Noctalia): setgid op, BrowserSupport, polkit owners.
  # Session polkit agent: Noctalia shell.polkit_agent (not polkit-gnome).
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "nico" ];
  };

  # Match #537630 / official after-install.sh: dedicated group + setgid so the
  # desktop can verify MCP peers via SO_PEERCRED. Without this, logs show:
  #   Rejecting MCP connection: Linux peer effective GID check failed
  # GID >1000 required (same rule as onepassword / onepassword-cli).
  users.groups.onepassword-mcp.gid = 31003;

  security.wrappers."1password-mcp" = {
    source = "${onePasswordMcpPatched}/share/1password/1password-mcp";
    owner = "root";
    group = "onepassword-mcp";
    setuid = false;
    setgid = true;
  };

  environment.systemPackages = lib.mkIf cfg.enable [
    onePasswordMcpForGrok
  ];
}
