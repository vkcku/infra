{
  perSystem =
    { pkgs, ... }:
    let
      bin = pkgs.writeShellScriptBin "deploy-indra" ''
        set -euo pipefail

        "${pkgs.nixos-rebuild}/bin/nixos-rebuild" switch \
          --flake .#indra \
          --target-host deploy@indra \
          --use-substitutes \
          --no-reexec \
          --sudo
      '';
    in
    {
      apps.deploy-indra = {
        type = "app";
        program = "${bin}/bin/deploy-indra";
        meta.description = "deploy indra";
      };
    };
}
