# Shim so `nix-shell` / nix-direnv can enter the Nilla default dev shell.
# The real definition lives in `shells.default` in ./nilla.nix.
(import ./nilla.nix).shells.default.result.${builtins.currentSystem}
