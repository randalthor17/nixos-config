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
    # Base GTK3 theme for Dux colors (Settings > Theme & Apps > Apply GTK
    # colors copies it to ~/.local/share/themes and patches it).
    adw-gtk3
  ];

  # ---- AppImages -----------------------------------------------------------
  # binfmt: the kernel hands any AppImage (matched by its magic bytes, not the
  # name) to appimage-run's FHS env, so `./Foo.AppImage`, desktop entries and
  # Gear Lever-integrated apps all just work. Missing libs for a specific
  # AppImage: package = pkgs.appimage-run.override { extraPkgs = p: [ ... ]; }.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

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

  # RemoteDesktop (KDE Connect "Remote input"): the gnome portal needs
  # org.gnome.Mutter.RemoteDesktop, which niri doesn't implement. luminous
  # injects through wlr-virtual-pointer / virtual-keyboard, which niri has.
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-luminous ];
  xdg.portal.config.niri."org.freedesktop.impl.portal.RemoteDesktop" = "luminous";

  # Calendar / online accounts / secrets backends for the shell's widgets
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;

  # setuid pkexec wrapper, so apps can elevate through polkit
  security.polkit.enablePkexecWrapper = true;
}
