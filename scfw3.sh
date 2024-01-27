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

#TODO: Enable/Fixup IPv6 support
export SCFW_BLOCK_TOR=false;

#Lists
#<10k entries
blockedLists+=('bds_atif.ipset');
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
blockedLists+=('php_commenters_30d.ipset' 'php_dictionary_30d.ipset' 'php_harvesters_30d.ipset' 'php_spammers_30d.ipset');
blockedLists+=('sblam.ipset');
blockedLists+=('socks_proxy_30d.ipset');
blockedLists+=('spamhaus_drop.netset');
blockedLists+=('spamhaus_edrop.netset');
blockedLists+=('sslproxies_30d.ipset');
blockedLists+=('stopforumspam_7d.ipset');
blockedLists+=('threatview.ipset');
blockedLists+=('vxvault.ipset');
blockedLists+=('xroxy_30d.ipset');
if [ "$SCFW_BLOCK_TOR" = true ]; then blockedLists+=('dm_tor.ipset' 'et_tor.ipset' 'iblocklist_onion_router.netset' 'tor_exits.ipset'); fi;
#<25k entries
blockedLists+=('botscout_30d.ipset');
blockedLists+=('cinscore.ipset');
#<50k entries
blockedLists+=('blocklist_de.ipset');
blockedLists+=('ciarmy.ipset');
blockedLists+=('cleantalk_7d.ipset');
#<100k entries
#blockedLists+=('haley_ssh.ipset');
#<150k entries
blockedLists+=('blocklist_net_ua.ipset');
#blockedLists+=('stopforumspam.ipset');

#Countries
blockedCountries=();
#blockedCountries+=('cn' 'us' 'ru');

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
	if [ ! -f "$name" ]; then
		#Remove comments, empty lines, and leading zeroes
		#Credit (CC BY-SA 4.0): https://stackoverflow.com/a/3432574
		#Credit (CC BY-SA 4.0): https://stackoverflow.com/a/60741627
		if [[ "$list" == "threatview.ipset" ]]; then
			/usr/bin/wget -O - "$url" | grep -v -e '^#' -e '^[[:space:]]*$' | sed -E 's/\.0*([1-9])/\.\1/g; s/^0*//' > "$name";
		else
			/usr/bin/wget -O - "$url" | grep -v -e '^#' -e '^[[:space:]]*$' > "$name";
		fi;
	fi;
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
		rm "$1.orig";
		wc -l "$1";
	fi;
	if [ -f /etc/scfw-exclusions.grep ]; then
		mv "$1" "$1.orig";
		grep -v -f /etc/scfw-exclusions.grep "$1.orig" > "$1";
		rm "$1.orig";
		wc -l "$1";
	fi;
}

loadLists() {
	#Remove old lists+zone
	clearLists;

	#Create the needed directories
	createWorkDirectory;

	#Setup the zone
	firewall-cmd --new-zone=scfw --permanent || true;
	firewall-cmd --zone=scfw --set-target=DROP --permanent;

	if [ ! -f /etc/scfw-exclusions.grep ]; then
		echo -e '^0\.0\.0\.0/8$\n^10\.0\.0\.0/8$\n^172\.16\.0\.0/12$\n^192\.168\.0\.0/16$\n^169\.254\.0\.0/16$\n^100\.64\.0\.0/10$\n^fd00::/7$\n^fd00::/8$\n^fe80::/10$' > /etc/scfw-exclusions.grep;
	fi;
	if [ "$SCFW_BLOCK_TOR" = false ]; then prepareTorExclusion; fi;

	for list in "${blockedLists[@]}"
	do
		if [[ "$list" == "cinscore.ipset" ]]; then
			importListToFirewall "$list" "https://cinsscore.com/list/ci-badguys.txt";
		elif [[ "$list" == "threatview.ipset" ]]; then
			importListToFirewall "$list" "https://threatview.io/Downloads/IP-High-Confidence-Feed.txt";
		else
			importListToFirewall "$list" "https://iplists.firehol.org/files/$list";
		fi;
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
