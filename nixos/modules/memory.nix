# Compressed swap in RAM and the out-of-memory killer.
{ ... }:
{
  zramSwap.enable = true;

  # Act on RAM alone: with 16G of disk swap the default waits until it thrashes.
  # Both thresholds, or only SIGTERM ignores swap: an unset kill threshold
  # defaults to half the SIGTERM one, so SIGKILL would hold off until ~15G of
  # the 31G of swap had filled -- long enough for a process that sits on
  # SIGTERM to keep growing.
  services.earlyoom = {
    enable = true;
    freeSwapThreshold = 100;
    freeSwapKillThreshold = 100;
    enableNotifications = true;
    extraArgs = [
      # Names come from /proc/PID/comm, which truncates at 15 characters and
      # keeps Nix's wrapper prefix, so swaylock shows up as ".swaylock-wrapp".
      # Match loosely: anchoring on exact names silently missed it, leaving the
      # lock screen killable. This also covers swayidle, swaybg and waybar.
      "--avoid" "(sway|waybar|Xwayland)"
      # A Firefox tab dies instead of the whole browser. "Isolated Web Co" is
      # already the truncated form.
      "--prefer" "^(Web Content|Isolated Web Co)$"
    ];
  };
}
