{ inputs, self, ... }: {
  perSystem =
    {
      lib,
      pkgs,
      system,
      ...
    }:
    let
      treefmt = pkgs.callPackage ./_pkgs/treefmt.nix {
        inherit (inputs) treefmt-nix-config;
      };

      nixosChecks =
        let
          isCurrentSystem = _: conf: conf.pkgs.stdenv.hostPlatform.system == system;
          nixos = lib.attrsets.filterAttrs isCurrentSystem self.nixosConfigurations;
        in
        builtins.mapAttrs (_: v: v.config.system.build.toplevel) nixos;
    in
    {
      checks = {
        lint = pkgs.writeShellScriptBin "lint" ''
          set -euo pipefail

          "${treefmt}/bin/treefmt" --ci
          touch "$out"
        '';
      }
      // nixosChecks;
    };
}
