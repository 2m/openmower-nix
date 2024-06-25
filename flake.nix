{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    deploy-rs.url = "github:serokell/deploy-rs";
  };
  outputs = { self, nixpkgs, nixos-hardware, deploy-rs }: rec {
    images = {
      openmower = (self.nixosConfigurations.openmower.extendModules {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          {
            disabledModules = [ "profiles/base.nix" ];
          }
        ];
      }).config.system.build.sdImage;
    };
    packages.x86_64-linux.pi-image = images.openmower;
    packages.aarch64-linux.pi-image = images.openmower;
    nixosConfigurations = {
      openmower = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./configuration.nix
          ./base.nix
        ];
      };
    };

    deploy.nodes.openmower = {
      # this is how it ssh's into the target system to send packages/configs over
      sshUser = "openmower";
      hostname = "openmower.local";
      confirmTimeout = 300; # wait a bit longer for larger updates

      sshOpts = [ "-oControlMaster=no" ];

      profiles.openmower = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations.openmower;
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}

