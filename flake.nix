{
  description = "Home Manager configuration of ubuntu";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dude.url = "github:johndikeman/dude";
    # dude2 coexists with dude1 (v1) on the same machine: separate branch, separate
    # config dir/state/token, distinct unit names. see dude2 branch flake.nix for
    # the module (services.dude2-agent). merge dude2 branch → dude2 branch input is
    # removed once dude2's flake.nix becomes the main flake.
    dude2.url = "github:johndikeman/dude/dude2";
    dude-prediction-markets.url = "github:johndikeman/dude-prediction-markets";
    deploy-rs = {
      url = "github:johndikeman/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      deploy-rs,
      dude,
      dude-prediction-markets,
      dude2,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations."ubuntu" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          dude.homeManagerModules.dude-agent
          dude-prediction-markets.homeManagerModules.prediction-markets
          dude2.homeManagerModules.dude2-agent
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };

      deploy.nodes.vps = {
        hostname = "vps";
        profiles.ubuntu = {
          user = "ubuntu";
          path = deploy-rs.lib.${system}.activate.home-manager self.homeConfigurations."ubuntu";
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
