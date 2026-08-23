# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./../../nixosModules/boot.nix
    ./../../nixosModules/network.nix
    ./../../nixosModules/window_manager.nix
    ./../../nixosModules/audio.nix
    ./../../nixosModules/users.nix
    ./../../nixosModules/environment_pkgs.nix
    ./../../nixosModules/env_shell.nix
    ./../../nixosModules/hardware.nix
    ./../../nixosModules/neovim-pkgs.nix
    ./hardware-configuration.nix
    ./../../nixosModules/fonts.nix
  ];

  touchpad.enable = true;
  laptop-hardware.enable = true;

  networking.hostName = "framework-pro"; # Define your hostname.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  programs.firefox.enable = true;
  system.stateVersion = "26.05"; # Did you read the comment?

}
