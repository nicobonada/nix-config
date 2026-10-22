{
  pkgs,
  ...
}:
{
  # HL-1210W is host-based. IPP on this model does not accept a job.
  # brlaser renders the page; the queue sends it to raw port 9100.
  # mDNS name, not a DHCP address. Resolved via Avahi (./avahi.nix).
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
  };

  hardware.printers = {
    ensureDefaultPrinter = "HL-1210W";
    ensurePrinters = [
      {
        name = "HL-1210W";
        description = "Brother HL-1210W";
        deviceUri = "socket://BRN0468749CBD60.local:9100";
        model = "drv:///brlaser.drv/br1210.ppd";
        ppdOptions.PageSize = "A4";
      }
    ];
  };
}
