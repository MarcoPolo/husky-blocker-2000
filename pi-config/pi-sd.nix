{ pkgs, modulesPath, ... }:
{
  # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];
  # boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelPackages = pkgs.linuxPackages;
}

