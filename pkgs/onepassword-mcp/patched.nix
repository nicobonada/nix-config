{
  runCommand,
  patchelf,
  # 1Password GUI package that ships share/1password/1password-mcp
  gui,
}:
# Local stand-in for NixOS/nixpkgs#537630 until it lands:
# nixpkgs still does not patchelf 1password-mcp (only main app + BrowserSupport
# + op-ssh-sign). Thin derivation supplies a store path the security wrapper
# can setgid.
runCommand "1password-mcp-patched" {
  nativeBuildInputs = [ patchelf ];
} ''
  mkdir -p $out/share/1password
  cp ${gui}/share/1password/1password-mcp $out/share/1password/1password-mcp
  chmod +w $out/share/1password/1password-mcp
  interp=$(patchelf --print-interpreter ${gui}/share/1password/1password)
  rpath=$(patchelf --print-rpath ${gui}/share/1password/1password)
  patchelf --set-interpreter "$interp" --set-rpath "$rpath" \
    $out/share/1password/1password-mcp
''
