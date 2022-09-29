{
  description = "A very basic flake";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-22.05";

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { system = system; };
        in
        {
          packages.hello = pkgs.hello;
          defaultPackage = self.packages.${system}.hello;
          devShell = pkgs.mkShell {
            buildInputs = [ pkgs.hello ];
          };
        })) //
    {
      nixosConfigurations = {
        # GC_DONT_GC=1 nix build .#nixosConfigurations.pi4SD.config.system.build.sdImage  
        pi4SD = nixpkgs.lib.nixosSystem
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
                  # the installation media is also the installation target,
                  # so we don't want to provide the installation configuration.nix.
                  installer.cloneConfig = false;
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
                  # openssh.authorizedKeys.keys = import ./common/authorizedKeys.nix;
                };
              })
            ];
          };
      };
    };
}
