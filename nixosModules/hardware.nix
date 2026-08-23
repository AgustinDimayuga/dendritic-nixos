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

    })

  ];

}
