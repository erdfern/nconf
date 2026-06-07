# build-installer
#
# Build the custom installer ISO (systems.nixos.installer): a minimal NixOS live
# image with sshd enabled and my SSH keys authorized, so a freshly-booted machine
# can be installed with `install <host> root@<ip>` from another machine.

# TODO update installer flake inputs when building or use npins inputs! npins inputs would be preferred for sync

out="$(nix-build nilla.nix \
  -A systems.nixos.installer.result.config.system.build.isoImage \
  --no-out-link)"

echo ">> Installer ISO built:" >&2
ls -lh "$out/iso/"*.iso
