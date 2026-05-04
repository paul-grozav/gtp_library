[Boxes registry](https://portal.cloud.hashicorp.com/vagrant/discover)
#### Commands
```sh
# List all boxes available on machine
vagrant box list

# List all VMs available on machine
vagrant global-status
# List status of VM(s) defined in current directory
vagrant status

vagrant box add user/box-name ./my_box_file

vagrant init alpine/alpine64 # after mkdir project && cd project
vagrant ssh
vagrant destroy -f

vagrant up
vagrant halt
# force shutdown, not graceful
vagrant halt -f

```