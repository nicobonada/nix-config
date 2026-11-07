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
    # Desktops print via the local brlaser + :9100 queue. cups-browsed
    # would ingest the homelab IPP share and the printer's own broken
    # IPP advertisement, then pause the ghost queue on backend errors.
    browsed.enable = false;
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
