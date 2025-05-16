references
- https://github.com/nilla-nix/nilla
- https://github.com/arnarg/nilla-utils
- https://github.com/arnarg/config
- https://github.com/jakehamilton/config
`systems.nixos.<name>.result.config.system.build.toplevel`

# Install

### kexec if you must
```sh
curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run
```

### Partition, Format, Mount

Manually or using Disko:

```sh
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount disk-config.nix
```

### Generate passwords if users are immutable enabled!!
```
mkpasswd -m sha-512 > /persist/passwords/root
mkpasswd -m sha-512 > /persist/passwords/<user>
```

### Install system:

```sh
nixos-install --no-root-passwd --no-channel-copy -f nilla.nix -A systems.nixos.<name>.result
```

```sh
reboot
```

Activate home manager conf:
```sh
nix build -f nilla.nix systems.home."<user>@<host>".result.activationPackage
./result/activate
```
