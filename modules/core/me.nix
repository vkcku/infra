{
  flake.modules.nixos.core = { config, lib, ... }: {
    options.infra.core = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "vkcku";
        description = "username of the default user i.e. me";
      };
    };

    config =
      let
        cfg = config.infra.core;
        passwordKey = "${cfg.username}_${config.networking.hostName}_password";
      in
      {
        sops.secrets."${passwordKey}".neededForUsers = true;

        users.users."${cfg.username}" = {
          isNormalUser = true;
          createHome = true;
          extraGroups = [ "wheel" ];
          hashedPasswordFile = config.sops.secrets."${passwordKey}".path;
        };

        nix.settings.trusted-users = [ cfg.username ];
      };
  };
}
