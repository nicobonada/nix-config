{
  writeShellApplication,
  python3,
  # Path to scripts/1password-mcp-adapter.py (passed from pkgs/default.nix)
  adapter,
}:
# Thin bridge around the setgid MCP binary:
#   - Always spawn /run/wrappers/bin/1password-mcp (peer GID checks).
#   - Auto-detect host framing (NDJSON vs legacy Content-Length).
writeShellApplication {
  name = "1password-mcp-grok";
  runtimeInputs = [ python3 ];
  text = ''
    export ONEPASSWORD_MCP_RAW=/run/wrappers/bin/1password-mcp
    export PYTHONUNBUFFERED=1
    exec python3 -u ${adapter}
  '';
}
