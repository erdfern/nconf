{ lib
, config
, ...
}:
let
  cfg = config.kor.preset.server;
in
{
  options.kor.preset.server = with lib; {
    enable = mkEnableOption "server preset";
  };

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;

    time.timeZone = lib.mkForce "utc";

    kor.system.impermanence.root.extraDirectories = [ "/etc/ssh" ];
    kor.system.impermanence.root.extraFiles = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
}
