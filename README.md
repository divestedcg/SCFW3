SCFW3
=====

Overview
--------
- These are two simple scripts to block known and learned bad addresses.
- It is meant to be used on top of firewalld.
- This is for resource management, not security.

Use
---
- Place scfw3.sh into /etc/cron.daily/1scfw
  - Copy ip-aggregator.py into /usr/local/bin/
    - This is mandatory
  - Configure the lists you want enabled at the top of it
- Place trash.sh into /etc/cron.hourly/2trash
- `chmod +x` both of them
- Enjoy!

Known Issues
------------
- You must set FirewallBackend to iptables for firewalld or will have very long load times
  - see https://github.com/firewalld/firewalld/issues/738

Credits
-------
- FireHOL for the blocklists: https://iplists.firehol.org
- IPdeny for the country lists: https://ipdeny.com
- @andrewtwin for the IP & CIDR merger: https://github.com/andrewtwin/ip-aggregator

Donate
-------
- https://divested.dev/donate
