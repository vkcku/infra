{ inputs, ... }: {
  perSystem =
    { lib, system, ... }:
    let
      postgresOverlay =
        final: prev:
        let
          resolvedPg = final.postgresql_18_jit;
          pg = prev.postgresql;
        in
        {
          postgresql =
            if lib.strings.getVersion resolvedPg == lib.strings.getVersion pg then
              throw "postgres overlay is not needed anymore; postgresql is version 18"
            else
              final.postgresql_18_jit;
        };
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;

        overlays = [ postgresOverlay ];
      };
    };
}
