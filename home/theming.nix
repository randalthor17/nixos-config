{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

# User side of the theme. Values: osConfig.theme (hosts/nixos/theme.nix).
# Colors: Dux Shell regenerates them on every wallpaper/theme change
#   - GTK: Dux writes gtk.css (Theme & Apps -> "Apply GTK colors", once)
#   - Qt: DankMatugen.colors, used by qtengine and kdeglobals below
let
  t = osConfig.theme;
  inherit (config.xdg) configHome dataHome;

  duxColorScheme = "${dataHome}/color-schemes/DankMatugen.colors";

  # QFont::toString() (Qt6) for kdeglobals
  qfont = name: size: "${name},${toString size},-1,5,400,0,0,0,0,0,0,0,0,0,0,1";

  # Write a real, writable file at activation (not a store symlink).
  # always: overwrite every activation; otherwise only seed when missing.
  writeFile =
    {
      target,
      source,
      always,
    }:
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      ${lib.optionalString (!always) ''if [ ! -e "${target}" ]; then''}
      run mkdir -p "$(dirname "${target}")"
      run install -m 644 ${source} "${target}"
      ${lib.optionalString (!always) "fi"}
    '';
in
{
  # ---- Fonts ---------------------------------------------------------------
  # Packages are installed system-wide by modules/nixos/theme.nix.
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        t.fonts.sans.name
        "Noto Sans"
      ];
      serif = [
        t.fonts.sans.name
        "Noto Serif"
      ];
      monospace = [
        t.fonts.mono.name
        "Noto Sans Mono"
      ];
    };
    antialiasing = true;
    hinting = "slight";
    subpixelRendering = "rgb";
  };

  # ---- Cursor (GTK, X11/XWayland, XCURSOR_*; niri reads it in home/niri.nix)
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    inherit (t.cursor) name package size;
  };

  # ---- GTK -----------------------------------------------------------------
  # HM owns settings.ini + dconf (icons, cursor, font). gtk.theme stays unset:
  # Dux switches adw-gtk3 / adw-gtk3-dark itself and owns gtk.css.
  # Keep Dux's icon theme setting on "System Default".
  gtk = {
    enable = true;
    iconTheme = { inherit (t.icons) name package; };
    font = {
      inherit (t.fonts.sans) name;
      inherit (t.fonts) size;
    };
  };

  # Icon theme in ~/.icons as well: flatpak apps can see it there (the store
  # can't be exposed). Each dir is exposed individually (flatpak override below).
  home.file = lib.genAttrs' t.icons.dirs (
    dir: lib.nameValuePair ".icons/${dir}" { source = "${t.icons.package}/share/icons/${dir}"; }
  );

  # ---- Qt: qtengine (plugin + QT_QPA_PLATFORMTHEME from modules/nixos/theme.nix)
  # Also for the systemd user session: the dms service only treats qtengine as
  # active when it sees these, and `dms run` would otherwise set
  # QT_QPA_PLATFORMTHEME_QT6=gtk3 for every app launched from Dux.
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qtengine";
    QT_QPA_PLATFORMTHEME_QT6 = "qtengine";
  };
  systemd.user.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qtengine";
    QT_QPA_PLATFORMTHEME_QT6 = "qtengine";
  };

  # qtengine's config stays writable: Dux updates its color scheme and icon
  # theme (Theme & Apps -> "Apply Qt colors", and on each theme change with
  # the qtengine template on). So it's only seeded when missing; delete
  # ~/.config/qtengine/config.json to re-seed after changing the theme.
  home.activation.seedQtengineConfig = writeFile {
    target = "${configHome}/qtengine/config.json";
    always = false;
    source = (pkgs.formats.json { }).generate "qtengine-config.json" {
      theme = {
        colorScheme = duxColorScheme;
        iconTheme = t.icons.name;
        style = t.qtStyle;
        font = {
          family = t.fonts.sans.name;
          inherit (t.fonts) size;
          weight = -1;
        };
        fontFixed = {
          family = t.fonts.mono.name;
          inherit (t.fonts) size;
          weight = -1;
        };
      };
      misc = {
        singleClickActivate = false;
        menusHaveIcons = true;
        shortcutsForContextMenus = true;
      };
    };
  };

  # ---- KDE / kdeglobals ----------------------------------------------------
  # KDE frameworks read colors from kdeglobals: point it at Dux's scheme.
  xdg.configFile."kdeglobals".source = config.lib.file.mkOutOfStoreSymlink duxColorScheme;

  # Fonts, icons and style for kdeglobals, as a lower-priority layer (Dux's
  # scheme has none, so KDE falls back to Noto Sans 10 + Breeze). Used by
  # flatpak KDE-runtime apps via XDG_CONFIG_DIRS (below). A real file, since
  # /nix isn't visible in the sandbox.
  home.activation.kdedefaults = writeFile {
    target = "${configHome}/kdedefaults/kdeglobals";
    always = true;
    source = (pkgs.formats.ini { }).generate "kdeglobals" (
      let
        sans = qfont t.fonts.sans.name t.fonts.size;
      in
      {
        General = {
          font = sans;
          menuFont = sans;
          toolBarFont = sans;
          smallestReadableFont = qfont t.fonts.sans.name t.fonts.smallSize;
          fixed = qfont t.fonts.mono.name t.fonts.size;
        };
        Icons.Theme = t.icons.name;
        KDE.widgetStyle = t.qtStyle;
        WM.activeFont = sans;
      }
    );
  };

  # ---- Flatpak (global user override; applies to system flatpaks too) -----
  # - GTK: gtk.css from ~/.config/gtk-{3,4}.0, adw-gtk3 copy in
  #   ~/.local/share/themes (theme name comes via the settings portal).
  # - Qt: runtimes have no qtengine, so use KDE's platform theme, which reads
  #   kdeglobals: Dux colors + the kdedefaults layer above.
  xdg.dataFile."flatpak/overrides/global".source = (pkgs.formats.ini { }).generate "flatpak-global" {
    Context.filesystems = lib.concatStringsSep ";" (
      [
        "xdg-config/gtk-3.0:ro"
        "xdg-config/gtk-4.0:ro"
        "xdg-config/kdeglobals:ro"
        "xdg-config/kdedefaults:ro"
        "xdg-data/themes:ro"
      ]
      ++ map (dir: "~/.icons/${dir}:ro") t.icons.dirs
    );
    Environment = {
      QT_QPA_PLATFORMTHEME = "kde";
      QT_QPA_PLATFORMTHEME_QT6 = "kde"; # host's qtengine value leaks in otherwise
      XDG_CONFIG_DIRS = "/app/etc/xdg:/etc/xdg:${configHome}/kdedefaults";
    };
  };
}
