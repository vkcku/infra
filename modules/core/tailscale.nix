{
  flake.modules.nixos.core =
    { config, lib, ... }:
    let
      cfg = config.infra;
    in
    {
      sops.secrets."tailscale_auth_key" = { };

      services.tailscale = {
        enable = true;

        authKeyFile =
          if cfg.profile == "server" then config.sops.secrets."tailscale_auth_key".path else null;
        extraUpFlags = lib.lists.optional cfg.ssh "--ssh";
        extraDaemonFlags = [ "--no-logs-no-support" ];
      };
    };
}
