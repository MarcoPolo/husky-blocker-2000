{ pkgs, ... }: {
  system.stateVersion = "22.05";
  imports = [ ./pi-sd.nix ];

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [ vim fish uhubctl htop bluez ];

  # TODO 
  # Enable usb perms

  users.users.marco = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
    createHome = true;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = import ./authorized-keys.nix;
  };

  networking = {
    firewall.enable = false;

    wireless = {
      enable = true;
      networks = (import ../secret.nix).wifi;
    };
  };

  # services.create_ap = {
  #   enable = true;
  #   settings = {
  #     INTERNET_IFACE = "eth0";
  #     WIFI_IFACE = "wlan0";
  #     SSID = "husky blocker 2000";
  #     PASSPHRASE = "noding to see here";
  #   };
  # };

  hardware.bluetooth.enable = true;

  programs = {
    fish.enable = true;
  };

  services = {
    openssh = {
      enable = true;
    };
  };

  boot.kernelParams = pkgs.lib.mkForce [ "console=ttyS0,115200n8" "console=tty0" ];
}
