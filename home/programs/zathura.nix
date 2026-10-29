{
  programs.zathura.enable = true;

  # Plugin desktops are NoDisplay; the generic org.pwmt.zathura.desktop
  # has no MimeType. xdg-open needs the mupdf handler.
  xdg.mimeApps.defaultApplications."application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
}
