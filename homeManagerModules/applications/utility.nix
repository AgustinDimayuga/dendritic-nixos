{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mpv
    swayimg
  ];
}
