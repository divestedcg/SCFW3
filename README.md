SCFW3
=====

Overview
--------
This is a simple script to block known bad addresses.
It is meant to be used on top of firewalld.

Use
---
- Choose the lists you want enabled at the top of scfw3.sh
- `$ sudo sh scfw3.sh enable`
- `$ sudo sh scfw3.sh disable`

Known Issues
------------
- Large lists *will* OOM the system. Cause is unknown, maybe firewalld, libnftables, or SELinux policy.
 - Boot a recovery disk and `$ rm -rf /etc/firewalld/ipsets`
 - Related: https://github.com/firewalld/firewalld/issues/738

Credits
-------
- FireHOL for the blocklists: https://iplists.firehol.org
- IPdeny for the country lists: https://ipdeny.com
