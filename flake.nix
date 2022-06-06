{
  description = "Toy project made up only to test haskell.nix";

  inputs.haskellNix.url = "/home/ccr/mlabs/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlay = self: _: {
          hsPkgs =
            self.haskell-nix.project' {
              src = ./.;
              compiler-nix-name = "ghc8107";
              shell.tools = {
                cabal = { };
                # hlint = {};
                # haskell-language-server = {};
              };
              contentAddressed = {
                enable = true;
              };
            };
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            haskellNix.overlay
            overlay
          ];
        };
        flake = pkgs.hsPkgs.flake { };
      in
      flake // {
        packages = {
          default = flake.packages."hello:exe:executable";
        };
        apps = {
          default = flake-utils.lib.mkApp {
            drv = flake.packages."hello:exe:executable";
            exePath = "/bin/executable";
          };
        };
        hydraJobs = {
          build = flake.packages."hello:exe:executable";
        };
      }
    );
}
