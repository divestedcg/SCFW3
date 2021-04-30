#!/bin/bash
#Copyright (c) 2021 Divested Computing Group
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

#TODO: Fix IPv6 support (it uses even more memory)
#XXX: TODO: Fix out-of-memory under SELinux enabled. dontaudit NETFILTER_CFG nft_register_rule on ipset import?

createWorkDirectory() {
	mkdir /tmp/scfw3 &>/dev/null || true;
	chmod 700 /tmp/scfw3;
	cd /tmp/scfw3;
}

#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-setting_and_controlling_ip_sets_using_firewalld
importListToFirewall() {
	name=$1;
	url=$2;
	if [ "$3" = "true" ]; then v6="--option=family=inet6"; fi;
	/usr/bin/wget -O "$name".iplist "$url";
	removeSelectEntries "$name".iplist;
	firewall-cmd --permanent --delete-ipset="$name" &>/dev/null || true;
	firewall-cmd --permanent --new-ipset="$name" --type=hash:net --option=maxelem=1000000;
	firewall-cmd --permanent --ipset="$name" --add-entries-from-file="$name".iplist;
	firewall-cmd --permanent --zone=drop --add-source=ipset:"$name";
	unset v6;
}

importCountryList() {
	countryCode="$1";
	importListToFirewall country-block-v4-"$countryCode" "https://www.ipdeny.com/ipblocks/data/aggregated/$countryCode-aggregated.zone";
	#importListToFirewall country-block-v6-"$countryCode" "https://www.ipdeny.com/ipv6/ipaddresses/blocks/$countryCode.zone" true;
}

removeSelectEntries() {
	awk -i inplace '!/0.0.0.0\/8/' $1;
	awk -i inplace '!/10.0.0.0\/8/' $1;
	awk -i inplace '!/172.16.0.0\/12/' $1;
	awk -i inplace '!/192.168.0.0\/16/' $1;
	awk -i inplace '!/169.254.0.0\/16/' $1;
	awk -i inplace '!/100.64.0.0\/10/' $1;
	awk -i inplace '!/fd00::\/7/' $1;
	awk -i inplace '!/fd00::\/8/' $1;
	awk -i inplace '!/fe80::\/10/' $1;
}

loadLists() {
	#Create the needed directories
	createWorkDirectory;

	#Download and import the lists
	importListToFirewall "firehol_level1" "https://iplists.firehol.org/files/firehol_level1.netset";
	importListToFirewall "firehol_level2" "https://iplists.firehol.org/files/firehol_level2.netset";
	importListToFirewall "firehol_level3" "https://iplists.firehol.org/files/firehol_level3.netset";
	#importListToFirewall "firehol_level4" "https://iplists.firehol.org/files/firehol_level4.netset";
	#importListToFirewall "firehol_webserver" "https://iplists.firehol.org/files/firehol_webserver.netset";

	#Reference: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
	#importCountryList cn; #China
	#importCountryList ru; #Russia
	#importCountryList va; #Holy See

	#Reload to apply
	firewall-cmd --reload;
}

clearLists() {
	firewall-cmd --permanent --delete-ipset="firehol_level1" &>/dev/null || true;
	firewall-cmd --permanent --delete-ipset="firehol_level2" &>/dev/null || true;
	firewall-cmd --permanent --delete-ipset="firehol_level3" &>/dev/null || true;
}

if [ "$1" = "enable" ]; then loadLists; fi;
if [ "$1" = "disable" ]; then clearLists; fi;
