# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
echo "Application started" &&
source /openbao/secrets/config.xml &&
echo "mysql -u ${sql_user} -p${sql_password}" &&
echo "Application ended" &&
true
# ============================================================================ #
