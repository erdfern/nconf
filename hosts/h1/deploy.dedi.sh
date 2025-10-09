#!/usr/bin/env sh
# https://nix-community.github.io/nixos-anywhere/howtos/use-without-flakes.html
# nixos-anywhere --store-paths $(nix-build nilla.nix -A systems.nixos.dedi.result.config.system.build.formatScript -A systems.nixos.dedi.result.config.system.build.toplevel --no-out-link) dedi
#
 # --print-build-logs \
nixos-anywhere \
  -i /home/lk/.ssh/id_ed25519 \
  --debug \
  --store-paths $(nix-build nilla.nix -A systems.nixos.dedi.result.config.system.build.formatScript -A systems.nixos.dedi.result.config.system.build.toplevel --no-out-link) \
  dedi
