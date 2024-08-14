 https://hub.docker.com/r/gitlab/gitlab-runner/tags?page=1&ordering=last_updated

# !!! Make sure that you have all the images that your users currently need
# Create docker config
docker run --rm -t -i -v /opt/gitlab-runner/config:/etc/gitlab-runner --name gitlab-runner gitlab/gitlab-runner:v13.9.0 register \
  --non-interactive \
  --executor "docker" \
  --docker-image alpine:3 \
  --docker-pull-policy if-not-present \
  --docker-privileged \
  --url "https://gitlab.com/" \
  --registration-token "SECRET" \
  --description "docker-runner-ci-hypervisor" \
  --tag-list "docker,linux" \
  --run-untagged \
  --locked="false"

# Start docker runner
docker run -d --name gitlab-runner --restart always \
  -v /opt/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --privileged gitlab/gitlab-runner:v13.9.0

# This is supposed to remove the container from the site
# The name value is the description value used when registered
docker run --rm -t -i -v /opt/gitlab-runner/config:/etc/gitlab-runner --name gitlab-runner gitlab/gitlab-runner:v13.9.0 unregister \
  --url https://gitlab.com \
  --name docker-runner-ci-hypervisor
