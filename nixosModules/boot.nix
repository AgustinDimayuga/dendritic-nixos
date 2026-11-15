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
      boot.loader.efi.efiSysMountPoint = lib.mkDefault "/boot/efi";
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = lib.mkDefault false;
        device = "nodev";
        useOSProber = lib.mkDefault true;
        gfxmodeEfi = "800x600";
      };
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;
    }

    # kernel-latest machine, the laptop: single-boot layout (red values)
    (lib.mkIf config.kernel-latest.enable {
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.loader.efi.efiSysMountPoint = lib.mkForce "/boot";
      boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
      boot.loader.grub.efiInstallAsRemovable = lib.mkForce true;
      boot.loader.grub.useOSProber = lib.mkForce false;
    })
  ];
}
