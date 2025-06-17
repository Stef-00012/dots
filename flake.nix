{
    description = "Base NixOS Config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        #astal = {
        #    url = "github:aylur/astal";
        #    inputs.nixpkgs.follows = "nixpkgs";
        #};
        ags = {
            url = "github:aylur/ags";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, ... } @ inputs:
    let
        system = "x86_64-linux";
        username = "stef";

        pkgs = import nixpkgs {
            inherit system;

            config = {
                allowUnfree = true;
            };
        };

    in
    {
        nixosConfigurations = {
            main = nixpkgs.lib.nixosSystem {
                specialArgs = {
                    inherit system;
                    inherit inputs;
                };

                modules = [
                    ./nixos/configuration.nix
                    inputs.home-manager.nixosModules.default
                    # {
                    #     home-manager = {
                    #         extraSpecialArgs = {
                    #             inherit system;
                    #             inherit inputs;
                    #         };
                    #         users.${username} = import ./homes/${username}/home.nix;
                    #     };
                    # }
                ];
            };
        };
    };
}