{ ... }:

{
  imports = [
    ./nix.nix
    ./boot.nix
    ./hardware.nix
    ./services.nix
    ./desktop.nix
    ./fonts.nix
    ./users.nix
  ];
}
