{ ... }:
let
  font = "Hack Nerd Font Mono";
in
{
  home.file.".face.icon".source = ./avatar.jpg;
  # home.file.".config/.avatar.jpg".source = ./avatar.jpg;
  # home.file.".config/.lock_background".source = ./gray0_ctp_on_line.png;

  catppuccin.hyprlock = {
    enable = true;
    useDefaultConfig = false; # config file has errors, idk. version mismatch? still works but yeah.
    # accent = "peach";
    # flavor = "mocha";
  };

  programs.hyprlock = {
    enable = true;

    # sourceFirst = true;
    # extraConfig = ''
    #   source=${catTheme}
    #   $accent = $maroon
    #   $accentAlpha = $maroonAlpha
    #   $font = JetBrainsMono Nerd Font
    # '';

    # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/
    settings = {
      # source = [ catTheme ];

      general = {
        grace = 5;
        fail_timeout = 500;
        hide_cursor = true;
        ignore_empty_input = true;
      };

      auth = {
        pam = {
          enabled = true;
          # module = "hyprlock";
          # fingerprint = {
          #   enabled = false;
          #   # ...
          # };
        };
      };

      background = [
        {
          path = "screenshot";
          color = "$base"; # fallback

          blur_passes = 3;
          blur_size = 7;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      # shape = [
      #   { }
      # ];

      image = [
        {
          # monitor =
          # path = "$HOME/.avatar.jpg";
          # path = toString ./avatar.jpg;
          path = "${./avatar.jpg}";
          size = 100;
          border_size = 2;
          border_color = "$accent";
          position = "0,75";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          # TIME
          text = ''cmd[update:10000] echo "<span font_weight='bold'>$(date +"%R")</span>"'';
          color = "$text";
          # color = "$accent";
          font_size = 94;
          font_family = font;
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        {
          # DATE 
          # text = "cmd[update:43200000] echo \"$(date +\"%A, %d %B %Y\")\"";
          # text = ''cmd[update:900000] echo "<span font_weight='light'>$(date +"%d %B %Y")</span>"'';
          text = ''cmd[update:900000] echo "<span font_weight='light'>$(date +"%d. %b")</span>"'';
          color = "$subtext0";
          # color = "$sky";
          # font_size = 25;
          font_size = 58;
          font_family = font;
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];

      input-field = [{
        # monitor = "";
        size = "300, 60";
        outline_thickness = 4;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "$accent";
        inner_color = "$surface0";
        font_color = "$text";
        fade_on_empty = true;
        # face_timeout = 5000 # fade?
        placeholder_text = ''
          <span foreground="##$textAlpha"><i>󰌾 Logged in as </i><span foreground="##$accentAlpha">$USER</span></span>
        '';
        hide_input = false;
        check_color = "$accent";
        fail_color = "$red";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "$yellow";
        position = "0, -47";
        halign = "center";
        valign = "center";
      }];
    };
  };
}


