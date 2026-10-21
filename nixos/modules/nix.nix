# Nix itself: settings, garbage collection, store dedupe.
{ ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    connect-timeout = 5;
    experimental-features = [ "nix-command" "flakes" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
  # Rebuilds yield the CPU to the desktop.
  nix.daemonCPUSchedPolicy = "batch";

  # Real loader at /lib64/ld-linux-x86-64.so.2 in place of the default
  # stub-ld, so prebuilt generic-Linux binaries run: pip wheels, npm
  # packages that download binaries, and similar.
  programs.nix-ld.enable = true;
}
