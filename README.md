### Using

After installing Nix from [nix-installer], run `just prepare` to install nix LSP for editor support and nix formmater.

Then run `just build-image` to build RPi SD card image that contains OpenMower setup.

For MacOS users, prepend `just` command with `./inside-docker.sh`, like `./inside-docker.sh just build-image`.

Install `jnoortheen.nix-ide` VSCode extension for Nix language support.

[nix-installer]: https://github.com/DeterminateSystems/nix-installer

### Update RPi EEPROM

If the built image does not boot with error before Linux kernel startup, you might need to update the RPi EEPROM.

First build SD card image with older kernel by changing kernel defition in [base.nix] to `linuxPackages_6_0`. After flashing the image run the following commands on the RPi:

```
sudo nixos-rebuild switch --flake .
nix-shell -p raspberrypi-eeprom
sudo mkdir /mnt
sudo mount /dev/disk/by-label/FIRMWARE /mnt
BOOTFS=/mnt FIRMWARE_RELEASE_STATUS=stable rpi-eeprom-update -d -a
```

[base.nix]: ./base.nix
