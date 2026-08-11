{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.indra = { ... }: {
    imports = map (m: flakeConfig.flake.modules.nixos."${m}") [
      # keep-sorted start
      "core"
      # keep-sorted end
    ];

    hardware.facter.reportPath = ./facter.json;

    infra.core = {
      profile = "server";
      disk = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
    };

    disko.devices.disk.main.content.partitions = {
      # Hostinger VPS boots in legacy BIOS mode.
      boot = {
        size = "1M";
        type = "EF02";
        priority = 1;
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

    boot = {
      loader.grub = {
        enable = true;
        efiSupport = false;
      };

      kernelParams = [
        "console=tty1"
        # The Hostinger VPS does not work if the console output is not sent
        # to the serial console as well.
        "console=ttyS0,115200n8"
      ];
    };

    system.stateVersion = "26.11";
  };
}
