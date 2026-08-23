{ config, lib , pkgs, ...}:

{
  users.users.agustin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };



}
