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
            buildInputs = [ pkgs.zstd pkgs.git-crypt ];
          };
        })) //
    (
      let secret = (import ./secret.nix); in {
        nixosConfigurations = {
          # nix build .#nixosConfigurations.pi.config.system.build.sdImage  
          pi = nixpkgs.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = [
                (
                  { pkgs, modulesPath, ... }:
                  {
                    #shttps://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
                    nixpkgs.overlays = [
                      (final: super: {
                        makeModulesClosure = x:
                          super.makeModulesClosure (x // { allowMissing = true; });
                      })
                    ];
                    imports = [
                      (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
                    ];
                    boot.kernelPackages = pkgs.linuxPackages_rpi4;
                  }
                )
                ({ pkgs, ... }: {
                  system.stateVersion = "22.05";

                  security.sudo.wheelNeedsPassword = false;

                  environment.systemPackages = with pkgs; [ vim fish ];

                  users.users.marco = {
                    isNormalUser = true;
                    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
                    createHome = true;
                    shell = pkgs.fish;
                    openssh.authorizedKeys.keys = import ./pi-config/authorized-keys.nix;
                  };

                  networking.wireless.networks = secret.wifi;

                  programs = {
                    fish.enable = true;
                  };

                  services = {
                    openssh = {
                      enable = true;
                    };
                  };
                })
              ];
            };
        };
      }
    );
}
