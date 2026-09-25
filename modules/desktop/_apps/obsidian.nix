{
  mkNixPak,
  obsidian,
}:
let
  sandboxed = mkNixPak {
    config = { sloth, ... }: {
      bind.rw = [
        (sloth.concat' sloth.homeDir "/notes")
        (sloth.concat' sloth.homeDir "/.config/obsidian")

        (sloth.concat [
          sloth.runtimeDir
          "/"
          (sloth.env "WAYLAND_DISPLAY")
        ])
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
      ];

      env = {
        NIXOS_OZONE_WL = "1";
        WAYLAND_DISPLAY = sloth.env "WAYLAND_DISPLAY";
        XDG_RUNTIME_DIR = sloth.runtimeDir;
      };
    };

    app = {
      package = obsidian;

      extraEntrypoints = [
        "/bin/obsidian-cli"
      ];
    };
  };
in
sandboxed.config.env
