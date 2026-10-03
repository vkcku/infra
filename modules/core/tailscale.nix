{
  flake.modules.nixos.core =
    { config, lib, ... }:
    let
      cfg = config.infra.core;
      isServer = cfg.profile == "server";
      authKeyName = "external/tailscale/auth_key";
    in
    {
      sops.secrets.${authKeyName} = { };

      services.tailscale = {
        enable = true;

        authKeyFile = if isServer then config.sops.secrets.${authKeyName}.path else null;
        extraUpFlags = lib.lists.optional isServer "--ssh";
        extraDaemonFlags = [ "--no-logs-no-support" ];
      };
    };
}
