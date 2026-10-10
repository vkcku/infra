{ inputs, ... }: {
  flake.modules.nixos.cli-tools =
    { config, pkgs, ... }:
    let
      claude = pkgs.callPackage ../_pkgs/claude.nix {
        mkNixPak = inputs.nixpak.lib.nixpak {
          inherit (pkgs) lib;
          inherit pkgs;
        };
      };
      protondrive = pkgs.callPackage ../_pkgs/proton-drive.nix { };
      protonpass = pkgs.callPackage ../_pkgs/proton-pass-cli.nix { };
    in
    {
      environment.systemPackages = [
        # keep-sorted start
        claude
        pkgs.acpi
        pkgs.bat
        pkgs.bubblewrap
        pkgs.coreutils
        pkgs.eza
        pkgs.fd
        pkgs.file
        pkgs.gh
        pkgs.htop
        pkgs.ripgrep
        pkgs.wl-clipboard
        protondrive
        protonpass
        # keep-sorted end
      ];

      assertions = [
        {
          assertion = config.infra.core.profile == "daily-use";
          message = "cli-tools module can only be enabled for daily-use machines";
        }
      ];
    };
}
