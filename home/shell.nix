{ pkgs, ... }:

{
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    NIXOS_CONFIG = "/home/rand/nixos-config/flake.nix";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      # NH_FLAKE is set system-wide by programs.nh.flake (modules/nixos/nix.nix)
      nfmt = "treefmt -C \"$NH_FLAKE\"";
      rebuild = "nfmt && nh os switch";
      update = "nfmt && nh os switch --update";
    };
  };

  home.packages = with pkgs; [
    wl-clipboard
    ripgrep
    fd
    btop
    fastfetch
    ouch # archives: ouch compress / decompress
    unzip
    zip
    tree
  ];
}
