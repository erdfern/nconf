#!/usr/bin/env sh
nix build -f nilla.nix systems.nixos.dns.result.config.formats.sd-aarch64

# then cp compressed img, unzstd and write/dd to sd card..
