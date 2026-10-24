{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.agustin = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "i2c"
    ];
    packages = with pkgs; [
      tree
    ];
  };

}
