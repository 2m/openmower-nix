{ lib, config, ... }:
{
  options.settings.authorizedKey = lib.mkOption {
    type = lib.types.str;
    description = "Authorized key for user openmower";
    example = "ssh-rsa AAAA...";
    default = throw "Please set authorizedKey in settings.nix";
  };

  config = {
    users = {
      users.openmower = {
        password = "openmower";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          config.settings.authorizedKey
        ];
      };
    };

    # enable 'sudo' without password
    security.sudo.extraRules = [
      {
        users = [ "openmower" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
