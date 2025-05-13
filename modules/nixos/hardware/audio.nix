{ lib
, config
, pkgs
, user
, ...
}:
let
  cfg = config.kor.hardware.audio;
in
{
  # uh... this might not be idiomatic
  imports = lib.optionals (lib.versionAtLeast lib.version "25.05pre-git") [
    { services.pulseaudio.enable = lib.mkForce false; }
  ];

  options.kor.hardware.audio = {
    enable = lib.mkEnableOption "audio support";
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;

      wireplumber.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pulsemixer
      pavucontrol
      qjackctl
      easyeffects
    ];

    users.users.${user}.extraGroups = lib.singleton "audio";
  };
}
