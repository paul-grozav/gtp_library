# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
vault {
  # Use https or http
  address = "https://openbao.server.paul.grozav.info/"
}
auto_auth {
  method "approle" {
    config = {
      # role_id_file_path = "/openbao/creds/role_id"
      # secret_id_file_path = "/openbao/creds/secret_id"
      role_id_file_path = "/run/secrets/role_id"
      secret_id_file_path = "/run/secrets/secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "/openbao/secrets/token"
    }
  }
}

# One for every file to manage
template {
  source = "/app/config.ctmpl"
  destination = "/openbao/secrets/config.xml"
  perms = 0400
}
# ============================================================================ #
