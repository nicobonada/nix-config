{ pkgs, ... }:
{
  services.xidlehook = {
    enable = true;
    not-when-audio = true;
    not-when-fullscreen = true;
    timers = [
      {
        delay = 480;
        command = "${pkgs.libnotify}/bin/notify-send -t 60000 'Idle' 'Locking in 1 minute\nSleeping in 2 minutes'";
      }
      {
        delay = 540;
        command = "i3lock";
      }
      {
        delay = 600;
        command = "systemctl suspend";
      }
    ];
  };
}
