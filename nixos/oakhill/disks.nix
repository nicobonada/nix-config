# oakhill disk layout. Source of truth for GPT + tank + mounts.
#
# Live pool already exists. `nixos-rebuild switch` only writes fileSystems and
# (via disko-zfs) dataset properties. Never run
# `disko --mode destroy,format` against this host.
#
# Leftovers vs a clean recreate:
# - each NVMe has an unused 8M p9 (OpenZFS reserved slice)
# - nvme0n1 still has a stale whole-disk `rpool` label (pool is tank on p1)
# - sda games is p4 (no p3); a recreate would make it p3
{ lib, ... }:
{
  disko.devices = {
    disk = {
      evo-plus = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S59ANM0RA17992K";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      evo = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0R146966B";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/ata-CT1000BX500SSD1_2110E583AEFB";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "swap";
              };
            };
            games = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home/nico/stuff/games";
              };
            };
          };
        };
      };
    };

    zpool.tank = {
      type = "zpool";
      mode = "mirror";
      options.ashift = "13";
      # Pool dataset is unmounted; children that NixOS mounts use legacy.
      rootFsOptions = {
        mountpoint = "none";
        compression = "zstd";
        xattr = "sa";
        acltype = "posix";
        relatime = "on";
      };
      datasets = {
        home = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/home";
        };
        "home/stuff" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/home/nico/stuff";
        };
        "home/music" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/home/nico/stuff/music";
        };
        local = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
        "local/nix" = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            # Caps /nix so Determinate GC sees dataset free, not the whole pool.
            quota = "80G";
          };
          mountpoint = "/nix";
        };
        system = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
        "system/root" = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/";
        };
        "system/var" = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            # Backstop so logs/caches cannot fill the pool. journald is
            # already SystemMaxUse=500M; this is the dataset ceiling.
            quota = "10G";
          };
          mountpoint = "/var";
        };
      };
    };
  };

  disko.zfs = {
    enable = true;
    settings.ignoredProperties = [
      "nixos:shutdown-time"
      "nixos:*"
    ];
  };

  # Upstream only requiredBy local-fs-pre (boot). Without wantedBy, switch
  # leaves the oneshot dead and never applies quota/properties.
  systemd.services.disko-zfs.wantedBy = [ "multi-user.target" ];

  # Live sda has no PARTLABELs and games is p4. Keep the devices that already work.
  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-uuid/60CA-A4B7";
  fileSystems."/home/nico/stuff/games".device = lib.mkForce "/dev/disk/by-label/games";
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/var".neededForBoot = true;
  swapDevices = lib.mkForce [
    { device = "/dev/disk/by-uuid/ccd927bf-d32b-408c-a0f2-9074caecf98a"; }
  ];
}
