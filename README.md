# Build

```
❯ nix build .#nixosConfigurations.pi.config.system.build.sdImage  

❯ unzstd result/sd-image/nixos-sd-image-22.05.20220929.1b814a1-aarch64-linux.img.zst -o nixos.img

❯ sudo dd if=./nixos.img of=/dev/disk<number here> bs=4M status=progress
```


# Power on/off

```
echo '1-1' |sudo tee /sys/bus/usb/drivers/usb/unbind
```

```
echo '1-1' |sudo tee /sys/bus/usb/drivers/usb/bind
```