# The graphical session: sway, waybar, audio, fonts, the look.
{ pkgs, ... }:
{
  # TTY login on tty1 starts sway (see fish/config.fish). This module supplies
  # graphics, audio, screen-sharing portals, XWayland and swaylock authentication.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      rofi
      dunst
      copyq
      libnotify
      grim
      slurp
      wl-clipboard
      brightnessctl
      playerctl
      pavucontrol
      autotiling-rs # new windows split the focused one along its long side
      poweralertd # low and critical battery notifications
      # the look: Windows 95 theme and icons. Adwaita supplies the cursor
      # and any icon Chicago95 lacks
      chicago95
      adwaita-icon-theme
      # lets GTK apps open terminal programs like nvim; it finds kitty itself
      xdg-terminal-exec
    ];
  };
  # Default apps, system-wide (nothing in ~/.config): web, HTML and PDFs in
  # Firefox, text in nvim.
  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "text/html" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/pdf" = "firefox.desktop";
    "text/plain" = "nvim.desktop";
  };
  # The system-wide default theme and icons; the cursor stays GTK's default,
  # Adwaita. GTK apps read dconf; rofi, finding no icon-theme of its own,
  # reads gtk-3.0/settings.ini. Only sway/config (cursor) and dunstrc (icons)
  # still name them, since neither looks anywhere else.
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "Chicago95";
        icon-theme = "Chicago95";
      };
    }
  ];
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Chicago95
    gtk-icon-theme-name=Chicago95
  '';
  security.rtkit.enable = true;
  services.speechd.enable = false;
  # starts with the graphical session
  programs.waybar.enable = true;
  fonts.packages = [ pkgs.monaspace ];
  environment.sessionVariables = {
    # Electron apps (Signal, WhatsApp, SimpleX, Session, Bitwarden) on Wayland
    NIXOS_OZONE_WL = "1";
    # Java GUIs (Burp) draw blank grey windows on sway without it.
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
}
