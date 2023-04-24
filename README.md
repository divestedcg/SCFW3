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
- Or place in /etc/cron.daily/0scfw with bottom bits edited to enableforce

Known Issues
------------
- You must set FirewallBackend to iptables for firewalld <1.3.1, see https://github.com/firewalld/firewalld/issues/738

Credits
-------
- FireHOL for the blocklists: https://iplists.firehol.org
- IPdeny for the country lists: https://ipdeny.com

Donate
-------
- https://divested.dev/donate
