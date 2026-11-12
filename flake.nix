{
  description = "NixOS + niri + Dux Shell (home-manager)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim.url = "github:pfassina/lazyvim-nix";

    # Neovim colorschemes (also what Dux Shell's neovim template targets).
    base46 = {
      url = "github:duxlabs-dev/base46";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
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
