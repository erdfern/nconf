{ lib
, config
, ...
}:
let
  cfg = config.kor.profiles.server;
in
{
  options.kor.profiles.server = with lib; {
    enable = mkEnableOption "server profile";
  };

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;

    time.timeZone = lib.mkForce "utc";

    # kor.system.impermanence.root.extraDirectories = [ "/etc/ssh" ];
    # kor.system.impermanence.root.extraFiles = [
    #   "/etc/ssh/ssh_host_rsa_key"
    #   "/etc/ssh/ssh_host_rsa_key.pub"
    #   "/etc/ssh/ssh_host_ed25519_key"
    #   "/etc/ssh/ssh_host_ed25519_key.pub"
    #   "/etc/ssh/ssh_host_ed25519_key"
    #   "/etc/ssh/ssh_host_ed25519_key.pub"
    # ];
  };
}
