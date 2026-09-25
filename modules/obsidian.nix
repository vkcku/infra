{ inputs, ... }: {
  flake.modules.nixos.obsidian =
    { pkgs, ... }:
    let
      mkNixPak = inputs.nixpak.lib.nixpak {
        inherit (pkgs) lib;
        inherit pkgs;
      };

      obsidian = mkNixPak {
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
          package = pkgs.obsidian;

          extraEntrypoints = [
            "/bin/obsidian-cli"
          ];
        };
      };
    in
    {
      environment.systemPackages = [ obsidian.config.env ];
    };
}
