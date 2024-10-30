{
  description = "Test reproduciblity of genomic CNNs";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pythonEnv = pkgs.python311.withPackages (p:
        with p; [
          ipython
          python-lsp-server
          python-lsp-black
          python-lsp-ruff
        ]);
    in {
      devShells.${system}.default =
        pkgs.mkShell { packages = (with pkgs; [ gnumake pythonEnv ]); };
    };
}
