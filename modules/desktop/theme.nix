{
  flake.modules.nixos.desktop =
    { lib, ... }:
    {
      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
          }
        ];
      };

      # GTK3 apps ignore the portal color-scheme, so also set the legacy
      # dark-theme hint they read directly.
      infra.dotfiles."gtk-3.0/settings.ini" = lib.generators.toINI { } {
        Settings.gtk-application-prefer-dark-theme = true;
      };
    };
}
