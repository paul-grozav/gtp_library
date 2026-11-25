# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
/usr/bin/dumb-init \
  /bin/sh \
  /usr/local/bin/docker-entrypoint.sh \
  agent \
  -config /openbao/agent.hcl \
  &
agent_pid=${!} &&
cfg_file="/openbao/secrets/config.xml" &&
echo "Agent started with pid=${agent_pid}" &&
while [ ! -f ${cfg_file} ]
do
  echo "Waiting for config file to be generated at ${cfg_file} ..." &&
  sleep 1
done &&
echo "Config file generated at ${cfg_file} ." &&
echo "Running my app ..." &&
/bin/sh /app/start.sh &&
kill ${agent_pid} &&
wait ${agent_pid} &&
true
# ============================================================================ #
