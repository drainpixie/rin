{
  disko.devices = {
    disk.vda = {
      type = "disk";
      device = "/dev/vda";

      content = {
        type = "table";
        format = "gpt";
        partitions = {
          ESP = {
            size = "512MiB";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
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
      };
    };
  };
}
