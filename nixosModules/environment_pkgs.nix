{ config, lib, pkgs, ...}:

{

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    gcc
    libnotify
    git
    wget
    neovim
    kitty
    home-manager
    tmux
    btop

  ];


}
