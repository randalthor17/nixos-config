{ pkgs, ... }:

{
  # System-wide fonts. The theme fonts are added by modules/nixos/theme.nix
  # (values in hosts/nixos/theme.nix); fontconfig defaults in home/theming.nix.
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];
  };
}
