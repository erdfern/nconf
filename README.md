references
- https://github.com/nilla-nix/nilla
- https://github.com/arnarg/nilla-utils
- https://github.com/arnarg/config
- https://github.com/jakehamilton/config
`systems.nixos.<name>.result.config.system.build.toplevel`

# Install

### Partition, Format, Mount

Manually or using Disko:

```sh
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount hosts/<name>/disk-config.nix
```

### Install system:

```sh
nixos-install -f nilla.nix -A systems.nixos.<name>.result
```

```sh
reboot
```

Activate home manager conf:
```sh
nix build -f nilla.nix systems.home."<user>@<host>".result.activationPackage
./result/activate
```
