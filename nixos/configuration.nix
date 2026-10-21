# Laptop desktop. Each concern lives in modules/; the generated disk layout
# lives in hardware-configuration.nix, which stays in /etc/nixos.
# Apply: sudo cp -r ~/.config/.dotfiles/nixos/. /etc/nixos/ && sudo nixos-rebuild switch
# (the /. matters: without it cp nests a second nixos/ inside /etc/nixos)
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix      # boot loader, disk encryption, kernel, shutdown
    ./modules/hardware.nix  # bluetooth, firmware updates, media SSD
    ./modules/power.nix     # power profiles, battery
    ./modules/memory.nix    # zram, reclaim tuning, earlyoom
    ./modules/nix.nix       # nix settings, gc, nix-ld
    ./modules/desktop.nix   # sway, waybar, audio, fonts
    ./modules/hardening.nix # encrypted DNS, Tor, kernel and network lockdown
    ./modules/dev.nix       # languages, language servers, LaTeX
    ./modules/packages.nix  # apps, core security tools
  ];

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN";

  users.users.toad = {
    isNormalUser = true;
    shell = pkgs.fish;
    # no "video": brightnessctl goes through logind
    extraGroups = [ "wheel" "networkmanager" ];
  };
  security.sudo.execWheelOnly = true;

  # Installation compatibility version, not the package release selector.
  system.stateVersion = "26.05";
}
