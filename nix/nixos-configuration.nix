{
  self,
  flake-utils,
  nixpkgs,
  lix-module,
  home-manager,
  nur,
  ...
}:

flake-utils.lib.eachDefaultSystemPassThrough (
  system:
  let
    inherit ((import ../configurations/user.nix).user) username;
    pkgs = nixpkgs.legacyPackages.${system};
    args = import ../my-args.nix { inherit (pkgs) lib; } // {
      inherit system;
    };
  in
  {
    nixosConfigurations = {
      "${username}" = nixpkgs.lib.nixosSystem {
        modules = [
          {
            nixpkgs.overlays = [
              nur.overlays.default
              (final: prev: {
                brandishcode = self.packages.${system};
              })
            ];
          }
          lix-module.nixosModules.default
          { _module.args = args; }
          home-manager.nixosModules.home-manager
          ../options
          ../configurations
          ../system
          ../desktop-environment
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = args;
            home-manager.users.${username} = {
              home.stateVersion = "24.11";
              imports = [
                ./home-manager
              ];
            };
          }
        ];
      };
    };
  }
)
