{
  flake.modules.nixos.core =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      user = "deploy";
    in
    {

      config = lib.mkIf (config.infra.core.profile == "server") {

        users.groups."${user}" = { };

        users.users."${user}" = {
          isSystemUser = true;
          group = user;
          shell = pkgs.bash;
          hashedPassword = "!";
        };

        security.sudo.extraRules = [
          {
            users = [ user ];
            commands = [
              {
                # TODO: Figure out if there is a more secure way to handle
                # this.
                #
                # Currently, I am hoping this is not going to be as much of
                # an issue since SSH only works over my tailnet. Maybe some
                # restricted access control policies that only allow access
                # from specific machines (such as my personal laptop and any
                # CI machines) will be good enough?
                command = "ALL";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];

        nix.settings.trusted-users = [ user ];
      };
    };
}
