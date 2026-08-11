{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      treefmt = inputs.treefmt-nix-config.lib.mkTreefmt pkgs {
        programs.typos.configFile = toString (
          (pkgs.formats.toml { }).generate "typos.toml" {
            default.extend-words.facter = "facter";
          }
        );
      };
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
