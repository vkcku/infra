{
  flake.modules.nixos.desktop = { pkgs, ... }: {
    services.gnome.gnome-keyring.enable = true;

    # niri is launched via `niri-session` from a TTY, so the keyring is
    # unlocked by the `login` PAM service.
    security.pam.services.login.enableGnomeKeyring = true;

    # See https://niri-wm.github.io/niri/Important-Software.html#portals.
    xdg.portal = {
      enable = true;

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];

      config.niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };
}
