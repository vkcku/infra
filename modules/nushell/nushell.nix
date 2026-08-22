{
  flake.modules.nixos.nushell = { config, pkgs, ... }: {
    infra.dotfiles = {
      "nushell/config.nu" = ./config.nu;
    };

    users.users."${config.infra.core.username}" = {
      shell = pkgs.nushell;
    };
  };
}
