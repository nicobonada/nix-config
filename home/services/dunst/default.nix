{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        follow = "keyboard";
        font = "Inter 12";
        frame_color = "#8aadf4";
        separator_color = "frame";
      };

      urgency_low = {
        background = "#363a4f";
        foreground = "#cad3f5";
      };

      urgency_normal = {
        background = "#363a4f";
        foreground = "#cad3f5";
      };

      urgency_critical = {
        background = "#363a4f";
        foreground = "#cad3f5";
        frame_color = "#ed8796";
      };
    };
  };
}
