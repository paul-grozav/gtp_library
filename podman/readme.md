```sh
# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
echo "Installing podman ..." &&
yum install -y podman &&
(
  echo "Installing podman-compose ..." &&
  curl -o /usr/local/bin/podman-compose https://raw.githubusercontent.com/containers/podman-compose/devel/podman_compose.py &&
  chmod +x /usr/local/bin/podman-compose &&
  yum install -y python3-pyyaml
) &&
exit 0
# ============================================================================ #
```