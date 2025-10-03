This was tested with the following software:
1. **Target**(a.k.a. Server) -
  [`rtslib-fb`](https://github.com/open-iscsi/rtslib-fb) and the debian package
  [`targetcli-fb`](https://packages.debian.org/bookworm/targetcli-fb)
2. **Initiator**(a.k.a. Client) - https://ipxe.org using commands
  [sanboot](https://ipxe.org/cmd/sanboot) and
  [sanhook](https://ipxe.org/cmd/sanhook)

## Target
Installing the software on Debian(13):
```sh
apt-get update &&
apt-get install -y \
  targetcli-fb \
  kmod
```

The LIO kernel subsystem can also be managed from Python directly. Here is
`lio_manager.py`.
<details>
<summary>lio_manager.py source code</summary>

```py
# Author: AI
import sys
import os
import json
from rtslib_fb.root import RTSRoot
from rtslib_fb.utils import RTSLibError

# --- Configuration ---
# This path must match where you store your configuration
CONFIG_PATH = '/etc/rtslib-fb-target/saveconfig.json'

def initialize_root():
    """Initializes the connection to the LIO kernel subsystem (configfs)."""
    try:
        # We use the minimal constructor, as learned from the debugging process
        return RTSRoot()
    except Exception as e:
        print(f"\n[ERROR] Failed to initialize LIO connection to kernel (configfs).")
        print(f"The root cause is likely a low-level permission or missing kernel module.")
        print(f"Details: {e}")
        sys.exit(1)

def restore_config():
    """Restores the configuration from the saved JSON file."""
    root = initialize_root()

    if not os.path.exists(CONFIG_PATH):
        print(f"[FATAL] Configuration file not found at: {CONFIG_PATH}")
        sys.exit(1)

    try:
        print(f"[INFO] Reading configuration from: {CONFIG_PATH}")
        with open(CONFIG_PATH, 'r') as f:
            config_data = json.load(f)

        print("[INFO] Attempting to restore configuration to kernel...")
        # Restore with target and storage object arguments (no 'auth' or 'check_existing')
        errors = root.restore(config_data, target=True, storage_object=True)

        if errors:
            print("[SUCCESS] Configuration restored with non-fatal issues (often cleanup errors).")
            # print("Non-fatal errors encountered:")
            # for error in errors:
            #     print(f"  - {error}")
        else:
            print("[SUCCESS] LIO configuration fully restored and active.")

    except Exception as e:
        print(f"\n[CRITICAL FAILURE] Failed to restore configuration: {e}")
        sys.exit(1)

def save_config():
    """Saves the current active configuration from the kernel to the JSON file."""
    root = initialize_root()

    try:
        print(f"[INFO] Saving active configuration to: {CONFIG_PATH}")
        root.save_to_file(CONFIG_PATH)
        print("[SUCCESS] Configuration saved.")
    except Exception as e:
        print(f"\n[CRITICAL FAILURE] Failed to save configuration: {e}")
        print("Check write permissions for the configuration directory.")
        sys.exit(1)


def list_config():
    """Prints the current configuration tree (equivalent to 'ls')."""
    root = initialize_root()
    # Note: We can't use root.print_config() directly as it may not exist in this rtslib version.
    print("\n--- ACTIVE LIO CONFIGURATION (Manual Dump) ---")

    # Simple dump of the current active configuration
    try:
        config_dump = json.dumps(root.dump(), indent=4)
        print(config_dump)
        print("---------------------------------------------")
        print("[INFO] Target is currently active in kernel.")
    except Exception as e:
        print(f"[ERROR] Could not dump configuration tree: {e}")


def show_usage():
    """Prints usage instructions."""
    script_path = os.path.basename(sys.argv[0])
    print(f"\nUsage: python3 {script_path} <command>")
    print("\nCommands:")
    print("  restore  - Loads the configuration from the JSON file into the kernel (use after boot or config change).")
    print("  save     - Saves the current kernel state to the JSON file.")
    print("  list     - Prints the current active configuration tree in JSON format.")
    print("  status   - Alias for 'list'.")
    sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        show_usage()

    command = sys.argv[1].lower()

    if command == 'restore':
        restore_config()
    elif command == 'save':
        save_config()
    elif command in ('list', 'status'):
        list_config()
    else:
        show_usage()
```
</details>

Use as:
```sh
root@alice:/# python3 lio_manager.py restore
root@alice:/# python3 lio_manager.py list
```

This will load/save the config from/to this JSON file:
`/etc/rtslib-fb-target/saveconfig.json`.

To alter the content of the JSON you can use the following CLI commands:

```sh
# === Expose hdd.img over iscsi ===
iqn="iqn.2025-10.com.example" &&
allowed_initiator="${iqn}:client1" &&
fileio_path="/home/paul/data/FreeDOS/dosnethdd.img" &&
fileio_name="doshdd" &&
fileio_iqn="${iqn}:${fileio_name}" &&

# Create the FileIO BackStore Storage object - this is the actual file on the
# disk that will be exposed over the network.
targetcli /backstores/fileio create ${fileio_name} ${fileio_path} &&
# Create the iSCSI target object including the TPG1 and a portal listening on
# 0.0.0.0 port 3260.
targetcli /iscsi create ${fileio_iqn} &&
# Add the previously created FileIO BackStore as a LUN to the iSCSI object. 
targetcli /iscsi/${fileio_iqn}/tpg1/luns create \
  /backstores/fileio/${fileio_name} &&
# Restrict access to iSCSI object and only allow one initiator to access it.
targetcli /iscsi/${fileio_iqn}/tpg1/acls create ${allowed_initiator} &&
# Save configuration objects created in RAM/runtime to JSON persistent storage.
targetcli saveconfig

# To show the objects/structure you can do
targetcli ls

# If you want to remove the objects, do it in reverse order
targetcli /iscsi/${fileio_iqn}/tpg1/acls delete ${allowed_initiator} &&
targetcli /iscsi/${fileio_iqn}/tpg1/luns delete lun0 &&
targetcli /iscsi delete ${fileio_iqn} &&
targetcli /backstores/fileio delete ${fileio_name} &&
targetcli saveconfig
```

## Initiator(iPXE)
The format of an iSCSI SAN URI is defined by RFC 4173. The general syntax is:
```txt
iscsi:<servername>:<protocol>:<port>:<LUN>:<targetname>
```
- `<servername>` is the DNS name or IP address of the iSCSI target.
- `<protocol>` is the protocol which iSCSI target(portal) is using. It can be
left empty, in which case, the default protocol 6 (that is TCP) will be used.
- `<port>` is the TCP port of the iSCSI target. It can be left empty, in which
case the default port (3260) will be used.
- `<LUN>` is the SCSI LUN of the boot disk, in hexadecimal. It can be left
empty, in which case the default LUN (0) will be used.
- `<targetname>` is the iSCSI target IQN.

```sh
#!ipxe
dhcp

# This initiator-iqn is the authentication string sent in the first packet by
# ipxe, after connecting.
set initiator-iqn iqn.2025-10.com.example:client1
# sanboot iscsi:192.168.0.2:6:3260:0:iqn.2025-10.com.example:dosnethdd.img
# sanboot iscsi:192.168.0.2:6:3260:0:iqn.2025-10.com.example:dsl.iso
set target_host 192.168.0.2
set target_protocol 6
set target_port 3260
set target_iqn iqn.2025-10.com.example:dsl.iso
set target_lun 0
sanboot iscsi:${target_host}:${target_protocol}:${target_port}:${target_lun}:${target_iqn}
```

## Terminology
1. `Target` - The network storage **server**, holding and serving the
disks/data.
2. `Initiator` - The **client** that mounts/reads/consumes the disks through the
network.
3. `iSCSI LUN` - A Logical Unit Number is a uniquely identified, **logical
partition of storage** presented over a network using the iSCSI protocol.
4. `IQN` - An iSCSI Qualified Name (IQN) is a unique, standard format name used
to identify an iSCSI node, such as an initiator (client) or target (server), in
an iSCSI network.
5. `TPG` - A Target Portal Group is a list of network portals (IP address and
TCP port combinations) that an iSCSI target uses to listen for connections.
