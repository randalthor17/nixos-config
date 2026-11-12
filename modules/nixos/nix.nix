{ ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  # nh: nicer rebuilds (`nh os switch`); knows the flake path, so no --flake needed.
  # GC stays with nix.gc below (programs.nh.clean would conflict with it).
  programs.nh = {
    enable = true;
    flake = "/home/rand/nixos-config";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  nixpkgs.config = {
    allowUnfree = true;
    problems.handlers = {
      "gtk+".broken = "warn"; # or "ignore"
    };
  };
}
