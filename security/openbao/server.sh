# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
script_dir="$( cd $( dirname ${0} ) && pwd -P )" &&
version=$(cat ${script_dir}/version.txt) &&
podman run \
  --interactive \
  --tty \
  --rm \
  docker.io/openbao/openbao:${version} \
  &&
true
# ============================================================================ #
# # Define account for vault agent
# bao auth enable approle
# bao write auth/approle/role/vault-agent-role \
#   token_policies="vault-agent-policy" \
#   token_ttl="1h" \
#   token_max_ttl="4h"
# bao write auth/approle/role/vault-agent-role/custom-secret-id \
#   secret_id="ChangeMeToAStrongStaticPassword"
# bao read -field=role_id auth/approle/role/vault-agent-role/role-id
# bao policy write vault-agent-policy - <<'EOF'
# path "secret/data/mariadb/auth/creds/my-injector" {
#   capabilities = ["read"]
# }
# EOF
#
# bao secrets enable -path=secret kv-v2
# bao kv put secret/mariadb/auth/creds/my-injector \
#   username="injector_user_01" \
#   password="DummyPass_9xK4mQTedi2vR8pL"
# ============================================================================ #
