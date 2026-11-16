{ config, pkgs, ... }:

{
  # qt5ct + qt6ct, QT_QPA_PLATFORMTHEME=qt5ct (qt6ct answers it too).
  # qt5ct/qt6ct.conf owned here. Colors still follow Dux: color_scheme_path is
  # the palette matugen rewrites on every theme change. Don't use Dux's
  # "Apply Qt colors" (it would edit these read-only files; not needed).
  qt =
    let
      qtct = v: font: {
        Appearance = {
          color_scheme_path = "${config.xdg.configHome}/qt${v}ct/colors/matugen.conf";
          custom_palette = true;
          icon_theme = "Papirus-Dark";
          standard_dialogs = "xdgdesktopportal";
          style = "Fusion";
        };
        Fonts = {
          fixed = ''"${font}"'';
          general = ''"${font}"'';
        };
      };
    in
    {
      enable = true;
      platformTheme.name = "qtct";
      qt5ctSettings = qtct "5" "Google Sans Flex,12,-1,5,50,0,0,0,0,0";
      qt6ctSettings = qtct "6" "Google Sans Flex,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
    };
  # Replace the copies Dux / qtct wrote before HM took these over.
  xdg.configFile."qt5ct/qt5ct.conf".force = true;
  xdg.configFile."qt6ct/qt6ct.conf".force = true;

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

  # ---- GTK: icons + cursor (Home Manager owns settings.ini + dconf) --------
  # gtk.theme stays unset: Dux switches adw-gtk3/adw-gtk3-dark itself, and it
  # writes gtk.css (dank-colors import), so HM must not create gtk.css.
  # Keep Dux's icon theme setting on "System Default".
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    # cursorTheme comes from home.pointerCursor.gtk.enable
  };

  # Papirus for flatpak apps (it isn't on Flathub). GTK and Qt both search
  # ~/.icons; each theme dir is exposed to the sandbox individually in
  # modules/nixos/services.nix, since flatpak only follows a symlink that is
  # itself the exposed path. Papirus-Dark links into ../Papirus, so both.
  home.file = builtins.listToAttrs (
    map
      (name: {
        name = ".icons/${name}";
        value.source = "${config.gtk.iconTheme.package}/share/icons/${name}";
      })
      [
        "Papirus"
        "Papirus-Dark"
      ]
  );

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
