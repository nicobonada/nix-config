{ config, lib,  ... }:
let
  cfg = config.amd-gpu;
in {
  options.amd-gpu = {
    enable = lib.mkEnableOption "support for AMD GPUs (overclocking and undervolting)";
  };

  config = lib.mkIf cfg.enable {
    services.lact.enable = true;

    hardware.amdgpu.overdrive.enable = true;
  };
}
