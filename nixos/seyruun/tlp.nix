{
  # amd-pstate-epp (active) picks the frequency itself. The powersave governor
  # is what unlocks the EPP steps; the performance governor locks EPP to
  # performance. tlp-pd speaks the power-profiles API Noctalia and
  # GameMode use.
  # AC -> balance_performance, battery -> balance_power, power-saver -> power.
  services.tlp = {
    enable = true;
    pd.enable = true;

    settings = {
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      CPU_DRIVER_OPMODE_ON_SAV = "active";

      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_GOVERNOR_ON_SAV = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_SAV = "power";

      # 1 allows boost. The CPU decides when to use it.
      # power-saver disallows it.
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;
      CPU_BOOST_ON_SAV = 0;

      # usbhid and audio are already excluded, which covers the YubiKey, RK87,
      # Logitech receiver, HyperX dongle, and Raiju. Bluetooth is not.
      USB_EXCLUDE_BTUSB = 1;
      # Elan 04f3:0c82 binds no usbhid interface, so the default
      # exclusion misses it.
      USB_DENYLIST = [ "04f3:0c82" ];
    };
  };
}
