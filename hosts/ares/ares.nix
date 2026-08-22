{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.ares = { ... }: {
    imports = map (m: flakeConfig.flake.modules.nixos."${m}") [
      # keep-sorted start
      "cli-tools"
      "core"
      "dotfiles"
      "git"
      "nushell"
      # keep-sorted end
    ];

    infra = {
      core = {
        disk = "/dev/disk/by-id/nvme-WD_Green_SN350_1TB_231350803893";
        profile = "daily-use";
      };
    };

    disko.devices.disk.main.content.partitions = {
      esp = {
        size = "1G";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        };
      };
      root = {
        size = "100%";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/";
        };
      };
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

  };
}
