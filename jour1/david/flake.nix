{
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      with nixpkgs.legacyPackages.${system}; {
        packages.default = stdenv.mkDerivation {
          pname = "david";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ zig.hook ];
        };

        apps = {
          "01" = flake-utils.lib.mkApp { drv = self.packages.${system}.default; name = "david01"; };
          "02" = flake-utils.lib.mkApp { drv = self.packages.${system}.default; name = "david02"; };
        };
      });
}
