{
  flake.modules.nixos.desktop =
    { config, ... }:
    let
      user = config.infra.core.username;
      nixconfdir = "${config.users.users."${user}".home}/.config/nix";
    in
    {
      sops = {
        secrets."external/github/nix_pat" = {
          restartUnits = [ config.systemd.user.services."infra-nix-conf".name ];
        };

        templates."nix.conf" = {
          owner = user;
          content = ''
            access-tokens = github.com=${config.sops.placeholder."external/github/nix_pat"}
          '';
        };
      };

      # Cannot use dotfiles setup with hjem since the file is
      # dynamically created by sops at startup.
      systemd.user.services."infra-nix-conf" = {
        description = "setup nix.conf in $XDG_CONFIG_HOME";

        serviceConfig = {
          Type = "oneshot";
          User = user;
          Group = config.users.users."${user}".group;
        };

        enableStrictShellChecks = true;
        script = ''
          rm -rf "${nixconfdir}"
          mkdir --parents "${nixconfdir}"
          ln --symbolic "${config.sops.templates."nix.conf".path}" "${nixconfdir}/nix.conf"
        '';
      };
    };
}
