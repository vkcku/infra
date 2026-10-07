{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.ares = { lib, ... }: {
    imports = map (m: flakeConfig.flake.modules.nixos."${m}") [
      # keep-sorted start
      "cli-tools"
      "core"
      "desktop"
      "dotfiles"
      "git"
      "nushell"
      # keep-sorted end
    ];

    infra = {
      core = {
        profile = "daily-use";
      };

      desktop.externalMonitor = "HDMI-A-1";
    };

    networking = {
      hostName = "ares";
      hostId = "e0c9078e";
    };

    time.timeZone = "Asia/Kolkata";

    hardware.facter.reportPath = ./facter.json;
    system.stateVersion = "26.11";

    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 100;
        editor = false;
      };
    };

    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
        "obsidian"
        "spotify"
      ];
  };
}
