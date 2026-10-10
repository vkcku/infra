{
  mkNixPak,
  spotify,
  makeFontsConf,
  noto-fonts,
  noto-fonts-cjk-sans,
  noto-fonts-color-emoji,
  ...
}:
let
  fonts = makeFontsConf {
    fontDirectories = [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };

  sandboxed = mkNixPak {
    config = { sloth, ... }: {
      app.package = spotify;

      flatpak.appId = "com.spotify.Client";

      dbus.policies = {
        "org.mpris.MediaPlayer2.spotify" = "own";
        "org.freedesktop.Notifications" = "talk";
      };

      gpu.enable = true;

      bubblewrap = {
        network = true;

        sockets = {
          wayland = true;
          pipewire = true;
          pulse = true;
        };

        tmpfs = [ "/tmp" ];

        bind.rw = [
          (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/spotify"))
          (sloth.mkdir (sloth.concat' sloth.homeDir "/.cache/spotify"))
        ];

        env = {
          # keep-sorted start
          FONTCONFIG_FILE = "${fonts}";
          NIXOS_OZONE_WL = "1";
          TMPDIR = "/tmp";
          # keep-sorted end
        };

      };
    };
  };
in
sandboxed.config.env
