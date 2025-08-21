{
  lib,
  config,
  modulesPath,
  ...
}: {
  imports = [
    ./disko.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];

      kernelModules = [];
    };

    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 24 * 1024;
    }
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = config.my.architecture;

  virtualisation.vmVariant.virtualisation = {
    memorySize = 4 * 1024;
    graphics = true;
    cores = 3;
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
