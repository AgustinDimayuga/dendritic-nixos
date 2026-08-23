{ config, lib, pkgs, ...}:

{

 programs.nm-applet.enable = true; # Adds the applet system-wide
 networking.networkmanager.enable = true;


  networking.firewall.extraCommands = ''
    iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
  '';
  services.openssh.enable = true;


}
