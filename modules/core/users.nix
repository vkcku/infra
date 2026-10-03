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
        passwordKey = "hosts/${config.networking.hostName}/${cfg.username}_password";
        rootPasswordKey = "hosts/${config.networking.hostName}/root_password";
      in
      {
        sops.secrets."${passwordKey}".neededForUsers = true;
        sops.secrets."${rootPasswordKey}".neededForUsers = true;

        users.users."${cfg.username}" = {
          isNormalUser = true;
          createHome = true;
          extraGroups = [ "wheel" ];
          hashedPasswordFile = config.sops.secrets."${passwordKey}".path;
        };

        users.users.root = {
          hashedPasswordFile = config.sops.secrets."${rootPasswordKey}".path;
        };

        users.mutableUsers = false;

        nix.settings.trusted-users = [ cfg.username ];
      };
  };
}
