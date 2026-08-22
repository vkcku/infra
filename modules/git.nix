{
  flake.modules.nixos.git =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      /**
        Format the given attrset as a git config. The `includeIf` sections
        are placed at the end of the configuration. This allows those included
        configurations to overwrite any previously set configurations. The order
        of the final `includeIf` sections are not guaranteed.
      */
      toGitIni =
        value:
        let
          includeIf = lib.attrsets.filterAttrs (key: _: lib.strings.hasSuffix "includeIf" key) value;
          others = removeAttrs value (builtins.attrNames includeIf);
        in
        lib.generators.toGitINI others + "\n" + lib.generators.toGitINI includeIf;

      cfg = config.infra.git;
    in
    {
      options.infra.git = {
        config = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "The git configuration. Any `includeIf` values are moved to the end of the file but there are no guarantees in the ordering of the includeIf directives.";
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "vkcku";
          description = "The git username.";
        };

        email = lib.mkOption {
          type = lib.types.str;
          default = "git@mail.vkcku.com";
          description = "The git email.";
        };
      };

      config = {
        infra.git.config = {
          # keep-sorted start block=yes newline_separated=yes
          alias = {
            dc = "diff --cached";
            pf = "push --force-with-lease";
          };

          branch = {
            sort = "-committerdate";
          };

          commit = {
            gpgSign = true;
            verbose = true;
          };

          core = {
            editor = "hx";
            # Show the whitespace properly in diffs. Generally, this should be
            # taken care of by formatters etc, but just in case.
            whitespace = "trailing-space";
            pager = "${pkgs.delta}/bin/delta";
            fsmonitor = true;
            compression = 9;
          };

          delta = {
            navigate = true;
            side-by-side = true;
            line-numbers = true;
            hyperlinks = true;
          };

          diff = {
            # Modern diff algorithm that handles moving code blocks around much
            # better.
            algorithm = "histogram";
            mnemonicPrefix = true;

            # Detect copies and renames in `git diff`.
            renames = "copy";
          };

          fetch.prune = true;

          gpg = {
            format = "ssh";
            ssh.program = "${pkgs.openssh}/bin/ssh-keygen";
          };

          help.autocorrect = "prompt";

          init.defaultBranch = "main";

          interactive.diff-filter = "${pkgs.delta}/bin/delta --color-only";

          maintenance = {
            auto = true;
            strategy = "incremental";
          };

          merge.conflictStyle = "zdiff3";

          push = {
            default = "simple"; # Already the default since v2.

            # Automatically track remote branch with the same name.
            autoSetupRemote = true;

            # Push tags to remote automatically.
            followTags = true;
          };

          rerere = {
            enabled = true;
            autoUpdate = true;
          };

          tag.gpgSign = true;

          transfer.fsckobjects = true;

          user = {
            name = cfg.user;
            email = cfg.email;
          };

          user.signingKey = "~/.ssh/id_ed25519.pub";
          # keep-sorted end
        };

        infra.dotfiles."git/config" = toGitIni cfg.config;

        environment.systemPackages = [ pkgs.git ];
      };
    };
}
