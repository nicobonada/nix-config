{ inputs, ... }:
{
  imports = [ inputs.ucodenix.nixosModules.default ];

  # firmware for amd cpus
  services.ucodenix.enable = true;
  boot.kernelParams = [ "microcode.amd_sha_check=off" ];
}
