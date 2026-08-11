{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      treefmt = pkgs.callPackage ./_pkgs/treefmt.nix {
        inherit (inputs) treefmt-nix-config;
      };
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        name = "infra";

        packages = [
          # keep-sorted start
          pkgs.nixd
          pkgs.sops
          treefmt
          # keep-sorted end
        ];
      };
    };
}
