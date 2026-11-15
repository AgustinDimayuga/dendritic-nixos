{ config, pkgs, ... }:
{
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.usbmuxd.enable = true; # actually runs the iPhone USB service

  environment.systemPackages = [
    pkgs.ntfs3g # mount.ntfs: Windows NTFS drives
    pkgs.usbmuxd # puts usbmuxd on PATH so HyprFM's check passes
  ];

}
