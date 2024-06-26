set dotenv-load

prepare:
    # install nix from
    # https://github.com/DeterminateSystems/nix-installer

    # install nix language server
    nix profile install nixpkgs#nixd

    # install formatter
    nix profile install nixpkgs#nixpkgs-fmt

    # install nixos-shell
    nix profile install nixpkgs#nixos-shell

    # enable cross compilation on x86 linux
    echo "extra-platforms = aarch64-linux armv7l-linux i686-linux" | sudo tee -a /etc/nix/nix.conf
    echo "extra-sandbox-paths = /usr/bin/qemu-aarch64-static /usr/bin/qemu-aarch64-static /usr/bin/qemu-arm-static" | sudo tee -a /etc/nix/nix.conf

    sudo systemctl restart nix-daemon

    # on macos prepend ./inside-docker.sh before every just command
    # this will use docker for running nix that will use rosetta for cross compilation

deploy:
    nix run github:serokell/deploy-rs

build-image:
    nix build .#images.openmower

flash target:
    zstdcat result*/sd-image/nixos-sd-image-* | \
        sudo dd of={{target}} bs=8M conv=fsync status=progress

flash-macos target:
    diskutil unmountDisk {{target}}
    zstdcat result-from-docker/sd-image/nixos-sd-image-* | \
        sudo dd of={{target}} bs=8M conv=fsync status=progress

run:
    nixos-shell --flake .#openmower

repl:
    nix repl ".#nixosConfigurations.openmower"

image := `readlink -n result`
user := `whoami`

get-result:
    sudo docker cp nix-docker:{{image}} ./result-from-docker
    sudo chown -R {{user}} ./result-from-docker

