# SOL - Serial Over LAN
To use SOL (Serial over LAN) you should enable it in the UEFI setup/BIOS:
`Advanced -> Serial Port Console Redirection -> SOL -> Console Redirection
 [Enabled]` then save and exit(exit=reboot).

Then connect with:
```sh
IPMI_PASSWORD=mySecretPass ipmitool -h 192.168.0.11 -U admin -E -C3 -I lanplus \
  sol activate

# Run sol deactivate if SOL session is already active
```

