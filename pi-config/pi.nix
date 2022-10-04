{ pkgs, ... }: {
  system.stateVersion = "22.05";
  imports = [ ./pi-sd.nix ];

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [ vim fish uhubctl htop ];

  # TODO 
  # Enable usb perms

  users.users.marco = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
    createHome = true;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = import ./authorized-keys.nix;
  };

  networking.wireless = {
    enable = true;
    networks = (import ../secret.nix).wifi;
  };

  programs = {
    fish.enable = true;
  };

  services = {
    openssh = {
      enable = true;
    };
  };
}
