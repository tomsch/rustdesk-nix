{
  description = "RustDesk - open-source remote desktop client";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system} = {
        default = pkgs.callPackage ./package.nix {};
        rustdesk = self.packages.${system}.default;
      };

      overlays.default = final: prev: {
        rustdesk = final.callPackage ./package.nix {};
      };
    };
}
