{ inputs, ... }: {
  flake.modules.nixos.core = {
    imports = [ inputs.disko.nixosModules.default ];
  };
}
