{
  lib,
  libnotify,
  makeBinaryWrapper,
  runCommand,
  solaar,
}:
# nixpkgs collects GI typelibs from solaar's build closure. libnotify is
# not in it, so gi.require_version("Notify", "0.7") fails at startup.
# Wrap the cached binary. overrideAttrs would rebuild the Python package
# on every nixpkgs bump.
runCommand "solaar-${solaar.version}"
  {
    nativeBuildInputs = [ makeBinaryWrapper ];
    meta = solaar.meta // {
      mainProgram = "solaar";
    };
  }
  ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe solaar} $out/bin/solaar \
      --prefix GI_TYPELIB_PATH : ${libnotify}/lib/girepository-1.0
    ln -s solaar $out/bin/solaar-cli
    ln -s ${solaar}/share $out/share
  ''
