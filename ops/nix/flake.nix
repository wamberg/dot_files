{
  description = "NixOS and nix-darwin configuration for wamberg's machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Pinned stable nixpkgs for packages broken on unstable.
    # TODO: Remove once calibre builds on unstable again.
    # Tracking: https://github.com/NixOS/nixpkgs/issues/493843
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop.url = "github:aaddrick/claude-desktop-debian";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, nix-darwin, claude-desktop, ... }:
    let
      forgeSystem = "x86_64-linux";
      pkgs-stable = import nixpkgs-stable {
        system = forgeSystem;
        config.allowUnfree = true;
      };
      claude-desktop-fhs = claude-desktop.packages.${forgeSystem}.claude-desktop-fhs;
    in
    {
    nixosConfigurations = {
      forge = nixpkgs.lib.nixosSystem {
        system = forgeSystem;
        specialArgs = { inherit pkgs-stable claude-desktop-fhs; };
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
