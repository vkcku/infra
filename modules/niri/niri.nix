{
  flake.modules.nixos.niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      niriConf =
        let
          baseConf = pkgs.writeText "niri-base-conf" (
            lib.strings.replaceString "{{external_monitor}}" config.infra.desktop.externalMonitor (
              builtins.readFile ./config.kdl
            )
          );

          finalConf = pkgs.writeText "niri-final-conf" ''
            include "${baseConf}"
          '';
        in
        pkgs.runCommandLocal "niri-config"
          {
            nativeBuildInputs = [ pkgs.niri ];
          }
          ''
            ln --symbolic "${finalConf}" "$out"
            niri validate --config "$out"
          '';
    in
    {
      options.infra.desktop = {
        externalMonitor = lib.mkOption {
          type = lib.types.str;
          description = "The name of the external monitor.";
        };
      };

      config = {
        environment.systemPackages = [
          config.programs.niri.package
          pkgs.xwayland-satellite
        ];

        environment.sessionVariables = {
          NIRI_CONFIG = "${niriConf}";
          NIXOS_OZONE_WL = "1";
        };

        programs.niri.enable = true;

        security.polkit.enable = true;

        systemd.user.services.niri.enableDefaultPath = false;

        xdg.portal = {
          enable = true;

          config.niri = {
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          };
        };
      };
    };
}
