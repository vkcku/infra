{
  flake.modules.nixos.cli-tools =
    { config, pkgs, ... }:
    let
      protondrive = pkgs.callPackage ../_pkgs/proton-drive.nix { };
    in
    {
      environment.systemPackages = [
        # keep-sorted start
        pkgs.acpi
        pkgs.bat
        pkgs.bubblewrap
        pkgs.coreutils
        pkgs.eza
        pkgs.fd
        pkgs.file
        pkgs.gh
        pkgs.htop
        pkgs.proton-pass-cli
        pkgs.ripgrep
        pkgs.wl-clipboard
        protondrive
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
