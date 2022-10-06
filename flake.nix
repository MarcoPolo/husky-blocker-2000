{
  description = "A very basic flake";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # From a older release-22.05
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
  inputs.nixpkgsDarwin.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";

  outputs = { self, nixpkgs, nixpkgsDarwin, flake-utils }:
    (flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs =
            import (if (builtins.elemAt (builtins.split "-" system) 2) == "darwin" then nixpkgsDarwin else nixpkgs)
              {
                system = system;
              };
        in
        {
          defaultPackage = pkgs.hello;
          devShell = pkgs.mkShell {
            buildInputs = [ pkgs.zstd pkgs.git-crypt pkgs.colmena pkgs.go_1_18 ];
          };
        })) //
    # Deployment
    ({
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "aarch64-linux";
          };
        };

        pi = {
          deployment = {
            targetHost = "192.168.195.120";
          };
          time.timeZone = "America/Los_Angeles";
          imports = [ ./pi-config/pi.nix ];
        };
      };
    }) //
    ({
      nixosConfigurations = {
        # nix build .#nixosConfigurations.pi.config.system.build.sdImage  
        pi = nixpkgs.lib.nixosSystem
          {
            system = "aarch64-linux";
            modules = [ ./pi-config/pi.nix ];
          };
      };
    });
}
