{ config, lib, ... }:
{

  imports = [
    ./kitty.nix
    ./yazi.nix
    ./obs.nix
    ./zathura.nix
    ./git.nix
    ./tmux.nix
    ./vscode.nix
    ./discord.nix
    ./spotify.nix
    ./browserapplications.nix
    ./chromium.nix
    ./hyprfm.nix
    ./zsh.nix
    ./utility.nix
  ];

}
