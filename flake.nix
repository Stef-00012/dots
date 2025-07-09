{
    description = "Base NixOS Config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

        astal = {
            url = "github:aylur/astal";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        ags = {
            url = "github:aylur/ags";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland = {
            url = "github:hyprwm/Hyprland";
            inputs.nixpkgs.follows = "nixpkgs-small";
        };

        hyprland-plugins = {
            url = "github:hyprwm/hyprland-plugins";
            inputs.hyprland.follows = "hyprland";
        };

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs-small";
        };

        spicetify-nix = {
            url = "github:Gerg-L/spicetify-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
        system = "x86_64-linux";
        username = "stef";
        group = "users";
        host = "nixos";

        nixosMachine =  { host }:
            nixpkgs.lib.nixosSystem {
                specialArgs = {
                    inherit
                        inputs
                        system
                        host
                        username
                        group
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
                                    group
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