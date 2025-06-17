{
    description = "Base NixOS Config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

        ags = {
            url = "github:aylur/ags";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland = {
            url = "github:hyprwm/Hyprland";
            inputs.nixpkgs.follows = "nixpkgs-small";
        };

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs-small";
        };
    };

    outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
        system = "x86_64-linux";
        username = "stef";
        host = "nixos";

        nixosMachine =  { host }:
            nixpkgs.lib.nixosSystem {
                specialArgs = {
                    inherit
                        inputs
                        system
                        host
                        username
                        ;
                };
                modules = [
                    ./hosts/${host}/config.nix
                    home-manager.nixosModules.home-manager
                    {
                        home-manager = {
                            extraSpecialArgs = {
                                inherit
                                    inputs
                                    system
                                    host
                                    username
                                    ;
                                };
                            useUserPackages = true;
                            useGlobalPkgs = true;
                            backupFileExtension = "backup";
                            users.${username} = import ./hosts/${host}/home.nix;
                        };
                    }
                ];
            };

    in
    {
        nixosConfigurations = {
            nixos = nixosMachine { host = "nixos"; };
        };
    };
}