{
  flake.modules.nixos.nushell = { config, pkgs, ... }: {
    infra.dotfiles = {
      "nushell/config.nu" = ./config.nu;
    };

    users.users."${config.infra.core.username}" = {
      shell = pkgs.nushell;
    };

    assertions = [
      {
        assertion = config.infra.core.profile == "daily-use";
        message = "nushell module can only be enabled for daily-use machines";
      }
    ];
  };
}
