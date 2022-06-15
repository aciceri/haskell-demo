{
  description = "Toy project made up only to test haskell.nix";

  #inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.haskellNix.url = "github:mlabs-haskell/haskell.nix/aciceri/ca";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix, ... }@inputs:
    with flake-utils.lib; eachSystem (with system; [ x86_64-linux ])
      (system:
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
                  enable = false;
                };
              };
          };
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              haskellNix.overlay
              overlay
            ];
            config.contentAddressedByDefault = true;
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
            build = pkgs.hello;
            #build = flake.packages."hello:exe:executable";
          };
        });
}
