{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      less-patched =
        let
          version = "692";
        in
        prev.less.overrideAttrs {
          src = prev.fetchzip {
            url = "https://www.greenwoodsoftware.com/less/less-${version}.tar.gz";
            hash = "sha256-Imc5m0jh85vfsNhA9iqvfBb2MSQul7PYqm1Ppe75UGA=";
          };
          inherit version;
        };
    })
  ];
  system.replaceDependencies.replacements = [
    {
      oldDependency = pkgs.less;
      newDependency = pkgs.less-patched;
    }
  ];
}
