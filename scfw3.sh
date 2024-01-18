#!/bin/bash
#Copyright (c) 2021-2024 Divested Computing Group
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
export SCFW_BLOCK_TOR=false;

#Lists
#<10k entries
blockedLists+=('bds_atif.ipset');
blockedLists+=('botscout_7d.ipset');
blockedLists+=('botvrij_dst.ipset');
blockedLists+=('bruteforceblocker.ipset');
blockedLists+=('cidr_report_bogons.netset');
blockedLists+=('cybercrime.ipset');
blockedLists+=('dyndns_ponmocup.ipset');
blockedLists+=('et_block.netset');
blockedLists+=('et_compromised.ipset');
blockedLists+=('gpf_comics.ipset');
blockedLists+=('greensnow.ipset');
blockedLists+=('myip.ipset');
blockedLists+=('php_commenters_7d.ipset' 'php_dictionary_7d.ipset' 'php_harvesters_7d.ipset' 'php_spammers_7d.ipset');
blockedLists+=('sblam.ipset');
blockedLists+=('socks_proxy_7d.ipset');
blockedLists+=('spamhaus_drop.netset');
blockedLists+=('spamhaus_edrop.netset');
blockedLists+=('sslproxies_7d.ipset');
blockedLists+=('stopforumspam_7d.ipset');
blockedLists+=('vxvault.ipset');
blockedLists+=('xroxy_7d.ipset');
if [ "$SCFW_BLOCK_TOR" = true ]; then blockedLists+=('dm_tor.ipset' 'et_tor.ipset' 'tor_exits.ipset'); fi;
#<50k entries
blockedLists+=('blocklist_de.ipset');
blockedLists+=('ciarmy.ipset');
blockedLists+=('cleantalk_7d.ipset');
#<100k entries
#blockedLists+=('blocklist_net_ua.ipset');
#blockedLists+=('haley_ssh.ipset');
#<150k entries
#blockedLists+=('stopforumspam.ipset');

#Countries
blockedCountries=();
#blockedCountries+=('cn' 'us' 'ru');

#Exclusions
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
	if [ ! -f "$name" ]; then /usr/bin/wget -O "$name" "$url"; fi;
	removeAllowedEntries "$name";
	firewall-cmd --permanent --delete-ipset="$name" &>/dev/null || true;
	firewall-cmd --permanent --new-ipset="$name" --type=hash:net --option=maxelem=200000 --option=hashsize=16384 $inet;
	firewall-cmd --permanent --ipset="$name" --add-entries-from-file="$name";
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

prepareTorExclusion() {
	wget "https://iplists.firehol.org/files/tor_exits.ipset" -O - | grep -v '^#' | sed 's/\./\\./g' > tor_exclusions.grep;
}

removeAllowedEntries() {
	wc -l "$1";
	if [ "$SCFW_BLOCK_TOR" = false ]; then
		mv "$1" "$1.orig";
		grep -v -f tor_exclusions.grep "$1.orig" > "$1";
	fi;
	#TODO: Concat them all and perform in one pass
	for allow in "${allowList[@]}"
	do
		awk -i inplace "$allow" "$1";
	done;
	wc -l "$1";
}

loadLists() {
	#Remove old lists+zone
	clearLists;

	#Create the needed directories
	createWorkDirectory;

	#Setup the zone
	firewall-cmd --new-zone=scfw --permanent || true;
	firewall-cmd --zone=scfw --set-target=DROP --permanent;

	if [ "$SCFW_BLOCK_TOR" = false ]; then prepareTorExclusion; fi;

	for list in "${blockedLists[@]}"
	do
		importListToFirewall "$list" "https://iplists.firehol.org/files/$list";
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
