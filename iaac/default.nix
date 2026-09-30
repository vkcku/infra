{ inputs, ... }: {
  perSystem = { system, ... }: {
    packages.opentofu-json = inputs.terranix.lib.terranixConfiguration {
      inherit system;

      modules = [ ./main.nix ];
    };
  };
}
