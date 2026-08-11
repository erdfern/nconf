# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal NixOS + home-manager configuration for several hosts. Built on **Nilla**
(`nilla.create`), **not** flakes. Inputs are pinned with **npins**, systems/modules/packages
are produced by **nilla-utils generators**, and fleet rollouts go through **Colmena**.

## This is not a flake

Never use `nix flake ...`. The entrypoint is `nilla.nix`; `default.nix` and `shell.nix` are
thin shims that `import ./nilla.nix`. Evaluate/build against it explicitly:

```sh
nix repl                      # then  :l .          (loads nilla.nix)
nix eval -f nilla.nix <attr>
nix build -f nilla.nix <attr> # attrs below usually end in .result[.x86_64-linux]
```

The `.result` suffix is pervasive: Nilla inputs, systems, and packages expose their evaluated
value under `.result` (per-system ones under `.result.<system>`), e.g.
`config.inputs.nixpkgs.result.x86_64-linux`, `systems.nixos.kor.result.config`.

## Commands

Enter the dev shell first (`nilla shell`, or `direnv allow` once for nix-direnv auto-load). It
provides the `nilla` CLI plus the repo helper commands, all defined in the `commands` set in
[nilla.nix](nilla.nix) (bodies in [scripts/](scripts)):

```sh
install <host> [user@target]   # provision a host (local on-ISO, or remote via nixos-anywhere)
deploy  <host> [user@target]   # rebuild+switch: runs `nilla os switch` then `nilla home switch`
wake    <host|mac>             # send a Wake-on-LAN magic packet (inventory in wol.nix)
build-installer                # build the self-contained installer ISO
colmena apply --on @<tag>      # whole-fleet / tag-based rollout (tags live in hosts/*/default.nix)
```

Build things directly (this repo has **no test suite** — "does it work" means "does it build"):

```sh
nilla build <pkg>                                                        # a package from ./packages
nix build -f nilla.nix 'packages.<pkg>.result.x86_64-linux'             # same, explicit
nix build -f nilla.nix 'systems.nixos.<host>.result.config.system.build.toplevel'   # a host
nix build -f nilla.nix 'systems.home."<user>@<host>".result.activationPackage'      # a home config
nix build -f nilla.nix 'systems.nixos.installer.result.config.system.build.isoImage'
```

CI ([.github/workflows/build.yml](.github/workflows/build.yml)) builds every host + home config +
the installer ISO and pushes to the `kor.cachix.org` binary cache, so installs/deploys substitute
instead of rebuilding. It discovers hosts dynamically via
`builtins.attrNames systems.nixos` / `systems.home` — no hardcoded host list to maintain.

**Updating inputs:** `npins update` (all) or `npins update <name>` (one), then rebuild. The
`inputs.nix` layer reads `npins/` — do not hand-edit pinned revisions.

## Architecture

**`nilla.nix`** is the whole config. Its `let` block defines the helper `commands` (shared by the
dev shell *and* baked into the installer ISO at `/etc/nconf`), and `config` wires up the generators.

**`inputs.nix`** turns every npins pin into a Nilla input, assigning each a `loader`
(`"flake"` for flake-shaped inputs, `"raw"` for plain sources) and per-input `settings`. `nixpkgs`
is configured here with `allowUnfree = true` and the default overlay (see packages) + NUR.

**Generators do the folder→attribute mapping** — this is the key indirection to understand:

- `generators.nixos.folder = ./hosts` → each `hosts/<host>/` becomes `systems.nixos.<host>`.
- `generators.home.folder = ./hosts` → `systems.home."<user>@<host>"`. Home-manager runs
  **standalone** here (not the NixOS module — there are TODOs about switching).
- `generators.nixosModules.folder = ./modules/nixos` → `config.modules.nixos.<name>` (e.g. `core`).
- `generators.homeModules.folder = ./modules/home` → `config.modules.home.<name>` (e.g. `common`).
- `generators.packages.folder = ./packages` **and** `generators.overlays.default.folder = ./packages`
  → each `packages/<name>/default.nix` is both `packages.<name>` and an attr in the default overlay,
  so it's available as `pkgs.<name>` inside every system.

Every generated NixOS/home system automatically gets `config.modules.nixos.core` /
`config.modules.home.common` injected (plus catppuccin + disko), and `me` passed as a module arg.

**`me.nix`** is the single source of identity (`user`, `email`, `ssh.pubKeys`, `gpg`, `git`). It is
passed as the `me` argument into nixos/home modules and read by the shell scripts (e.g. deploy reads
`(import ./me.nix).user`). Change identity here, not in individual modules.

**Module composition.** `modules/nixos/core/default.nix` is an aggregate that imports
`system/`, `sops/`, `profiles/` (desktop/laptop/server/development), `hardware/`,
`virtualisation/`, etc. `modules/home/common/default.nix` does the same for the home side.
Custom options are namespaced under **`kor.*`** (the option prefix, unrelated to the host named
`kor`), e.g. `kor.system.boot.enable`, `kor.basic-utils`, `kor.ssh.enable`.

**Host layout.** `hosts/<host>/default.nix` sets `modules = [ ./configuration.nix ]` and a
`deployment` block (Colmena `targetUser`/`tags`). Two hardware styles coexist: **facter**
(`facter.json` from nixos-facter, used by `dedi`/`kor`) and classic
`hardware-configuration.nix`; disks are declared with **disko** (`disk-config.nix`). Hosts:
`kor` (desktop/workstation), `kor-t14` (laptop), `dedi` & `h1` (servers — atticd, gh-runner).

**Colmena.** `hive.nix` re-derives its node set from `nilla.nix`'s `systems.nixos`, merging each
node's `deployment` (from the host's `default.nix`) with any extra modules under
`project.hive.nodes.<name>`. The Colmena option schema lives in [modules/hive/](modules/hive).
Use Colmena for fleet/tag deploys; use `deploy` for a single host.

**Secrets.** sops-nix with age. `.sops.yaml` lists recipients; encrypted material lives in
`secrets/` and per-host `hosts/<host>/secrets`. A new host's age identity is derived from its SSH
host key (generated on first boot): after first boot, add the host key to `.sops.yaml`, re-encrypt
`secrets/`, then `deploy`. Secrets are **not** provisioned during `install`.

## Conventions

- **Adding a package:** create `packages/<name>/default.nix` as a `callPackage`-style function
  (args = its deps). It auto-registers as `packages.<name>` and `pkgs.<name>` — no wiring needed.
- **Adding a host:** create `hosts/<name>/` with a `default.nix` (`modules` + `deployment`) and a
  `configuration.nix`; the generator picks it up. Capture hardware first (see the facter /
  `hardware-configuration.nix` flows in [README.md](README.md)).
- **`config.lib.modules.never`** (from [lib/modules.nix](lib/modules.nix)) is the sentinel used as a
  no-op default for optional per-input loaders/settings in `inputs.nix`.
- Commit messages follow Conventional Commits (`fix(scope): …`); `--wip--` is used for checkpoints.
- See [README.md](README.md) for the full install/deploy transport details (on-ISO vs
  nixos-anywhere, project resolution order, why local installs no longer run out of disk space).
