# Static Wake-on-LAN inventory, read by the `wake` helper (scripts/wake.sh).
#
# This lives OUTSIDE the per-host NixOS configs on purpose: a machine's MAC
# cannot be discovered while it is powered off, which is exactly when you want
# to wake it -- so the data `wake` needs is persisted here instead of read from
# the (offline) target. Plain attrset, no Nilla imports, so lookups are instant.
#
# Keyed by the `systems.nixos.<host>` name.
{
  kor = {
    # cat /sys/class/net/enp9s0/address
    mac = "74:56:3C:C6:41:93";

    # Subnet broadcast the magic packet is sent to (FritzBox LAN 192.168.178.0/24).
    broadcast = "192.168.178.255";
  };
}
