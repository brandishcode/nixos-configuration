{
  description = "Graphical nix configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:brandishcode/nixvim-configuration";
    nur.url = "github:nix-community/nur";
    clefru-nur.url = "github:clefru/nur-packages";
  };

  outputs =
    { nixpkgs, flake-utils, home-manager, nixvim, nur, clefru-nur, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nur.overlays.default ];
          config.allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [ "tokyo-night-v2" ];
        };
        nixvim' = {
          home.packages = [
            (nixvim.packages.${system}.default.extend {
              imports = [ nixvim.nixvim-configs.${system}.js ];
            })
          ];
        };
        options = import ./options-definition.nix;
        home-manager-options = {
          username = options.username;
          homeDirectory = "/home/${options.username}";
          stateVersion = "24.05";
        };
      in {
        packages = {
          homeConfigurations = {
            "${options.username}" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                {
                  home = with home-manager-options; {
                    inherit username;
                    inherit homeDirectory;
                    inherit stateVersion;
                  };
                }
                options
                ./options-declaration.nix
                ./home-manager
                nixvim'
              ];
            };
          };

          nixosConfigurations = {
            "${options.username}@${options.hostname}" =
              nixpkgs.lib.nixosSystem {
                inherit pkgs;
                modules = [
                  home-manager.nixosModules.home-manager
                  options
                  ./options-declaration.nix
                  ./options
                  ./system
                  ./desktop-environment
                  {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.extraSpecialArgs = {
                      inherit system;
                      inherit clefru-nur;
                    };
                    # home-manager setup
                    home-manager.users.${options.username} = {
                      home.stateVersion = home-manager-options.stateVersion;
                      imports = [
                        options
                        ./options-declaration.nix
                        ./configurations
                        ./home-manager
                        nixvim'
                        ./nurs
                      ];
                    };
                  }
                ];
              };
          };
        };
      });
}
