{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs._1password-gui;
  custom = import ../../pkgs { inherit pkgs; };

  # Prefer the module's GUI package when it differs from nixpkgs default.
  onePasswordMcpPatched = custom.onepassword-mcp-patched.override {
    gui = cfg.package;
  };
  onePasswordMcpForGrok = custom.onepassword-mcp-for-grok;
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
  # Local stand-in for NixOS/nixpkgs#537630 until it lands (see pkgs/onepassword-mcp/).
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
