{
  flake.modules.nixos.core = { lib, ... }: {
    options.infra.core = {
      profile = lib.mkOption {
        type = lib.types.enum [
          "server"
          "daily-use"
        ];
        description = "The kind of machine this is. This is used to determine sensible defaults for various services/applications.";
      };
    };
  };
}
