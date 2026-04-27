{ pkgs, ... }:
{
  home.packages = with pkgs; [
    aria2
    bandwhich
    dig
    ipcalc
    nmap
    snitch
    wavemon
    whosthere
    whois
    wifitui
  ];
}
