#!/usr/bin/env bash
# https://discourse.nixos.org/t/build-x86-64-linux-on-aarch64-darwin/35937
set -euo pipefail

if ! command -v docker &> /dev/null
then
  echo "Please install docker first."
  exit 1
fi

if ! docker container inspect nix-docker > /dev/null 2>&1; then
  docker create --platform linux/amd64 --privileged --name nix-docker -it -w /work -v $(git rev-parse --show-toplevel):/work nixos/nix
  docker start nix-docker > /dev/null
  docker exec nix-docker bash -c "git config --global --add safe.directory /work"
  docker exec nix-docker bash -c "echo 'sandbox = true' >> /etc/nix/nix.conf"
  docker exec nix-docker bash -c "echo 'filter-syscalls = false' >> /etc/nix/nix.conf"
  docker exec nix-docker bash -c "echo 'max-jobs = auto' >> /etc/nix/nix.conf"
  docker exec nix-docker bash -c "echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf"

  # cross compile aarch64
  docker exec nix-docker bash -c "echo 'extra-platforms = aarch64-linux armv7l-linux i686-linux' >> /etc/nix/nix.conf"
  docker exec nix-docker bash -c "echo 'extra-sandbox-paths = /usr/bin/qemu-aarch64-static /usr/bin/qemu-aarch64-static /usr/bin/qemu-arm-static' >> /etc/nix/nix.conf"

  docker exec nix-docker bash -c "nix-env -iA nixpkgs.docker nixpkgs.jq nixpkgs.niv nixpkgs.just"
fi

docker start nix-docker > /dev/null
docker exec -it nix-docker "$@"
