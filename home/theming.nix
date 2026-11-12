{ config, pkgs, ... }:

{
  # qt5ct + qt6ct, QT_QPA_PLATFORMTHEME=qt5ct (qt6ct answers it too).
  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  # `dms run` sets QT_QPA_PLATFORMTHEME_QT6=gtk3 when unset, and apps launched
  # from Dux inherit it, so Qt6 apps skip qt6ct (and the matugen palette).
  # systemd.user (environment.d) is what the dms service and its children see.
  home.sessionVariables.QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
  systemd.user.sessionVariables.QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";

  # KDE/Kirigami apps (KDE Connect) take colors from kdeglobals, not qt6ct.
  # Point it at the scheme Dux regenerates on every wallpaper/theme change.
  xdg.configFile."kdeglobals".source =
    config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/color-schemes/DankMatugen.colors";

  # Flatpak apps are sandboxed and can't see the matugen/Dux-generated theme
  # files in ~/.config, so expose them read-only. A user-level global override
  # applies to system-installed flatpaks too. (The adw-gtk3-dark flatpak theme
  # must also be installed, which it is.)
  xdg.dataFile."flatpak/overrides/global".text = ''
    [Context]
    filesystems=xdg-config/gtk-3.0:ro;xdg-config/gtk-4.0:ro;xdg-config/qt5ct:ro;xdg-config/qt6ct:ro;
  '';

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Ice";
    size = 24;
    package = pkgs.bibata-cursors;
  };

  # Google Sans Flex as the UI sans/serif (font itself is installed
  # system-wide in modules/nixos/fonts.nix).
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Google Sans Flex"
        "Noto Sans"
      ];
      serif = [
        "Google Sans Flex"
        "Noto Serif"
      ];
      monospace = [
        "GoogleSansCode Nerd Font"
        "Noto Sans Mono"
      ];
    };
    antialiasing = true;
    hinting = "slight";
    subpixelRendering = "rgb";
  };
}
