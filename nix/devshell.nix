{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      treefmt = inputs.treefmt-nix-config.lib.mkTreefmt pkgs { };
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        name = "infra";

        packages = [
          # keep-sorted start
          pkgs.nixd
          treefmt
          # keep-sorted end
        ];
      };
    };
}
