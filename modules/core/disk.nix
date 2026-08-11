{ inputs, ... }: {
  flake.modules.nixos.core =
    { config, lib, ... }:
    let
      cfg = config.infra.core;
    in
    {
      imports = [ inputs.disko.nixosModules.default ];

      options.infra.core = {
        disk = lib.mkOption {
          description = "name of the main disk";
          type = lib.types.str;
        };
      };

      config = {
        disko.devices.disk.main = {
          type = "disk";
          device = cfg.disk;
          content = {
            type = "gpt";

            # Partitions are to be defined by the hosts themselves.
          };
        };
      };
    };
}
