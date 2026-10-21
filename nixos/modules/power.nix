# Power profiles, power key, critical battery and charge limits. Hibernation
# is off at the kernel level (nohibernate, from hardening.nix).
{ ... }:
{
  services.power-profiles-daemon.enable = true;

  # The press that wakes the laptop from sleep also reaches logind once it has
  # resumed. At the default, poweroff, that shut it down a second after waking
  # (October 20).
  services.logind.settings.Login.HandlePowerKey = "ignore";

  services.upower = {
    enable = true;
    # the default, hybrid sleep, needs hibernation
    criticalPowerAction = "PowerOff";
  };
  # Nothing else starts UPower, and without it the critical action never fires.
  systemd.services.upower.wantedBy = [ "multi-user.target" ];
  # Stop charging at 80%, resume below 75%.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_start_threshold}="75", ATTR{charge_control_end_threshold}="80"
  '';
}
