{
  flake.modules.nixos.cli-tools = { config, pkgs, ... }: {
    environment.systemPackages = [
      # keep-sorted start
      pkgs.acpi
      pkgs.bat
      pkgs.coreutils
      pkgs.eza
      pkgs.fd
      pkgs.file
      pkgs.gh
      pkgs.htop
      pkgs.ripgrep
      pkgs.wl-clipboard
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
