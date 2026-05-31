references
- https://github.com/nilla-nix/nilla
- https://github.com/arnarg/nilla-utils
- https://github.com/arnarg/config
- https://github.com/jakehamilton/config

# Commands

Enter the dev shell (`nilla shell`, or `direnv allow` once for auto-load) to get:

- `install <host> [user@target] [extra nixos-anywhere args...]` — provision a host
- `deploy  <host> [user@target] [extra nilla args...]` — rebuild & switch an installed host
- `build-installer` — build the custom installer ISO

Hosts live in [`hosts/`](hosts); each is `systems.nixos.<host>` (+ `systems.home.<user>@<host>`).

# Install

Fresh installs use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere). Nilla is not a
flake, so we feed it the two store paths it needs:

```sh
nix-build nilla.nix \
  -A systems.nixos.<host>.result.config.system.build.diskoScript \
  -A systems.nixos.<host>.result.config.system.build.toplevel
```

`install` does this for you.

### New machine on your LAN (or in hand)

1. Build the installer ISO and flash it to a USB stick:
   ```sh
   build-installer   # prints the built ISO path
   # then e.g.:  sudo dd if=<that>.iso of=/dev/sdX bs=4M status=progress conv=fsync
   ```
   The ISO has sshd enabled and `me.ssh.pubKeys` authorized for `root`/`nixos`.
2. Boot the target from the USB and note its IP (`ip a`).
3. From this repo on another machine:
   ```sh
   install <host> root@<ip>
   ```

### Remote machine (Hetzner, VPS, …)

Get the target into a NixOS installer / rescue / kexec environment reachable over SSH, then:

```sh
install <host> root@<ip>
```

Official kexec installer, if the host only offers a non-NixOS rescue system:

```sh
curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run
```

### Local, on the machine itself

Boot the target from the installer ISO, check out this repo there, then:

```sh
install <host>          # no target = format THIS machine's disks + nixos-install
```

### Brand-new hardware (no hardware profile yet)

Generate a hardware profile from the booted target first, commit it, then install:

```sh
ssh root@<ip> nixos-facter > hosts/<host>/facter.json   # if the host uses facter
# or: ssh root@<ip> nixos-generate-config --no-filesystems --show-hardware-config > hosts/<host>/hardware-configuration.nix
install <host> root@<ip>
```

Hosts bake `users.users.*.initialHashedPassword`, so first login works without any `mkpasswd` step.

> Secrets (sops/age) are **not** provisioned during install yet — after first boot, place the age key as
> before. See `secrets/` and [modules/nixos/core/sops](modules/nixos/core/sops/default.nix).

# Manage (day 2)

```sh
deploy <host>              # rebuild + switch NixOS and home-manager locally
deploy <host> root@<ip>    # ... over SSH (nilla os/home switch --target)
```

Whole-fleet deploys still go through Colmena (see [hive.nix](hive.nix)):

```sh
colmena apply --on @<tag>
```
