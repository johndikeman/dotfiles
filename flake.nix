{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/hyprland?ref=v0.55.4";
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    llama-gemma.url = "git+ssh://git@github.com/johndikeman/experiments.git?ref=llama-gemma";
    helium = {
      url = "github:amaanq/helium-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wallpapers.url = "github:johndikeman/wallpapers";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      lanzaboote,
      rose-pine-hyprcursor,
      helium,
      ...
    }@inputs:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          rose-pine-hyprcursor = rose-pine-hyprcursor.packages.${system}.default;
          helium = inputs.helium.packages.${system}.default;
          xdg-desktop-portal-hyprland = inputs.hyprland.inputs.xdph;
        };
        modules = [
          lanzaboote.nixosModules.lanzaboote
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };

            home-manager.users.john = {
              imports = [ ./home.nix ];
            };
            home-manager.users.jess = {
              imports = [ ./jess-home.nix ];
            };
          }
        ];
      };
    };
}
