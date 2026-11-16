{ pkgs, ... }:

let
  khipro = pkgs.callPackage ../pkgs/khipro-dark-m17n.nix { };
in
{
  # fcitx5 (user service, started with the session) with m17n's input methods.
  # Wayland frontend: apps talk to it over text-input, no GTK/QT_IM_MODULE.
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = [ pkgs.fcitx5-m17n ];

      # Group: English (US) + Khipro Dark. Owned here, so fcitx5's own
      # settings UI can't change it (edit this instead).
      settings.inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "m17n_bn_khipro-dark";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "m17n_bn_khipro-dark";
      };
    };
  };
  # HM links ~/.config/fcitx5 as one store dir; link only its files instead, so
  # fcitx5 can still write the rest (addon confs). force: replace the profile
  # fcitx5 wrote before (it listed the old m17n_bn_khipro, since renamed).
  xdg.configFile.fcitx5 = {
    recursive = true;
    force = true;
  };

  # Khipro Dark: m17n reads user input methods from ~/.m17n.d
  home.file.".m17n.d/bn-khipro-dark.mim".source = "${khipro}/share/m17n/bn-khipro-dark.mim";
  home.file.".m17n.d/icons/bn-khipro-dark.png".source =
    "${khipro}/share/m17n/icons/bn-khipro-dark.png";
}
