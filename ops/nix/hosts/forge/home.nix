{ config, pkgs, ... }:

{
  imports = [
    ../../common/home.nix
  ];

  # Host-specific packages for forge
  home.packages = with pkgs; [
    # Add forge-specific tools here as needed
  ];

  # Username and home directory
  home.username = "wamberg";
  home.homeDirectory = "/home/wamberg";
}
