# Official Yaak CLI (@yaakapp/cli). Separate from the GUI package: that
# only uses the npm binary as a build tool and does not install it.
# Talks to the same data dir as the app (~/.local/share/app.yaak.desktop);
# does not speak MCP. Drop if/when nixpkgs ships a current yaak-cli.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  openssl,
  dbus,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yaak-cli";
  version = "2026.6.1";

  src = fetchurl (
    {
      x86_64-linux = {
        url = "https://registry.npmjs.org/@yaakapp/cli-linux-x64/-/cli-linux-x64-${finalAttrs.version}.tgz";
        hash = "sha256-jCl7npH3eTmOW4/8LPCoVOC3/kOVLTr9kpfXTySfUQ0=";
      };
      aarch64-linux = {
        url = "https://registry.npmjs.org/@yaakapp/cli-linux-arm64/-/cli-linux-arm64-${finalAttrs.version}.tgz";
        hash = "sha256-ZMfHW+IjHvAIwQeSanuDbjIzxJwHqNSefgy5eS0u/TY=";
      };
    }
    .${stdenv.hostPlatform.system}
      or (throw "yaak-cli: unsupported system ${stdenv.hostPlatform.system}")
  );

  sourceRoot = "package";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    openssl
    dbus
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/yaak $out/bin/yaak
    runHook postInstall
  '';

  meta = {
    description = "CLI for the Yaak API client (workspaces, requests, send)";
    homepage = "https://yaak.app/docs/getting-started/cli-usage";
    changelog = "https://github.com/mountain-loop/yaak/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "yaak";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
