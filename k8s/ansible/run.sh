#cd my_platform &&
(docker run \
  --rm \
  -it \
  -v $(pwd):/mnt:ro \
  williamyeh/ansible:alpine3 \
/bin/sh -c "$(cat - <<EOF
  cd /mnt &&
  mkdir ~/.ssh &&
  chmod a-rwx,u+rx -R ~/.ssh &&
  cp keys/id_rsa* ~/.ssh/ &&
  chmod a-rwx,u+r ~/.ssh/id_rsa* &&

#  cd my_platform &&
#  ansible-playbook books/playbook.yml &&

  cd kube-cluster &&
  ansible-playbook initial.yml &&
#  ansible-playbook kube-dependencies.yml &&
#  ansible-playbook master.yml &&
#  ansible-playbook workers.yml &&

  exit 0
EOF
)") &&
exit 0
