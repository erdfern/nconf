{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      input = {
        # xkb config from nixos doesn't seem to apply here, so it's duplicated
        kb_layout = "us,de";
        # shift+caps=caps,lshift+rshift=switch layout
        kb_options = "caps:escape_shifted_capslock,grp:shifts_toggle";

        follow_mouse = 2; # click on window to focus
        sensitivity = 0;
        accel_profile = "flat";

        float_switch_override_focus = 1;

        special_fallthrough = false;

        touchpad = {
          natural_scroll = "yes";
          disable_while_typing = true;
          drag_lock = false;
        };
        touchdevice = {
          enabled = true;
          # output = 
          # transform = -1;
        };
      };

      # device = {
      #   "synps/2-synaptics-touchpad" = {};
      # };

      gestures = {
        # workspace_swipe = true;
        # workspace_swipe_forever = true;
        # workspace_swipe_numbered = true;
      };
    };
  };
}
