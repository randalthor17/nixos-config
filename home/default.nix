{ ... }:

{
  # Home-manager entry point for rand. The desktop shell (Dux Shell) is
  # system-wide (modules/nixos/desktop.nix).
  imports = [
    ./shell.nix
    ./theming.nix
    ./niri.nix
    ./apps.nix
    ./dev.nix
    ./neovim.nix
  ];

  home.username = "rand";
  home.homeDirectory = "/home/rand";
  home.stateVersion = "26.05"; # match system.stateVersion
}
