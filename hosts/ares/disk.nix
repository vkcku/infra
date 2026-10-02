{
  flake.modules.nixos.ares = { ... }: {
    disko.devices.disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_Green_SN350_1TB_231350803893";
        content = {
          type = "gpt";

          partitions = {
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

          # Used as staging area for backups if needed.
          "local/backups" = {
            type = "zfs_fs";
            mountpoint = "/var/backups";
            options.mountpoint = "legacy";
          };

          reservation = {
            type = "zfs_fs";
            options = {
              canmount = "off";
              reservation = "20G";
            };
          };

          "safe" = {
            type = "zfs_fs";
            options.canmount = "off";
          };

          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
