{
  description = "Personal system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs @ { nixpkgs, home-manager, nixos-hardware, neovim-nightly-overlay, ... }:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          neovim-nightly-overlay.overlay
        ];
      };

      system = "x86_64-linux";
    in
    {
      homeManagerConfigurations = {
        wamberg = home-manager.lib.homeManagerConfiguration {
          inherit system pkgs;
          username = "wamberg";
          homeDirectory = "/home/wamberg";
          stateVersion = "21.11";
          configuration = {
            imports = [
              ./users/wamberg/home.nix
            ];
          };
        };
      };
      nixosConfigurations = {
        lofty = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./system/configuration.nix
            nixos-hardware.nixosModules.dell-xps-13-9380
          ];
        };
      };
    };
}
