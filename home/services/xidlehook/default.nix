{ pkgs, ... }:
{
  services.xidlehook = {
    enable = true;
    not-when-audio = true;
    not-when-fullscreen = true;
    timers = [
      {
        delay = 540;
        command = "${pkgs.libnotify}/bin/notify-send -t 60000 'Idle' 'Sleeping in 1 minute'";
      }
      {
        delay = 600;
        command = "systemctl suspend";
      }
    ];
  };
}
