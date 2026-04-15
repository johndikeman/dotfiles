{
  description = "Home Manager configuration of ubuntu";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dude.url = "git+ssh://git@github.com/johndikeman/dude.git?ref=main";
    dude-chess.url = "git+ssh://git@github.com/johndikeman/dude-chess.git?ref=add-checker-module";
  };

  outputs =
    { nixpkgs, home-manager, dude, dude-chess, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
    in
    {
      homeConfigurations."ubuntu" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ 
          ./home.nix
          dude.homeManagerModules.dude-agent
          dude-chess.homeManagerModules.dude-chess
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
