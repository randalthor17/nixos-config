{
  config,
  lib,
  inputs,
  ...
}:

# Theme options: fonts, icons, cursor, Qt widget style. Values are set in
# hosts/nixos/theme.nix; this module installs them system-wide, and the user
# side (home/theming.nix, niri, neovim) reads them via `osConfig.theme`.
# Colors are not here: Dux Shell generates them (matugen) at run time.
let
  inherit (lib) mkOption types;
  cfg = config.theme;

  # name + package, plus any extra options
  named =
    description: extra:
    types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "${description} name, as apps refer to it.";
        };
        package = mkOption {
          type = types.package;
          description = "Package providing the ${lib.toLower description}.";
        };
      }
      // extra;
    };
in
{
  imports = [ inputs.qtengine.nixosModules.default ];

  options.theme = {
    fonts = {
      sans = mkOption {
        type = named "Font family" { };
        description = "UI font (also the fontconfig sans-serif and serif default).";
      };
      mono = mkOption {
        type = named "Font family" { };
        description = "Monospace font.";
      };
      size = mkOption {
        type = types.int;
        default = 12;
        description = "UI font size in points.";
      };
      smallSize = mkOption {
        type = types.int;
        default = cfg.fonts.size - 2;
        defaultText = lib.literalExpression "config.theme.fonts.size - 2";
        description = "Smallest readable font size in points.";
      };
    };

    icons = mkOption {
      type = named "Icon theme" {
        dirs = mkOption {
          type = types.listOf types.str;
          default = [ cfg.icons.name ];
          defaultText = lib.literalExpression "[ config.theme.icons.name ]";
          description = ''
            Theme dirs under share/icons to link into ~/.icons and expose to
            flatpak apps. Include any theme the main one inherits or links into.
          '';
        };
      };
    };

    cursor = mkOption {
      type = named "Cursor theme" {
        size = mkOption {
          type = types.int;
          default = 24;
        };
      };
    };

    qtStyle = mkOption {
      type = types.str;
      default = "Fusion";
      description = "Qt widget style (host apps via qtengine, flatpak KDE apps via kdeglobals).";
    };
  };

  config = {
    fonts.packages = [
      cfg.fonts.sans.package
      cfg.fonts.mono.package
    ];

    # Qt platform theme (Qt5 + Qt6): plugin + QT_QPA_PLATFORMTHEME=qtengine.
    # Its config is per user, seeded by home/theming.nix.
    programs.qtengine.enable = true;
  };
}
