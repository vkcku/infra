{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      treefmt = pkgs.callPackage ./_pkgs/treefmt.nix {
        inherit (inputs) treefmt-nix-config;

        betterleaks = pkgs.callPackage ../_pkgs/betterleaks.nix { };
      };
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        name = "infra";

        packages = [
          # keep-sorted start
          pkgs.nix-fast-build
          pkgs.nixd
          pkgs.sops
          treefmt
          # keep-sorted end
        ];

        shellHook = ''
          rootdir="$(git rev-parse --show-toplevel)"
          git config core.hooksPath "$rootdir/hooks"
        '';
      };
    };
}
