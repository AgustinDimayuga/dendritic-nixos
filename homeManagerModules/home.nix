{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    ./hyprland/hyprland.nix
    ./applications/applications.nix
    ./theme.nix
  ];
  hyprland-laptop.enable = true;
  nixpkgs.config.allowUnfree = true;
  theme = "gruvbox";

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "agustin";
  home.homeDirectory = "/home/agustin";
  programs.home-manager.enable = true;
  home.stateVersion = "26.05"; # Please read the comment before changing.

}
