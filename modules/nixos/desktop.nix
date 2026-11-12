{ lib, pkgs, ... }:

{
  # ---- Compositor --------------------------------------------------------
  # Installs niri, registers the session, and sets up portals + keyring.
  # Its config is per user (home/niri.nix).
  programs.niri = {
    enable = true;
    useNautilus = false; # Dux Files is the file chooser (below)
  };
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    dux-gop
  ];

  # ---- Dux Shell ---------------------------------------------------------
  # Greeter + shell and its companion tools (dsearch, dgop, dfiles, dcal).
  services.displayManager.dux-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/rand";
  };
  programs.dux-shell.enable = true;
  programs.dux-search.enable = true;
  programs.dux-files.enable = true;
  programs.dux-calendar.enable = true;

  # File chooser from Dux Files. With useNautilus off, niri's module picks
  # GTK's; the rest of the portal config is niri's own.
  xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = lib.mkForce "dfiles";

  # Calendar / online accounts / secrets backends for the shell's widgets
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;
}
