#!/bin/bash
#Copyright (c) 2021-2023 Divested Computing Group
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

#TODO: Enable IPv6 support

blockedLists=('firehol_level1');
blockedLists+=('firehol_level2');
blockedLists+=('firehol_level3');
#blockedLists+=('firehol_level4');
#blockedLists+=('firehol_webserver');
#blockedLists+=('firehol_webclient');
#blockedLists+=('firehol_anonymous');
blockedCountries=();
#blockedCountries+=('cn' 'us' 'ru');
allowList=('!/0.0.0.0\/8/' '!/10.0.0.0\/8/' '!/172.16.0.0\/12/' '!/192.168.0.0\/16/' '!/169.254.0.0\/16/' '!/100.64.0.0\/10/' '!/fd00::\/7/' '!/fd00::\/8/' '!/fe80::\/10/');

createWorkDirectory() {
	mkdir /tmp/scfw3 &>/dev/null || true;
	chmod 700 /tmp/scfw3;
	cd /tmp/scfw3;
}

#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-setting_and_controlling_ip_sets_using_firewalld
importListToFirewall() {
	echo "Importing $1";
	name=$1;
	url=$2;
	if [ "$3" = "true" ]; then inet="--option=family=inet6"; else inet="--option=family=inet"; fi;
	if [ ! -f "$name.ipset" ]; then /usr/bin/wget -O "$name".ipset "$url"; fi;
	removeAllowedEntries "$name".ipset;
	firewall-cmd --permanent --delete-ipset="$name" &>/dev/null || true;
	firewall-cmd --permanent --new-ipset="$name" --type=hash:net --option=maxelem=200000 --option=hashsize=16384 $inet;
	firewall-cmd --permanent --ipset="$name" --add-entries-from-file="$name".ipset;
	firewall-cmd --permanent --zone=scfw --add-source=ipset:"$name";
	unset inet;
	sleep 2;
}

importCountryList() {
	echo "Importing $1";
	countryCode="$1";
	importListToFirewall country-block-v4-"$countryCode" "https://www.ipdeny.com/ipblocks/data/aggregated/$countryCode-aggregated.zone";
	#importListToFirewall country-block-v6-"$countryCode" "https://www.ipdeny.com/ipv6/ipaddresses/blocks/$countryCode.zone" true;
}

removeAllowedEntries() {
	#TODO: Concat them all and perform in one pass
	for allow in "${allowList[@]}"
	do
		awk -i inplace "$allow" "$1";
	done;
}

loadLists() {
	#Remove old lists+zone
	clearLists;

	#Create the needed directories
	createWorkDirectory;

	#Setup the zone
	firewall-cmd --new-zone=scfw --permanent || true;
	firewall-cmd --zone=scfw --set-target=DROP --permanent;

	for list in "${blockedLists[@]}"
	do
		importListToFirewall "$list" "https://iplists.firehol.org/files/$list.netset";
	done;

	for country in "${blockedCountries[@]}"
	do
		importCountryList "$country";
	done;

	#Reload to apply
	firewall-cmd --reload;
	echo "[SCFW3] Loaded";
}

clearLists() {
	for list in "${blockedLists[@]}"
	do
		firewall-cmd --permanent --delete-ipset="$list" &>/dev/null || true;
	done;

	for country in "${blockedCountries[@]}"
	do
		firewall-cmd --permanent --delete-ipset="country-block-v4-$list" &>/dev/null || true;
		firewall-cmd --permanent --delete-ipset="country-block-v6-$list" &>/dev/null || true;
	done;

	#Delete the zone
	firewall-cmd --delete-zone=scfw --permanent || true;

	#Reload to apply
	firewall-cmd --reload;
	echo "[SCFW3] Unloaded";
}

#Friendly prompt
#if [ "$1" = "enable" ]; then
#	loadLists;
#elif [ "$1" = "enableforce" ]; then
#	rm -rfv /tmp/scfw3;
#	loadLists;
#elif [ "$1" = "disable" ]; then
#	clearLists;
#else
#	echo "Options are: enable, enableforce, disable";
#fi;

#Just run as expected
rm -rfv /tmp/scfw3;
loadLists;
