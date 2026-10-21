# Bluetooth, firmware updates and the second SSD.
{ ... }:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.fwupd.enable = true;

  # Second SSD, mounted on first access.
  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/d2313096-1442-45e7-b3a7-3361e6e05dcd";
    fsType = "ext4";
    options = [ "noatime" "nofail" "x-systemd.automount" ];
  };
}
