{ inputs, ... }:
{
  imports = [ inputs.ucodenix.nixosModules.default ];

  # microcode for amd cpus
  hardware.cpu.amd.updateMicrocode = true;
  services.ucodenix.enable = true;
  boot.kernelParams = [ "microcode.amd_sha_check=off" ];
}
