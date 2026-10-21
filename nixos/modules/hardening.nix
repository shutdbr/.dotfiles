# Privacy and hardening: encrypted DNS, Tor, kernel and network lockdown.
# NixOS and this kernel already restrict dmesg, kernel pointers, ptrace and
# unprivileged BPF, and zero memory on allocation; only the gaps are here.
{ lib, pkgs, ... }:
{
  # Proton VPN stores its login in a Secret Service keyring. The module also
  # unlocks it through PAM on TTY login, before fish starts Sway.
  services.gnome.gnome-keyring.enable = true;
  # Proton's OpenVPN connections need the NetworkManager plugin; WireGuard
  # support is built into NetworkManager.
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  # Encrypted DNS. ~. routes every lookup to Quad9 or Cloudflare rather than
  # whatever the network advertises, so a cafe or campus resolver sees nothing.
  # TLS is mandatory, so a network can't force lookups back to plain text by
  # blocking port 853. Each network's own servers inherit it too, which breaks
  # one whose internal resolver has no port 853 (a campus name server that only
  # answers its own domain). Relax just that network, once:
  #   nmcli connection modify <name> connection.dns-over-tls opportunistic
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
        "2620:fe::fe#dns.quad9.net"
        "1.1.1.1#cloudflare-dns.com"
        "2606:4700:4700::1111#cloudflare-dns.com"
      ];
      Domains = [ "~." ];
      DNSOverTLS = true;
      # name-poisoning targets on shared networks, what Responder abuses
      LLMNR = false;
      MulticastDNS = false;
    };
  };
  # Hotel and airport logins need the network's own DNS to show the portal:
  # `sudo captive-dns on`, log in, then `sudo captive-dns off`. Reboot resets it.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "captive-dns" ''
      set -eu
      drop=/run/systemd/resolved.conf.d/captive.conf
      case "''${1:-}" in
        on)
          mkdir -p /run/systemd/resolved.conf.d
          printf '[Resolve]\nDNS=\nDomains=\nDNSOverTLS=no\n' > "$drop"
          ;;
        off) rm -f "$drop" ;;
        *) echo "usage: sudo captive-dns on|off" >&2; exit 2 ;;
      esac
      systemctl restart systemd-resolved
    '')
  ];

  # Tor client: a SOCKS proxy on 127.0.0.1:9050. Not started at boot, so the
  # network doesn't see Tor traffic all day: `sudo systemctl start tor`.
  # `torsocks <command>` sends one program through it. Tor Browser has its own.
  services.tor = {
    enable = true;
    client.enable = true;
    torsocks.enable = true;
  };
  systemd.services.tor.wantedBy = lib.mkForce [ ];

  # A random Wi-Fi hardware address per network, kept stable on that network,
  # so networks can't follow the laptop from one to the next.
  networking.networkmanager.wifi.macAddress = "stable";

  # No swapping in a different kernel at runtime (kexec). Also turns
  # hibernation off at the kernel level (nohibernate).
  security.protectKernelImage = true;
  # Kernel heap and page allocator harder to exploit; costs a little memory.
  boot.kernelParams = [ "slab_nomerge" "page_alloc.shuffle=1" ];

  boot.kernel.sysctl = {
    # Magic SysRq limited to REISUB: raw keyboard, sync, read-only remount,
    # kill tasks, reboot. No memory or task dumps from the keyboard.
    "kernel.sysrq" = 244;
    "fs.suid_dumpable" = 0; # setuid programs never write core dumps
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "dev.tty.ldisc_autoload" = 0;
    # Ignore ICMP redirects, which let anyone on the network reroute traffic.
    # The * reaches every interface, including ones plugged in later.
    "net.ipv4.conf.*.accept_redirects" = 0;
    "net.ipv6.conf.*.accept_redirects" = 0;
  };

  # Rare network protocols and filesystems the kernel would otherwise load on
  # demand for any program or plugged-in disk that asks. Old bugs live here.
  # `sudo modprobe hfsplus` still loads one by hand.
  boot.blacklistedKernelModules = [
    "sctp" "rds" "tipc" "n_hdlc" "ax25" "netrom" "x25" "rose"
    "appletalk" "psnap" "atm" "can" "ieee802154"
    "cramfs" "freevxfs" "jffs2" "hfs" "hfsplus"
  ];

  # Only wheel users may talk to the nix daemon.
  nix.settings.allowed-users = [ "@wheel" ];

  programs.firefox.policies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
  };
}
