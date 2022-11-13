# Build

```
❯ nix build .#nixosConfigurations.pi.config.system.build.sdImage  

❯ unzstd result/sd-image/nixos-sd-image-22.05.20220929.1b814a1-aarch64-linux.img.zst -o nixos.img

❯ sudo dd if=./nixos.img of=/dev/disk<number here> bs=4M status=progress
```


# Power on/off

First you need to use uhubctl:
```
sudo  uhubctl -l 2 -a 0 -e
sudo uhubctl -l 1-1 -p 2 -a 0 -e
```


poweroff:
```
echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind
```

poweron:
```
echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/bind
```

# Devlog

id: F9:B9:10:04:3C:C3


gatttool -t random -b F9:B9:10:04:3C:C3 --char-write-req --handle=0x0011 --value=0100 --listen