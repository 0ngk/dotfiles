{
  description = "rei's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
  }: let
    username = "rei";
    darwinSystem = "aarch64-darwin";
    alpineSystem = "x86_64-linux";
  in {
    darwinConfigurations.MacBookAir = nix-darwin.lib.darwinSystem {
      system = darwinSystem;
      specialArgs = {inherit inputs username;};
      modules = [
        ./hosts/darwin/MacBookAir.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = {inherit inputs username;};
          home-manager.users.${username} = {
            imports = [
              ./home/common.nix
              ./home/darwin.nix
            ];
          };
        }
      ];
    };

    homeConfigurations."${username}@alpine" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${alpineSystem};
      extraSpecialArgs = {inherit inputs username;};
      modules = [
        ./home/common.nix
        ./home/alpine.nix
      ];
    };
  };
}
