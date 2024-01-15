{
  description = "SML/NJ Kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
    flake-utils.lib.eachDefaultSystem
        (system:
        let
            pkgs = import nixpkgs { inherit system; };
        in
        rec {
            default = with pkgs; stdenv.mkDerivation {
                name = "smlnj_kernel";
                src = ./.;

                patchPhase = ''
                    substituteInPlace $src/share/jupyter/kernels/smlnj/kernel.json --replace kernel.py $out/share/jupyter/kernels/smlnj/kernel.py
                '';

                installPhase = ''
                    mkdir -p $out/share
                    cp -r $src/share/* $out/share/
                '';

                preFixup = ''
                    mkdir -p $out/nix-support
                    cat <<EOF > $out/nix-support/setup-hook
                    export JUPYTER_PATH=$out/share/jupyter/:$JUPYTER_PATH
                    EOF
                '';


            };

            devShell = pkgs.mkShell {
                buildInputs = [
                    default
                    pkgs.smlnj
                    pkgs.python311Packages.ipykernel
                ];
            };
        }
      );

}
