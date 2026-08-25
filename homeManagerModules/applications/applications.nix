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
    ./spotify.nix
  ];

}
