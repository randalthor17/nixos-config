{ pkgs, ... }:

{
  # System-wide fonts. Per-user fontconfig rules are in home/theming.nix.
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.googlesanscode
      (callPackage ../../pkgs/google-sans-flex.nix { })
    ];
  };
}
