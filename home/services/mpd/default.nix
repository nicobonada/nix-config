{ pkgs, ... }:
{
  services = {
    mpd = {
      enable = true;
      network.listenAddress = "any";
      extraConfig = builtins.readFile ./mpd.conf;
    };

    mpd-mpris = {
      enable = true;
      mpd.useLocal = true;
    };
  };

  programs.ncmpcpp = {
    enable = true;
    settings = {
      progressbar_look = "->-";
      user_interface = "alternative";
      space_add_mode = "always_add";
      external_editor = "nvim";
      browser_display_mode = "columns";
    };
  };

  home.packages = [ pkgs.mpc_cli ];
}
