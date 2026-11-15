{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    kernel-latest.enable = lib.mkEnableOption "use the latest kernel instead of the stable kernel";
  };

  config = lib.mkMerge [
    # default (red values)
    {
      boot.loader.systemd-boot.enable = false;
      boot.loader.efi.efiSysMountPoint = lib.mkDefault "/boot";
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = lib.mkDefault true;
        device = "nodev";
        gfxmodeEfi = "800x600";
      };
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;
    }

    # when kernel-latest is on (green values)
    (lib.mkIf config.kernel-latest.enable {
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.loader.efi.efiSysMountPoint = "/boot/efi";
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.grub.efiInstallAsRemovable = false;
      boot.loader.grub.useOSProber = true;
    })
  ];
}
