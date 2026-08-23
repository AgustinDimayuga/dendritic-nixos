{ config, lib, pkgs, ...}:

{

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    neovim
    kitty
    home-manager
    tmux
  ];


}
