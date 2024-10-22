{
  description = "Template Python Package and development environment for Upal Bhattacharya relying on direnv (using nix flakes) and setuptools (NOT Poetry or poetry2nix)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python312;

        # The main module
        myapp = pkgs.python3Packages.buildPythonPackage rec {
          # Change name here
          pname = "template_python_package";
          pyproject = true;
          version = "0.1.0";
          src = ./.;
          build-system = [
            (python.withPackages (
              ps: with ps; [
                # build system
                setuptools
              ]
            ))
          ];
        };

        # Python development packages used for development
        # LSP, formatting, etc.
        devPythonPackages = (
          python.withPackages (
            ps: with ps; [
              python-lsp-server
              isort
              black
              flake8
            ]
          )
        );

        # Python modules for actual package
        packagePythonPackages = (
          python.withPackages (
            ps:
            with ps;
            [
            ]
          )
        );

        # Other development packages available in the nixpkgs
        devPackages = (
          with pkgs;
          [
            nixd
            nixfmt-rfc-style
          ]
        );
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bashInteractive
            devPackages
            devPythonPackages
            packagePythonPackages
            myapp
          ];
        };
      }
    );
}
