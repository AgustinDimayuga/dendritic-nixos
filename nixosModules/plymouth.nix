{ pkgs, ... }:
let
  framework-penguin-theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "framework-penguin-plymouth";
    version = "1.0";
    src = ./plymouth/framework-penguin;
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/framework-penguin
      cp -r $src/* $out/share/plymouth/themes/framework-penguin/
      substituteInPlace $out/share/plymouth/themes/framework-penguin/*.plymouth \
        --replace "/usr/share/plymouth/themes/framework-penguin" "$out/share/plymouth/themes/framework-penguin"
    '';
  };
in
{
  boot.plymouth = {
    enable = true;
    theme = "framework-penguin";
    themePackages = [ framework-penguin-theme ];
  };

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
  ];

  boot.loader.timeout = 1;

}
