{ pkgs, ... }:
{
  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        devices = [ "nodev" ];
        # font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSansMono.ttf";
        fontSize = 32;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "zswap.enabled=1"           # enables zswap
      "zswap.shrinker_enabled=1"  # whether to shrink the pool proactively on high memory pressure
    ];
    initrd.kernelModules = [ "amdgpu" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
