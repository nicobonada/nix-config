{ config, ... }:
{
  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "nct6775" ];         # from lm_sensors
    kernelParams = [ "nohibernate" ];      # zfs doesn't support hibernate
    initrd.kernelModules = [ "amdgpu" ];
  };
}
