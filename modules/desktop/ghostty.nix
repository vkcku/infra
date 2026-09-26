{
  flake.modules.nixos.desktop =
    { lib, pkgs, ... }:
    let
      conf =
        let
          # Nix converts booleans to `1` and `0` :/
          boolString = b: if b then "true" else "false";
          toString' = value: if builtins.isBool value then boolString value else toString value;
        in
        pkgs.writeText "ghostty-config" (
          lib.strings.concatMapAttrsStringSep "\n" (key: value: "${key} = ${toString' value}") {
            # keep-sorted start
            app-notifications = true;
            auto-update = "off";
            background = "1e1e1e";
            background-opacity = 0.9;
            clipboard-trim-trailing-spaces = true;
            cursor-opacity = 0.8;
            gtk-single-instance = true;
            gtk-tabs-location = "hidden";
            gtk-titlebar = false;
            link-previews = true;
            linux-cgroup = "single-instance";
            notify-on-command-finish = "unfocused";
            notify-on-command-finish-action = "no-bell,notify";
            right-click-action = "copy-or-paste";
            scrollback-limit = 1024 * 1024 * 100; # 100 MiB
            selection-clear-on-copy = true;
            shell-integration-features = "cursor,sudo,title,ssh-env,ssh-terminfo,no-path";
            split-inherit-working-directory = true;
            tab-inherit-working-directory = true;
            window-inherit-working-directory = true;
            window-padding-color = "extend-always";
            window-show-tab-bar = "never";
            working-directory = "home";
            # keep-sorted end
          }
        );

      validatedConf =
        pkgs.runCommand ""
          {
            nativeBuildInputs = [ pkgs.ghostty ];
          }
          ''
            ghostty +validate-config --config-file=${conf}
            cp "${conf}" "$out"
          '';
    in
    {
      environment.systemPackages = [ pkgs.ghostty ];
      infra.dotfiles."ghostty/config.ghostty" = validatedConf;
    };
}
