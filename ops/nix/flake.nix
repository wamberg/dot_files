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

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      # Overlay to disable tests for all Python packages
      pythonTestOverlay = final: prev: {
        python3 = prev.python3.override {
          packageOverrides = python-final: python-prev:
            prev.lib.mapAttrs (name: value:
              if prev.lib.isDerivation value && value ? overrideAttrs
              then value.overrideAttrs (old: { doCheck = false; doInstallCheck = false; })
              else value
            ) python-prev;
        };
        python3Packages = final.python3.pkgs;
      };
    in
    {
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
          ({ ... }: {
            nixpkgs.overlays = [ pythonTestOverlay ];
          })
          ./hosts/mac/configuration.nix
          ./common/darwin.nix
          home-manager.darwinModules.home-manager
        ];
      };
    };
  };
}
