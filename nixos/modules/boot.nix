# Boot loader, disk encryption, kernel settings and shutdown.
{ ... }:
let
  # The two encrypted partitions. After a reinstall, list the new ones with
  #   lsblk -o NAME,SIZE,FSTYPE,UUID | grep crypto_LUKS
  # and paste the big one's UUID into root and the 16G one's into swap.
  root = "2124e935-f357-4f3b-9fa1-05653629e9a2";
  swap = "7e279086-5dd5-4f76-8b6e-e8868347a1bd";
in
{
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.tmp.cleanOnBoot = true;

  # TRIM for the root partition.
  boot.initrd.luks.devices."luks-${root}".allowDiscards = true;
  # The installer unlocked swap from its own configuration.nix; without this
  # line nothing unlocks it and boot waits 90 s for it.
  boot.initrd.luks.devices."luks-${swap}".device = "/dev/disk/by-uuid/${swap}";
}
