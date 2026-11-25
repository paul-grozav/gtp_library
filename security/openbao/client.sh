# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
script_dir="$( cd $( dirname ${0} ) && pwd -P )" &&
version="$(cat ${script_dir}/version.txt)" &&
ram_dir="/dev/shm/bao-app1" &&
mkdir -p ${ram_dir} &&
podman pod create \
  --name my-app-pod \
  ` # --port 8080:8080 ` \
  &&
podman volume create \
  --opt type=tmpfs \
  --opt device=tmpfs \
  shared-secrets \
  &&
podman run \
  --interactive \
  --tty \
  --rm \
  --pod my-app-pod \
  --name my-app-pod-container \
  --volume ${script_dir}/client/agent.hcl:/openbao/agent.hcl:ro \
  --volume shared-secrets:/openbao/secrets:Z \
  --volume ${script_dir}/client/creds:/openbao/creds:ro,Z \
  --volume ${script_dir}/client/app/config.ctmpl:/app/config.ctmpl:ro,Z \
  --volume ${script_dir}/client/app/entrypoint.sh:/app/entrypoint.sh:ro,Z \
  --volume ${script_dir}/client/app/start.sh:/app/start.sh:ro,Z \
  --entrypoint /bin/sh \
  docker.io/openbao/openbao:${version} \
  /app/entrypoint.sh \
  ; # Cleanup continues whether it failed or succeeded
rm -rf ${ram_dir} ;
podman pod rm my-app-pod ;
podman volume rm shared-secrets ;
true
# ============================================================================ #
