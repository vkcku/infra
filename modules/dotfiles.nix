{ inputs, ... }:
{
  flake.modules.nixos.dotfiles =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.hjem.nixosModules.default ];

      options.infra.dotfiles =
        let
          inherit (lib.types)
            attrsOf
            coercedTo
            pathInStore
            str
            ;
        in
        lib.mkOption {
          type = attrsOf (coercedTo str (s: pkgs.writeText "dotfiles-inline" s) pathInStore);
          default = { };
          description = "An attrset containing the files to link for the under XDG_CONFIG_HOME for the default user.";
        };

      config = {
        hjem = {
          clobberByDefault = true;

          linker = pkgs.smfh;

          users."${config.infra.core.username}".xdg.config.files = lib.attrsets.mapAttrs (_: path: {
            source = path;
          }) config.infra.dotfiles;
        };

        assertions = [
          {
            assertion = config.infra.core.profile == "daily-use";
            message = "dotfiles module can only be enabled for daily-use machines";
          }
        ];
      };
    };
}
