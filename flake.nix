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

        # Defining all relevant packages

        # Non nix-packaged modules grom GitHub
        ontospy = pkgs.python3Packages.buildPythonPackage rec {
          pname = "ontospy";
          version = "2.1.1";
          pyproject = true;
          src = pkgs.fetchFromGitHub {
            owner = "lambdamusic";
            repo = "Ontospy";
            rev = "v${version}";
            hash = "sha256-GUsoKAZYlyEcl1iZZJEE1qABbyDaylbCS193FyKUnFw=";
          };
          propagatedBuildInputs = [ pkgs.python3Packages.setuptools
                                  pkgs.cmake];
        };

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

        # Build packages
        buildPythonPackages = (
          python.withPackages (
            ps: with ps; [
              setuptools
            ]
          )
        );

        # Python modules for actual package
        modulePythonPackages = (
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

        # The main module
        myapp = pkgs.python3Packages.buildPythonPackage {
          # Change name here
          pname = "template_python_package";
          pyproject = true;
          version = "0.1.0";
          src = ./.;
          build-system = [
            buildPythonPackages
            modulePythonPackages
          ];
        };

      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bashInteractive
            devPackages
            devPythonPackages
            modulePythonPackages
            ontospy
            myapp
          ];
        };
      }
    );
}
