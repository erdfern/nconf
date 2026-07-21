references
- https://github.com/nilla-nix/nilla
- https://github.com/arnarg/nilla-utils
- https://github.com/arnarg/config
- https://github.com/jakehamilton/config

# Commands

Enter the dev shell (`nilla shell`, or `direnv allow` once for auto-load) to get:

- `install <host> [user@target]` — provision a host (local or remote)
- `deploy  <host> [user@target]` — rebuild & switch an installed host
- `wake    <host|mac>` — send a Wake-on-LAN magic packet
- `build-installer` — build the self-contained installer ISO
- the `nilla` CLI (`nilla os ...`, `nilla home ...`) for manual use

Hosts live in [`hosts/`](hosts); each is `systems.nixos.<host>` (+ `systems.home.<user>@<host>`).

# Install

One command, two transports. Both **erase and reformat** the target's disks.

```
install <host> [user@target] [--project <path>] [--ref <git-ref>] [--facter] [--yes] [-- extra args]
```

- **No target** → local on-device install: run it on the booted installer ISO; `disko`
  formats *this* machine, then `nixos-install`.
- **With a target** → remote install via [nixos-anywhere](https://github.com/nix-community/nixos-anywhere):
  the closure is built on *your* machine and copied to the target over SSH.

Nilla is not a flake, so under the hood we just build the two store paths the install needs:

```sh
nix-build nilla.nix \
  -A systems.nixos.<host>.result.config.system.build.diskoScript \
  -A systems.nixos.<host>.result.config.system.build.toplevel
```

`install` does this for you, picks the transport, and confirms before wiping (`--yes` to skip).

**Where the config comes from** (project resolution, first match wins): `--project <path>` →
`--ref <git-ref>` (fetched from `github:erdfern/config`) → `$NCONF_PROJECT` → `/etc/nconf`
(baked into the installer ISO) → the current git repo → `.`.

### New machine on your LAN (or in hand) — the self-contained way

1. Build the installer ISO and flash it:
   ```sh
   build-installer   # prints the built ISO path
   sudo dd if=<that>.iso of=/dev/sdX bs=4M status=progress conv=fsync
   ```
   The ISO bundles the whole config at `/etc/nconf`, the `install`/`deploy` commands, sshd with
   `me.ssh.pubKeys` authorized, security-key tooling (pcscd, yubikey/nitrokey), and the
   `kor.cachix.org` substituter.
2. Boot the target from the USB.
3. **On the target itself** — no repo clone needed:
   ```sh
   install <host>
   ```
   `disko` formats the disk, the writable Nix store is moved onto the fresh disk (so the system
   closure substitutes/builds on disk instead of the RAM-backed live store), then `nixos-install`.

   To install a newer config than the one baked in: `install <host> --ref main`.

### Remote machine (Hetzner, VPS, …)

Get the target into a NixOS installer / rescue / kexec environment reachable over SSH, then run
from this repo on your own machine:

```sh
install <host> root@<ip>
```

Official kexec installer, if the host only offers a non-NixOS rescue system:

```sh
curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run
```

### Brand-new hardware (no hardware profile yet)

Capture a hardware profile from the booted target, commit it, then install. For facter hosts:

```sh
install <host> root@<ip> --facter   # writes hosts/<host>/facter.json, then stops
git add hosts/<host>/facter.json && git commit -m "<host>: facter"
install <host> root@<ip>
```

For `hardware-configuration.nix` hosts:

```sh
ssh root@<ip> nixos-generate-config --no-filesystems --show-hardware-config > hosts/<host>/hardware-configuration.nix
install <host> root@<ip>
```

Hosts bake `users.users.*.initialHashedPassword`/`hashedPasswordFile`, so first login works
without a `mkpasswd` step.

> Why local installs no longer run out of space: the live ISO's `/nix/store` is a RAM-backed
> tmpfs overlay (~50% of RAM), far too small for a desktop closure. `install` never realizes the
> closure there — after `disko` it runs `nixos-install --file … --attr …`, which builds with
> `--store /mnt`, so the whole closure is built/substituted straight onto the target disk
> (pulling from `kor.cachix.org` and the installer's own store).

> Secrets (sops/age) are **not** provisioned during install. A new host's age identity is derived
> from its SSH host key (generated on first boot), so after first boot add the host's key to
> [`.sops.yaml`](.sops.yaml), re-encrypt `secrets/`, then `deploy`.

# Manage (day 2)

```sh
deploy <host>              # rebuild + switch NixOS and home-manager locally
deploy <host> root@<ip>    # ... over SSH (nilla os/home switch --target)
```

Wake a powered-off host over the LAN (needs `networking.interfaces.<if>.wakeOnLan`
on the target, its BIOS WoL/ErP settings, and its MAC recorded in [wol.nix](wol.nix)):

```sh
wake kor                  # look kor's MAC up in wol.nix and broadcast the magic packet
wake d8:bb:c1:12:34:56    # ... or target a MAC directly
wake --list               # show known hosts
```

Whole-fleet / tag-based deploys go through Colmena (see [hive.nix](hive.nix)):

```sh
colmena apply --on @<tag>   # e.g. @laptop, @workstation
```

CI ([`.github/workflows/build.yml`](.github/workflows/build.yml)) builds every host + the installer
ISO and pushes to `kor.cachix.org`, so installs and deploys substitute instead of building.
