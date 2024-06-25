{ pkgs, lib, ... }:
{
  # This causes an overlay which causes a lot of rebuilding
  environment.noXlibs = lib.mkForce false;
  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };

  # Crashes boot
  # hardware.raspberry-pi."4" = {
  #   xhci.enable = true;
  #   bluetooth.enable = false;
  # };

  # Disable USB scatter
  # https://github.com/morrownr/7612u?tab=readme-ov-file#known-issues
  boot.extraModprobeConfig = ''
    options mt76_usb disable_usb_sg=1
  '';

  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [ "root" "@wheel" ];
  };
}
