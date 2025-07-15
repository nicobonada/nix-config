{ inputs, config, lib,  ... }:
let
  cfg = config.amd-cpu;
in {
  imports = [ inputs.ucodenix.nixosModules.default ];

  options.amd-cpu = {
    enable = lib.mkEnableOption "support for Ryzen CPUs (microcode)";
  };

  config = lib.mkIf cfg.enable {
    # microcode for amd cpus
    hardware.cpu.amd.updateMicrocode = true;
    services.ucodenix.enable = true;
    boot.kernelParams = [ "microcode.amd_sha_check=off" ];
  };
}
