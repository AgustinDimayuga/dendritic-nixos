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
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;
    }

    (lib.mkIf config.kernel-latest.enable {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    })
  ];
}
