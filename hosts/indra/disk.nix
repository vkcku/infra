{
  flake.modules.nixos.indra = { ... }: {
    disko.devices.disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
        content = {
          type = "gpt";

          partitions = {
            # Hostinger VPS boots in legacy BIOS mode.
            boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };

            root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };

    disko.devices.zpool = {
      zroot = {
        type = "zpool";

        options = {
          # keep-sorted start
          ashift = "12";
          autoexpand = "on";
          autotrim = "on";
          # keep-sorted end
        };

        rootFsOptions = {
          # keep-sorted start
          acltype = "posix";
          atime = "off";
          canmount = "off";
          checksum = "on";
          compression = "zstd-3";
          devices = "off";
          normalization = "formD";
          # On NixOS, the setuid stuff lives in `/run/wrappers` which is
          # tmpfs so nothing needs to have setuid.
          setuid = "off";
          xattr = "sa";
          # keep-sorted end
        };

        datasets = {
          "local" = {
            type = "zfs_fs";
            options.canmount = "off";
          };

          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };

          "local/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options = {
              mountpoint = "legacy";
              # Prevent runaway logging from taking over the entire disk.
              quota = "5GB";
            };
          };

          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            # This is for impermanence. I don't plan on using it because I find
            # it annoying to have to remember to specify which directories/files
            # to include. However, by creating this snapshot I still have
            # the option to enable it at a later point if needed.
            postCreateHook = ''
              zfs snapshot zroot/local/root@blank
            '';
          };

          # Dataset that acts as a staging area for backups.
          "local/backups" = {
            type = "zfs_fs";
            mountpoint = "/var/backup";
            options.mountpoint = "legacy";
          };

          reservation = {
            type = "zfs_fs";
            options = {
              canmount = "off";
              reservation = "10G";
            };
          };

          "safe" = {
            type = "zfs_fs";
            options.canmount = "off";
          };

          "safe/postgresql" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/postgresql";
            options = {
              mountpoint = "legacy";
              recordsize = "32k";
            };
          };

          # Data specific to all services.
          "safe/data" = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
