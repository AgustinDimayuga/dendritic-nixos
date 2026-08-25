{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixos-hardware.url = "github:NixOs/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    yazi-flavors.url = "github:yazi-rs/flavors";
    yazi-flavors.flake = false;
    yazi-gruvbox-flavor.url = "github:bennyyip/gruvbox-dark.yazi";
    yazi-gruvbox-flavor.flake = false;
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      yazi-flavors,
      yazi-gruvbox-flavor,
      nix-vscode-extensions,
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nix-vscode-extensions.overlays.default ];
      };
    in
    {
      nixosConfigurations.framework-pro = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-hardware.nixosModules.framework-intel-core-ultra-series3
          ./hosts/framework-pro/configuration.nix
          ./hosts/framework-pro/hardware-configuration.nix
        ];

      };
      homeConfigurations.agustin = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };

        modules = [ ./homeManagerModules/home.nix ];

      };
    };
}
