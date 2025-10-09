{ lib
, config
, pkgs
, me
, ...
}:
let
  inherit (me) user;

  gui = config.kor.preset.desktop.enable;
  yubikey = {
    # packages = with pkgs; [ yubikey-personalization-gui yubikey-personalization yubioath-flutter ];
    packages = with pkgs; [
      yubikey-manager
      age-plugin-yubikey
    ] ++ lib.lists.optional gui pkgs.yubioath-flutter;
    # pubKeys = [ ];
  };
  nitrokey = {
    packages = with pkgs; [
      # pynitrokey
      age-plugin-fido2-hmac
    ] ++ lib.lists.optional gui pkgs.nitrokey-app2;
    # pubKeys = [ ];
  };

  cfg = config.kor.hardware.sk;
in
{
  options.kor.hardware.sk = {
    enable = lib.mkOption {
      default = cfg.yubikey.enable || cfg.nitrokey.enable;
      readOnly = true;
    };
    piv.enable = lib.mkEnableOption "smartcard functionality";
    yubikey.enable = lib.mkEnableOption "yubikey support";
    # yubikey.luks = 
    nitrokey.enable = lib.mkEnableOption "nitrokey support";
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = lib.mkIf cfg.yubikey.enable [ pkgs.yubikey-personalization ];
    hardware.nitrokey.enable = lib.mkIf cfg.nitrokey.enable true; # it's just adding it to udev.packages, too. but yay, option

    environment.systemPackages = [ ] ++ (lib.lists.optionals cfg.yubikey.enable yubikey.packages) ++ (lib.lists.optionals cfg.nitrokey.enable nitrokey.packages);

    programs = {
      ssh.startAgent = lib.mkForce false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    # NOTE https://ludovicrousseau.blogspot.com/2019/06/gnupg-and-pcsc-conflicts.html
    services.pcscd.enable = lib.mkIf cfg.piv.enable true;
  };
}
