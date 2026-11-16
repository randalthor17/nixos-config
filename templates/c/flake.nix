{
  description = "C/C++ project";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
          system: f nixpkgs.legacyPackages.${system}
        );
    in
    {
      devShells = forAllSystems (pkgs: {
        # mkShell brings the C compiler (stdenv); pkg-config's setup hook puts
        # every buildInputs library on PKG_CONFIG_PATH.
        default = pkgs.mkShell {
          # Delete what a project doesn't use.
          nativeBuildInputs = with pkgs; [
            # Build systems
            pkg-config
            gnumake
            cmake
            meson
            ninja
            autoconf
            automake
            libtool
            bear # compile_commands.json for make projects (clangd)

            # Debug / analysis
            gdb
            valgrind
            strace
            ltrace

            # Editor / lint
            clang-tools # clangd, clang-format, clang-tidy
            cppcheck
          ];
          buildInputs = with pkgs; [
            # libraries, e.g. curl (libcurl)
          ];
        };
      });
    };
}
