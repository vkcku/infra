{
  flake.modules.nixos.core =
    { config, lib, ... }:
    let
      cfg = config.infra.core;
      isServer = cfg.profile == "server";
    in
    {
      sops.secrets."tailscale_auth_key" = { };

      services.tailscale = {
        enable = true;

        authKeyFile =
          if isServer then config.sops.secrets."tailscale_auth_key".path else null;
        extraUpFlags = lib.lists.optional isServer "--ssh";
        extraDaemonFlags = [ "--no-logs-no-support" ];
      };
    };
}
