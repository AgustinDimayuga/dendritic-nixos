{
  config,
  lib,
  pkgs,
  ...
}:

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
    util-linux
    # change this to an application file soon
    bitwarden-desktop
    seahorse
    dbeaver-bin

  ];

}
