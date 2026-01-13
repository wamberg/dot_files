{
  description = "NixOS and nix-darwin configuration for wamberg's machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }: {
    nixosConfigurations = {
      forge = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/forge/configuration.nix
          ./common/nixos.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };

    darwinConfigurations = {
      mac = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/mac/configuration.nix
          ./common/darwin.nix
          home-manager.darwinModules.home-manager
        ];
      };
    };
  };
}
