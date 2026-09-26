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
        # 512M ESP; linux_latest kernels do not share. Unlimited gens filled /boot.
        configurationLimit = 8;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "zswap.enabled=1" # enables zswap
      "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
      # HP's EC locks this Ryzen near 400 MHz if s2idle starts too quickly.
      # Kernel bug 218557. The delay is 2.5s, after the screen is already off.
      "amd_pmc.delay_suspend=1"
    ];
    initrd.kernelModules = [ "amdgpu" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
