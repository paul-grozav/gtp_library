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
# export BAO_TOKEN="SECRET_TOKEN"
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
#
# Enabling dynamic mariadb accounts & secrets
# bao secrets enable database
# bao write database/config/my-mariadb-database \
#   plugin_name=mysql-database-plugin \
#   connection_url="{{username}}:{{password}}@tcp(openbao-mariadb-svc:3306)/" \
#   allowed_roles="my-role" \
#   username="root" \
#   password="example-root-password"
# bao write database/roles/my-role \
#   db_name=my-mariadb-database \
#   creation_statements="
#     create user '{{name}}'@'%' identified by '{{password}}';
#     grant select on *.* to '{{name}}'@'%';
#   " \
#   revocation_statements="
#     drop user if exists '{{name}}'@'%';
#   " \
#   default_ttl="60s" \
#   max_ttl="1h"
# bao read database/creds/my-role # Will generate a new user and pass
# List generated credentials for that role
# bao list sys/leases/lookup/database/creds/my-role
# List that specific lease by ID
# bao lease lookup database/creds/my-role/2q9207U6dZufRr2Al1clYpfI
#
# Get credentials with curl:
# BAO_ADDR="https://openbao.server.paul.grozav.info" \
# curl -vvv -H "X-Vault-Token: someToken" \
#   "${BAO_ADDR}/v1/database/creds/my-role" | jq .
# Every curl call generates a new credential set.
# ============================================================================ #
