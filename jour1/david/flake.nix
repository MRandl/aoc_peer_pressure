{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      with nixpkgs.legacyPackages.${system}; {
        packages.default = stdenv.mkDerivation {
          pname = "david";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ zig.hook ];
        };
      });
}
