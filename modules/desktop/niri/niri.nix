{ inputs, ... }:
{
  flake.modules.nixos.desktop =
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
            include "${./noctalia.kdl}"
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

      noctalia = inputs.noctalia.packages."${pkgs.stdenv.hostPlatform.system}".default;
      noctaliaConf =
        let
          conf = pkgs.writers.writeTOML "noctalia.toml" {
            # keep-sorted start block=yes newline_separated=yes
            bar = {
              main = {
                layer = "overlay";
                auto_hide = true;
                reserve_space = false;
                thickness = 40;
                font_weight = "bold";
                font_family = "DejaVu Sans Mono";
              };
            };

            battery.warning_threshold = 20;

            idle = {
              pre_action_fade_seconds = 2.0;

              behavior.lock = {
                timeout = 300;
                action = "lock";
                enabled = true;
              };

              behavior.screen-off = {
                timeout = 360;
                action = "screen_off";
                enabled = true;
              };

              behavior.suspend = {
                timeout = 600;
                action = "lock_and_suspend";
                enabled = true;
              };
            };

            notification.filter.spotify = {
              match = "spotify";
              show_toast = false;
              save_history = false;
            };

            theme = {
              source = "wallpaper";
            };

            wallpaper = {
              enabled = true;
            };
            # keep-sorted end
          };
        in
        pkgs.runCommand ""
          {
            nativeBuildInputs = [ noctalia ];
          }
          ''
            set -e
            noctalia config validate "${conf}"
            ln --symbolic "${conf}" "$out"
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
          # keep-sorted start
          config.programs.niri.package
          noctalia
          pkgs.xwayland-satellite
          # keep-sorted end
        ];

        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";
        };

        programs.niri.enable = true;

        security.polkit.enable = true;

        systemd.user.services.niri.enableDefaultPath = false;

        infra.dotfiles = {
          "noctalia/config.toml" = noctaliaConf;
          "niri/config.kdl" = niriConf;
        };
      };
    };
}
