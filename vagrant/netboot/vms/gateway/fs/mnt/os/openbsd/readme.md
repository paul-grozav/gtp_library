[//]: # (======================================================================)
[//]: # (authors:                                                              )
[//]: # (- Tancredi-Paul Grozav <paul@grozav.info>                             )
[//]: # (======================================================================)

See `diagram.plantuml` for how the boot works.

See `dhcp_snippet.conf` for how to define your host in the DHCP configuration
file.

Run `tftp_prepare.sh` to add the files to the TFTP server. This also copies `boot.conf` to the TFTP server.

Run `http_prepare.sh` to add the files to the HTTP server.

Look at `boot.output` to see what to expect when starting OpenBSD over PXE.

[//]: # (======================================================================)
