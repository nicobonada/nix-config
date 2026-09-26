let
  monitors = import ../monitors.nix;
in
{
  # No backdrop or xray key. Layer blur stays off.
  window_rule = [
    # Blur what is behind the window instead of a cached backdrop.
    {
      blur = true;
      blur_optimized = false;
    }

    {
      match.app_id = "^(steam_app_[0-9]+|gamescope)$";
      # Opening placement. Proton often has no app-id on the first configure,
      # and Umbriel does not replay opening settings when the id arrives.
      default_output = monitors.lg;
    }

    {
      match.app_id = "^brave-personal$";
      match.at_startup = true;
      default_output = monitors.asus;
    }

    {
      match.app_id = "^brave-work$";
      match.at_startup = true;
      default_output = monitors.lg;
    }

    {
      match.title = "^MikuLogiS\\+$";
      default_fullscreen = false;
    }

    {
      match.app_id = "^steam$";
      match.title = "^notificationtoasts_[0-9]+_desktop$";
      default_floating = true;
      default_position = {
        x = 10;
        y = 10;
        anchor = "bottom_right";
      };
    }

    {
      match.app_id = "^dev\\.noctalia\\.Noctalia\\.Settings$";
      default_floating = true;
      default_floating_size_px = {
        width = 1080;
        height = 920;
      };
    }
  ];
}
