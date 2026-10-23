{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    laptop-hardware.enable = lib.mkEnableOption "enable laptop hardware";
  };
  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [ brightnessctl ];
    }
    (lib.mkIf config.laptop-hardware.enable {
      services.fwupd.enable = true;
      powerManagement.enable = true;
      services.auto-cpufreq.enable = true;
      hardware.enableAllFirmware = true;

      services.fprintd.enable = true;

      # Secret Service for Bitwarden biometric unlock
      services.gnome.gnome-keyring.enable = true;
      # Typing your password into hyprlock unlocks the keyring
      security.pam.services.hyprlock.enableGnomeKeyring = true;
      security.pam.services.hyprlock.fprintAuth = false;
      security.pam.services.login.enableGnomeKeyring = lib.mkForce false;

      services.libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          naturalScrolling = true;
          disableWhileTyping = true;
        };
      };
    })
  ];
}
