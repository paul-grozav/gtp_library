```sh
# Tell curl that google.com:443 requests should be sent to 127.0.0.1:443 and not
# even try to resolve this domain using the NameServer. This domain name - IP
# mapping is injected in curl's DNS cache.
curl -vvv --resolve google.com:443:127.0.0.1 https://google.com/
```