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

    # enable cross compilation
    echo "extra-platforms = aarch64-linux armv7l-linux i686-linux" | sudo tee -a /etc/nix/nix.conf
    echo "extra-sandbox-paths = /usr/bin/qemu-aarch64-static /usr/bin/qemu-aarch64-static /usr/bin/qemu-arm-static" | sudo tee -a /etc/nix/nix.conf

    sudo systemctl restart nix-daemon

deploy:
    nix run github:serokell/deploy-rs

build-image:
    nix build .#images.openmower

flash target:
    zstdcat result/sd-image/nixos-sd-image-* | \
      sudo dd of={{target}} bs=8M conv=fsync status=progress

run:
    nixos-shell --flake .#openmower

repl:
    nix repl ".#nixosConfigurations.openmower"
