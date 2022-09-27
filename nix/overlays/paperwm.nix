# Thank you, terlar
# https://github.com/terlar/nix-config/blob/9c4f5cc59dabb83249dfd0e984a889bc4287ef1f/overlays/gnome-extensions/default.nix
final: prev: {
  gnome42Extensions =
    prev.gnome42Extensions
    // (with final.gnome; {
      paperwm = prev.gnomeExtensions.paperwm.overrideDerivation (old: let
        version = "42.0";
      in {
        inherit version;
        name = "${old.pname}-${version}";
        src = prev.fetchFromGitHub {
          owner = "paperwm";
          repo = "paperwm";
          rev = "3b7a4b6c07512d3ba5e1967cda0fbe63c6bb0ae1";
          hash = "sha256-HuqSp6NM9Ye9SyQT+il5Cn4FsSxnT6CAlA/NjwBkajo=";
        };
      });
    });
}
