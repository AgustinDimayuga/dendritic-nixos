{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
    gfxmodeEfi = "800x600";
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

}
