{
  flake.modules.nixos.nushell = { config, pkgs, ... }: {
    infra.dotfiles = {
      "nushell/config.nu" = ./config.nu;

      "nushell/autoload/zoxide.nu" =
        pkgs.runCommandLocal "zoxide.nu"
          {
            nativeBuildInputs = [ pkgs.zoxide ];
          }
          ''
            zoxide init nushell > "$out"
            echo "alias cd = __zoxide_z" >> "$out"
            echo "alias cdi = __zoxide_zi" >> "$out"
          '';
    };

    users.users."${config.infra.core.username}" = {
      shell = pkgs.nushell;
      packages = [
        # keep-sorted start
        pkgs.zoxide
        # keep-sorted end
      ];
    };

    assertions = [
      {
        assertion = config.infra.core.profile == "daily-use";
        message = "nushell module can only be enabled for daily-use machines";
      }
    ];
  };
}
