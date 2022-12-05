{
  description = "A very basic flake";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # From a older release-22.05
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
  inputs.nixpkgsDarwin.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";

  outputs = { self, nixpkgs, nixpkgsDarwin, flake-utils }@inputs:
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
          packages.husky-blocker = pkgs.buildGo118Module rec {
            src = ./simple-control-website;

            pname = "husky-blocker";
            version = "0.1.0";
            checkPhase = "";

            # postInstall = "";


            # Sha of go modules. To update uncomment the below line and comment
            # out the current sha. Then update the sha.
            # vendorSha256 = pkgs.lib.fakeSha256;
            vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";

            meta = with pkgs.lib; {
              description = "";
              homepage = "https://github.com/MarcoPolo/husky-blocker-2000";
              license = licenses.mit;
              maintainers = with maintainers; [ "marcopolo" ];
              platforms = platforms.linux ++ platforms.darwin;
            };
          };
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
            # targetHost = "192.168.12.1";
            targetHost = "192.168.195.120";
          };
          time.timeZone = "America/Los_Angeles";
          imports = [
            ./pi-config/pi.nix
            ({ ... }: {
              imports = [ self.outputs.nixosModules.huskyBlockerService ];
              services.husky-blocker.enable = true;
            })
          ];
        };
      };
    }) //
    ({
      nixosConfigurations = {
        # nix build .#nixosConfigurations.pi.config.system.build.sdImage  
        pi = nixpkgs.lib.nixosSystem
          {
            system = "aarch64-linux";
            modules = [
              ./pi-config/pi.nix
              ({ ... }: {
                imports = [ self.outputs.nixosModules.huskyBlockerService ];
                services.husky-blocker.enable = true;
              })
            ];
          };
      };

      nixosModules.huskyBlockerService = { config, pkgs, ... }:
        let
          nixpkgs = inputs.nixpkgs;
          lib = nixpkgs.lib;
          cfg = config.services.husky-blocker;
        in
        {
          options.services.husky-blocker = {
            enable = nixpkgs.lib.mkOption {
              description = "Enable";
              type = nixpkgs.lib.types.bool;
              default = false;
            };
          };
          config = {
            systemd.services = {
              husky-blocker = (lib.mkIf cfg.enable {
                description = "husky-blocker";
                wantedBy = [ "multi-user.target" ];
                after = [ "network.target" ];
                serviceConfig = {
                  Environment = "PATH=${pkgs.uhubctl}/bin:${pkgs.bash}/bin:$PATH";
                  ExecStart = "${self.packages.${pkgs.system}.husky-blocker}/bin/m";
                  Restart = "always";
                  RestartSec = "1min";
                  User = "root";
                };
              });
            };
          };
        };

    });
}
