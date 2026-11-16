{ inputs, ... }:
{
  imports = [ inputs.luciole.homeModules.default ];

  programs.luciole.enable = true;

  xdg.mimeApps.defaultApplications."inode/directory" = "dev.noctalia.luciole.desktop";
}
