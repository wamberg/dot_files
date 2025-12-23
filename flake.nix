{
  description = "Development environment for dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      format = pkgs.writeShellScriptBin "format" ''
        echo "Formatting Lua files..."
        find ./ -name '*.lua' -print0 | xargs -0 ${pkgs.stylua}/bin/stylua

        echo "Formatting YAML files..."
        find ops/arch -name '*.yml' -print0 | xargs -0 ${pkgs.yamlfmt}/bin/yamlfmt

        echo "Done!"
      '';

      lint = pkgs.writeShellScriptBin "lint" ''
        echo "Linting shell scripts..."
        find ./ -name 'tmux' -prune -o -name '*.sh' -print0 | xargs -0 ${pkgs.shellcheck}/bin/shellcheck

        echo "Done!"
      '';
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          yamlfmt
          shellcheck
          stylua
          format
          lint
        ];

        shellHook = ''
          echo "Development shell for dotfiles"
          echo "Available commands: format, lint"
        '';
      };
    };
}
