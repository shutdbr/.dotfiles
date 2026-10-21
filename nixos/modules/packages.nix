# Everyday programs. One-offs: `nix shell nixpkgs#foo`.
{ pkgs, ... }:
{
  programs.fish.enable = true;
  # translate the shell env to fish at build time, instead of running bash
  # through fenv on every fish start (~22ms each)
  programs.fish.useBabelfish = true;
  # fish turns this on, and it rebuilds the man index on every rebuild.
  documentation.man.cache.enable = false;
  programs.git.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true; # EDITOR=nvim for every shell, sudoedit and git
  };
  programs.firefox.enable = true;

  # `locate foo` without sudo; the index rebuilds daily at 02:15.
  services.locate.enable = true;

  # Packet capture without root for the wireshark group.
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  users.users.toad.extraGroups = [ "wireshark" ];

  environment.systemPackages = with pkgs; [
    kitty
    # native wayland build for Doom; doom finds epdfinfo through pdf-tools
    emacs-pgtk
    emacs-pgtk.pkgs.pdf-tools
    ripgrep
    fd
    unzip
    pciutils
    usbutils
    file
    jq
    btop
    nvd
    smartmontools # smartctl -a /dev/nvme0n1: SSD health
    imv # images
    tree

    # messaging and passwords
    signal-desktop
    whatsapp-electron
    simplex-chat-desktop
    session-desktop
    bitwarden-desktop

    # privacy. Tor itself is a service in hardening.nix
    proton-vpn # GUI: protonvpn-app; credentials use GNOME Keyring
    tor-browser
    onionshare-gui # share and receive files over Tor
    mat2 # remove metadata from documents, images and media
    age # simple command-line file encryption
    veracrypt # encrypted file containers and removable drives
    feather

    # security tools, the core set. The rest on demand, e.g. wordlists:
    # nix shell nixpkgs#seclists
    nmap
    tcpdump
    burpsuite
    sqlmap
    ffuf
    gobuster
    hashcat
    john
    metasploit
  ];
}
