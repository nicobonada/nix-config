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
  # Human desktop + CLI (Umbriel/Noctalia): setgid op, BrowserSupport, polkit owners.
  # Session polkit agent: Noctalia shell.polkit_agent (not polkit-gnome).
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "nico" ];
  };

  # Helium is not on 1Password's built-in Linux allowlist. BrowserSupport
  # matches the process basename (opt/helium/helium), not the profile
  # wrappers (helium-work / helium-personal / helium-scratch). Mode 0755
  # is required. Restart 1Password after this file lands.
  # https://support.1password.com/additional-browsers/
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      helium
    '';
    mode = "0755";
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
