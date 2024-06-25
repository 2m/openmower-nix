{ pkgs, lib, config, ... }:
{
  options.settings = {
    wifiSsid = lib.mkOption {
      type = lib.types.str;
      description = "WiFi SSID for the OpenMower to connect to";
      default = throw "Please set wifiSsid in settings.nix";
    };
    wifiPsk = lib.mkOption {
      type = lib.types.str;
      description = "WiFi password for the OpenMower to connect to";
      default = throw "Please set wifiPsk in settings.nix";
    };
  };

  config = {
    networking.hostName = "openmower";

    systemd.network.wait-online.enable = false;
    systemd.services.NetworkManager-connection-up = {
      script = ''
        ${pkgs.networkmanager}/bin/nmcli connection up Stepoffice
      '';
      wantedBy = [ "multi-user.target" ];
      after = [ "NetworkManager-ensure-profiles.service" ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
      };
    };

    networking = {
      networkmanager = {
        enable = true;
        wifi = {
          backend = "iwd";
          powersave = false;
          scanRandMacAddress = false;
        };
        ensureProfiles.profiles."${config.settings.wifiSsid}" = {
          connection = {
            id = config.settings.wifiSsid;
            type = "802-11-wireless";
            interface-name = "wlan0";
          };
          "802-11-wireless".ssid = config.settings.wifiSsid;
          "802-11-wireless-security" = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = config.settings.wifiPsk;
          };
        };
      };
    };

    # publish <hostname>.local name
    services.avahi = {
      nssmdns4 = true;
      enable = true;
      ipv4 = true;
      ipv6 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    # resolve mDNS names
    services.resolved = {
      enable = true;
      fallbackDns = [
        "8.8.8.8"
      ];
    };
  };
}
