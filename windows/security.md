# Security
```txt
This website is blocked by your organization.
Hosted by gmail.com
Contact your administrator for more information. Visit the support page.

Close page
Microsoft Security
```

View local events in:

> Start -> Event Viewer -> Applications and Services Logs -> Microsoft
> -> Windows -> Windows Defender -> Operational

Workarounds:
## 1. firefox/chromium in WSL
## 2. Proxy SOCKS5 via SSH
```sh
C:\Windows>ssh -D 1234 -p 1122 -N paul@alice.home.server.paul.grozav.info
# This will open a SOCKS5 proxy on localhost:1234
# Then download a protable (no-install) browser like this Firefox:
# https://portableapps.com/apps/internet/firefox_portable
# Go to Settings and search for "proxy", click Settings to set the proxy, and:
# Select "Manual proxy configuration"
# SOCKS Host: localhost
# Port: 1234
# Select SOCKS v5
```
## 3. Proxy server
```sh
$ cat squid.conf
# Define an ACL for the IP where your client connects from (will be visible in
# logs - initially rejected)
acl remote_ip src 11.22.33.44

# Allow the ACLs you just defined
http_access allow remote_ip

# Finally, deny everything else
http_access deny all

# Default port - ensure this is exposed though your firewall/NAT
http_port 3128
$ podman run -it --replace --name squid-proxy -p 0.0.0.0:3128:3128 \
  -v $(pwd)/squid.conf:/etc/squid/squid.conf:ro docker.io/ubuntu/squid:latest

# Then on your browser/client:
# Select "Manual proxy configuration"
# HTTP Proxy: alice.home.server.paul.grozav.info
# Port: 3128
```
## 4. Use a VirtualMachine
