{ inputs, ... }:
{
  flake.modules.nixos.core =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      conf = pkgs.writers.writeTOML "helix.toml" {
        theme = "bogster";

        editor = {
          shell =
            let
              shell =
                if lib.getName config.users.users."${config.infra.core.username}".shell == "nushell" then
                  "nu"
                else
                  "bash";
            in
            [
              shell
              "-c"
            ];
          line-number = "relative";
          auto-format = false;
          completion-replace = true;
          true-color = true;
          popup-border = "popup";

          file-picker.hidden = false;

          end-of-line-diagnostics = "disable";

          statusline = {
            left = [
              "mode"
              "spinner"
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
              "diagnostics"
            ];
            center = [ ];
            right = [
              "register"
              "position"
              "version-control"
            ];
          };

          lsp = {
            goto-reference-include-declaration = false;
          };

          cursor-shape = {
            insert = "bar";
          };

          auto-save = {
            focus-lost = true;
            after-delay.enable = true;
          };

          soft-wrap = {
            enable = true;
          };

          inline-diagnostics = {
            cursor-line = "warning";
            max-diagnostics = 1;
          };
        };

        keys = {
          # Write the file, if modified, when switching to normal mode from
          # insert mode.
          insert.esc = [
            "normal_mode"
            ":update"
          ];

          normal = {
            g.e = "goto_last_line";
            J = "select_line_below";
            K = "select_line_above";

            # Switch the default behavior.
            space = {
              f = "file_picker_in_current_directory";
              F = "file_picker";
            };
          };

          select = {
            g.e = "extend_to_last_line";
          };
        };
      };

      helix = pkgs.symlinkJoin {
        name = "helix-wrapped";
        paths = [ pkgs.helix ];
        nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hx \
            --add-flags '--config' \
            --add-flags '${conf}'
        '';
      };
    in
    {
      nixpkgs.overlays = [ inputs.helix.overlays.default ];

      environment = {
        systemPackages = [ helix ];
        sessionVariables.EDITOR = "hx";
      };
    };
}
