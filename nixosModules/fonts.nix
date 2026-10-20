{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "MonoLisaText Trial"
        "DejaVu Sans"
      ];
      serif = [
        "MonoLisaText Trial"
        "DejaVu Serif"
      ];
      monospace = [ "MonoLisa Variable" ];
    };
  };
}
