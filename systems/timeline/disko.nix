{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";

    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          device = "/dev/disk/by-label/NIXBOOT";
          content = {
            format = "vfat";
            type = "filesystem";
            mountpoint = "/boot";
            mountOptions = ["defaults"];

            extraArgs = [
              "-n"
              "NIXBOOT"
            ];
          };
        };

        root = {
          size = "100%";
          device = "/dev/disk/by-label/NIXROOT";
          content = {
            format = "ext4";
            mountpoint = "/";
            type = "filesystem";
            mountOptions = ["defaults"];

            extraArgs = [
              "-L"
              "NIXROOT"
            ];
          };
        };

        encrypted = {
          size = "40G";
          device = "/dev/disk/by-label/ENCRYPTED";

          content = {
            type = "luks";
            name = "encrypted";
            settings.allowDiscards = true;

            content = {
              mountpoint = "/media/backup";
              type = "filesystem";
              format = "ext4";

              extraArgs = [
                "--label"
                "BACKUP"
              ];
            };
          };
        };
      };
    };
  };
}
