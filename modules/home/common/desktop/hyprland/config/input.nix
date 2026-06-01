{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      # Config categories live under `config` (-> hl.config({ input = { ... } }))
      config = {
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
            natural_scroll = true; # was "yes" (lua wants a real bool here)
            disable_while_typing = true;
            drag_lock = false;
          };
          touchdevice = {
            enabled = true;
            # output =
            # transform = -1;
          };
        };
      };

      # Per-device overrides are no longer a `device` config category; each
      # device is now its own hl.device(...) call:
      # device = [
      #   { name = "synps/2-synaptics-touchpad"; }
      # ];

      # Trackpad gestures are no longer a config category either; they are
      # individual hl.gesture(...) calls:
      # gesture = [
      #   { fingers = 3; direction = "horizontal"; action = "workspace"; }
      # ];
    };
  };
}

# { ... }:
# {
#   wayland.windowManager.hyprland = {
#     settings = {
#       input = {
#         # xkb config from nixos doesn't seem to apply here, so it's duplicated
#         kb_layout = "us,de";
#         # shift+caps=caps,lshift+rshift=switch layout
#         kb_options = "caps:escape_shifted_capslock,grp:shifts_toggle";

#         follow_mouse = 2; # click on window to focus
#         sensitivity = 0;
#         accel_profile = "flat";

#         float_switch_override_focus = 1;

#         special_fallthrough = false;

#         touchpad = {
#           natural_scroll = "yes";
#           disable_while_typing = true;
#           drag_lock = false;
#         };
#         touchdevice = {
#           enabled = true;
#           # output = 
#           # transform = -1;
#         };
#       };

#       # device = {
#       #   "synps/2-synaptics-touchpad" = {};
#       # };

#       gestures = {
#         # workspace_swipe = true;
#         # workspace_swipe_forever = true;
#         # workspace_swipe_numbered = true;
#       };
#     };
#   };
# }
