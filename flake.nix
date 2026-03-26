# flake.nix
{
   inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
      flake-utils.url = "github:numtide/flake-utils";
   };
   outputs = { self, nixpkgs, flake-utils }:
   flake-utils.lib.eachDefaultSystem (system:
      let
         overlays = [];
         pkgs = import nixpkgs {
            inherit system overlays;
         };
         kathara = pkgs.stdenv.mkDerivation{
            name = "kathara-source";
            src = pkgs.fetchurl {
               url = "https://github.com/KatharaFramework/Kathara/releases/download/3.8.1/kathara_3.8.1-1noble_amd64.deb";
               hash = "sha256-0KeDzFpSpn5iiaN9ZZXkNMQNYrNT/rpTPt0qWkGEUBM=";
            };

            dpkg = pkgs.dpkg;

            buildInputs = with pkgs; [ 
               dpkg 
               autoPatchelfHook 
               libz 
               expat
               bzip2
            ];
            unpackPhase = ''
               dpkg -x $src unpacked
               cp -r unpacked/* $out/
            '';
         };
      in
      rec {
         packages.default = pkgs.buildFHSEnv {
            name = "kathara";
            targetPkgs = pkgs: [ kathara ];
            multiPkgs = pkgs: [ pkgs.dpkg ];
            runScript = "kathara";
         };

         devShells.default = pkgs.mkShell {
            name = "Kathara";
            buildInputs = [ packages.default ];
         };
      }) // {
      overlays = {
         default = final: prev: {
            kathara = self.packages.${prev.system}.default;
         };
      };
   };
}
