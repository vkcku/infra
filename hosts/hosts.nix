{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.nixosConfigurations =
    let
      hosts = builtins.attrNames (
        lib.attrsets.filterAttrs (_: type: type == "directory") (builtins.readDir ./.)
      );

      mkNixosConfiguration = host: {
        name = host;
        value = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            # keep-sorted start
            config.flake.modules.nixos."${host}"
            # keep-sorted end
          ];
        };
      };
    in
    builtins.listToAttrs (map mkNixosConfiguration hosts);
}
