{
  mkNixPak,
  spotify,
  ...
}:
let
  sandboxed = mkNixPak {
    config = { sloth, ... }: {
      bubblewrap = {
        bind.rw = [
          (sloth.concat' sloth.homeDir "/.config/spotify")
          (sloth.concat' sloth.homeDir "/.cache/spotify")

          (sloth.concat [
            sloth.runtimeDir
            "/"
            (sloth.env "WAYLAND_DISPLAY")
          ])

          # PipeWire for audio.
          (sloth.concat' sloth.runtimeDir "/pipewire-0")
        ];

        # For GPU.
        bind.dev = [ "/dev/dri" ];

        bind.ro = [
          "/nix/store"

          # For GPU.
          "/run/opengl-driver"
          "/run/opengl-driver-32"

          # Fonts.
          "/etc/fonts"

          # Network name resolution.
          "/etc/resolv.conf"
          "/etc/ssl/certs"
          "/etc/static/ssl/certs"
        ];

        network = true;

        env = {
          NIXOS_OZONE_WL = "1";
          WAYLAND_DISPLAY = sloth.env "WAYLAND_DISPLAY";
          XDG_RUNTIME_DIR = sloth.runtimeDir;
        };
      };

      app = {
        package = spotify;
      };
    };
  };
in
sandboxed.config.env
