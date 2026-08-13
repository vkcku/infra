{
  flake.modules.nixos.core = { lib, ... }: {
    options.infra.core.facts = {
      memory = lib.mkOption {
        type = lib.types.int;
        description = "The RAM available to the machine in bytes.";
      };
    };
  };
}
