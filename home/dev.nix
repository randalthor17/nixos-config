{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "randalthor17";
        email = "itsmehauhon@gmail.com";
      };
    };
  };

  # Per-project toolchains: a flake devShell + `.envrc` with `use flake`, loaded
  # on cd. nix-direnv caches the shell and keeps it from being GC'd.
  # New C/C++ project: `nix flake init -t ~/nixos-config#c && direnv allow`.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };

  home.packages = with pkgs; [
    # Nix (for editing this config)
    treefmt
    nixfmt
    statix
    nil

    # C/C++ toolchains (gcc, gdb, make, cmake, pkg-config, clang-tools) live in
    # project dev shells now: there pkg-config finds the shell's libraries.
  ];
}
