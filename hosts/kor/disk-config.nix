{ ... }:
{
  # TODO kinda hacky; go back to impermanence, which would also handle this
  # systemd.tmpfiles.settings = {
  # "10-kor-package-dummy" = {
  #   "/secondary-disk/Development".d = {
  #     mode = "0755";
  #     user = me.user;
  #     group = me.user;
  #   };
  # ${projects_path}."L?" = {
  #   mode = "0755";
  #   user = me.user;
  #   group = me.user;
  #   argument = "/secondary-disk/Development";
  # };
  # ${projects_path}."L?" = {
  #   mode = "0755";
  #   user = me.user;
  #   group = me.user;
  #   argument = "/secondary-disk/Development";
  # };
  # };
  # };
  # basically the same rule as will be generated from above
  # systemd.tmpfiles.rules = [
  #   # type path mode user group age argument
  #   # setting age/argument to - ignores them. if age is set, contents of a directory are subject to time-based cleanup...
  #   "d ${projects_path} 0755 ${me.user} ${me.user} -"
  #   "L ${projects_path} - - - - /secondary-disk/Development"
  # ];
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme1n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              name = "root";
              end = "-32G";
              content = {
                type = "filesystem";
                format = "f2fs";
                mountpoint = "/";
                extraArgs = [
                  "-O"
                  "extra_attr,inode_checksum,sb_checksum,compression"
                ];
                mountOptions = [
                  "compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime,nodiscard"
                ];
              };
            };
            swap = {
              # end = "-0";
              size = "100%";
              content = {
                type = "swap";
                priority = 100;
                discardPolicy = "both";
                resumeDevice = true;
                randomEncryption = false;
              };
            };
          };
        };
      };
      # TODO clean up the mounting, maybe via volume grouping or something; use impermanence?
      # secondary = {
      #   device = "/dev/sda";
      #   type = "disk";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       root = {
      #         size = "100%";
      #         content = {
      #           type = "filesystem";
      #           format = "xfs";
      #           mountpoint = "/secondary-disk";
      #           # mountpoint = projects_path;
      #           mountOptions = [
      #             "defaults"
      #             # "mode=775" # allow group-write
      #           ];
      #         };
      #       };
      #     };
      #   };
      # };
    };
  };
}
