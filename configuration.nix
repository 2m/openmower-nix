{ pkgs, ... }:
{
  imports = [ ./settings.nix ];

  system.stateVersion = "24.05";

  # needed for deploy-rs
  # https://artemis.sh/2023/06/06/cross-compile-nixos-for-great-good.html
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  environment.systemPackages = with pkgs; [ vim git ];

  services.openssh.enable = true;
}
