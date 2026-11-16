{ pkgs, ... }:

{
  # The one place to change fonts / icons / cursor / Qt style.
  # Options: modules/nixos/theme.nix. Colors come from Dux Shell.
  theme = {
    fonts = {
      sans = {
        name = "Google Sans Flex";
        package = pkgs.callPackage ../../pkgs/google-sans-flex.nix { };
      };
      mono = {
        name = "GoogleSansCode Nerd Font";
        package = pkgs.nerd-fonts.googlesanscode;
      };
      size = 12;
    };

    icons = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
      dirs = [
        "Papirus" # Papirus-Dark links into it
        "Papirus-Dark"
      ];
    };

    cursor = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    qtStyle = "Fusion";
  };
}
