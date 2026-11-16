{ lib, ... }:

{
  # Home-manager entry point for rand. The desktop shell (Dux Shell) is
  # system-wide (modules/nixos/desktop.nix).
  imports = [
    ./shell.nix
    ./theming.nix
    ./input.nix
    ./niri.nix
    ./apps.nix
    ./zen.nix
    ./kdeconnect.nix
    ./dev.nix
    ./neovim.nix
  ]
  # Optional: only when the launcher files are present in this repo.
  ++ lib.optional (builtins.pathExists ./matlab/matlab-env.nix) ./matlab.nix;

  home.username = "rand";
  home.homeDirectory = "/home/rand";
  home.stateVersion = "26.05"; # match system.stateVersion
}
