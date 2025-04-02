Create your keys:
rm ./key ./key.pub ; ssh-keygen -f ./key -P "" -m PEM -C "key@generic" && cat ./key ./key.pub ; rm ./key ./key.pub
And rename them to id_rsa and id_rsa.pub
These will be used to communicate with the machines you manage through ansible.

-rw------- 1 paul paul 1679 Jan 30 15:56 id_rsa
-rw------- 1 paul paul  394 Jan 30 15:56 id_rsa.pub

