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

  home.packages = with pkgs; [
    # Nix
    treefmt
    nixfmt
    statix
    nil

    # C/C++ & systems
    gcc
    gdb
    gnumake
    cmake
    pkg-config
    clang-tools
  ];
}
