{ config, lib, pkgs, ... }:

let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in

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

    supportedFilesystems = [ "zfs" ];
    initrd.supportedFilesystems = ["zfs"]; # boot from zfs
    # Note this might jump back and forth as kernels are added or removed.
    kernelPackages = latestKernelPackage;
  };

  networking.hostId = "23c95f57";

  services = {
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.
    udev.extraRules = /*udev*/''
      ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    '';
  };
}
