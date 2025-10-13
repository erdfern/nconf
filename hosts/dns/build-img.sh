#!/usr/bin/env sh
nix build -f nilla.nix systems.nixos.dns.result.config.formats.sd-aarch64 -o ./pisd

# then cp compressed img, unzstd and write/dd to sd card..
# cp ./pisd/*.zst .
# unzstd -d *.zst -o nixos-sd-image.img
# rm ./pisd
