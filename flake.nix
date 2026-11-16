{
  description = "NixOS + niri + Dux Shell (home-manager)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim.url = "github:pfassina/lazyvim-nix";

    # Zen browser (not in nixpkgs); home-manager module in home/zen.nix.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Declarative flatpaks (qBittorrent), see modules/nixos/services.nix.
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Battery + keyboard backlight for the MK75 keyboard and ATK VXE R1 NK mouse.
    hid-hwre = {
      url = "github:randalthor17/hw-re-upower-kernel-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Qt platform theme (KDE color-scheme based), see modules/nixos/desktop.nix.
    qtengine = {
      url = "github:kossLAN/qtengine";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim colorschemes (also what Dux Shell's neovim template targets).
    base46 = {
      url = "github:duxlabs-dev/base46";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # The attribute name must match networking.hostName (hosts/nixos).
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager
          nix-flatpak.nixosModules.nix-flatpak
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users."rand" = import ./home;
            };
          }
        ];
      };

      # Project templates: `nix flake init -t ~/nixos-config#c && direnv allow`
      templates.c = {
        path = ./templates/c;
        description = "C/C++ dev shell (make, cmake, meson, autotools, gdb, valgrind, clangd) with direnv";
      };

      # Local AI tooling: `nix develop`.
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            opencode
            ollama-rocm
            nixfmt
            statix
            deadnix
          ];

          shellHook = ''
            export OLLAMA_CONTEXT_LENGTH=65536
            export HSA_OVERRIDE_GFX_VERSION=11.0.0
          '';
        };
      });
    };
}
