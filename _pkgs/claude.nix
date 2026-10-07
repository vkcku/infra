{ mkNixPak, claude-code }:
let
  sandboxed = mkNixPak {
    config =
      { sloth, ... }:
      let
        configDir = sloth.mkdir (sloth.concat' sloth.homeDir "/.local/state/claude");
      in
      {
        bubblewrap = {
          bind.rw = [
            (sloth.env "PWD")

            configDir
            (sloth.mkdir (sloth.concat' sloth.homeDir "/.cache/claude-cli-nodejs"))
          ];

          bind.ro = [
            "/nix/store"

            "/run/current-system/sw"
            "/etc/profiles"

            # Git configuration for commits.
            (sloth.concat' sloth.homeDir "/.config/git")

            # User lookup.
            "/etc/passwd"
            "/etc/group"
            "/etc/nsswitch.conf"

            # Network name resolution.
            "/etc/hosts"
            "/etc/resolv.conf"
            "/etc/ssl/certs"
            "/etc/static/ssl/certs"
          ];

          network = true;

          newSession = true;
          dieWithParent = true;

          env = {
            CLAUDE_CONFIG_DIR = configDir;
            HOME = sloth.homeDir;
            PATH = sloth.env "PATH";
            TERM = sloth.env "TERM";
            COLORTERM = sloth.env "COLORTERM";
            LANG = sloth.env "LANG";
          };
        };

        app = {
          package = claude-code;
        };
      };
  };
in
sandboxed.config.env
