{
  flake.modules.nixos.desktop =
    { config, pkgs, ... }:
    let
      user = config.infra.core.username;
    in
    {
      systemd.user.services.garden-ssh-agent = {
        enable = true;
        wantedBy = [ "default.target" ];
        description = "SSH Agent";
        unitConfig = {
          ConditionUser = user;
        };
        serviceConfig = {
          User = user;
          Type = "exec";
          # '%t' is `$XDG_RUNTIME_DIR`.
          ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.sock -t 2h";
          Restart = "on-failure";
        };
      };
    };
}
