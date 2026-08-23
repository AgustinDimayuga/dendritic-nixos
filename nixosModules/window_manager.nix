{ config, lib, pkgs, ...}:
{

  options = {
    touchpad.enable = 
      lib.mkEnableOption "enable touchpad";
  };


  config = lib.mkMerge [
  (lib.mkIf config.touchpad.enable {
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };
  }) 
  {
  # Enable hyprland
   programs.hyprland = {
     enable = true;
     xwayland.enable = true;
   };
  }

  {

    # Auto-login on tty1 and start Hyprland
    services.getty.autologinUser = "agustin";

    environment.loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec start-hyprland
      fi
    '';
  }

  {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };


}



  ];

}
