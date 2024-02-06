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
blockedLists+=('feodo.ipset');
blockedLists+=('gpf_comics.ipset');
blockedLists+=('greensnow.ipset');
#blockedLists+=('ipsum-4.ipset');
blockedLists+=('myip.ipset');
blockedLists+=('php_commenters_30d.ipset' 'php_dictionary_30d.ipset' 'php_harvesters_30d.ipset' 'php_spammers_30d.ipset');
blockedLists+=('sblam.ipset');
blockedLists+=('socks_proxy_30d.ipset');
blockedLists+=('spamhaus_drop.netset');
blockedLists+=('spamhaus_edrop.netset');
blockedLists+=('sslbl.ipset');
blockedLists+=('sslproxies_30d.ipset');
blockedLists+=('stopforumspam_7d.ipset');
blockedLists+=('threatview.ipset');
#blockedLists+=('vpn_x.ipset');
blockedLists+=('vxvault.ipset');
blockedLists+=('xroxy_30d.ipset');
if [ "$SCFW_BLOCK_TOR" = true ]; then blockedLists+=('dm_tor.ipset' 'et_tor.ipset' 'iblocklist_onion_router.netset' 'tor_exits.ipset'); fi;
#<25k entries
blockedLists+=('botscout_30d.ipset');
blockedLists+=('cinscore.ipset');
#blockedLists+=('ipsum-3.ipset');
#blockedLists+=('vpn_a.ipset');
#<50k entries
blockedLists+=('blocklist_de.ipset');
blockedLists+=('ciarmy.ipset');
blockedLists+=('cleantalk_7d.ipset');
#blockedLists+=('ipsum-2.ipset');
#<100k entries
#blockedLists+=('haley_ssh.ipset');
#<150k entries
blockedLists+=('blocklist_net_ua.ipset');
#blockedLists+=('stopforumspam.ipset');
#<300k entries
blockedLists+=('ipsum-1.ipset');

#Countries
blockedCountries=();
#blockedCountries+=('cn' 'us' 'ru');

createWorkDirectory() {
	mkdir /tmp/scfw3 &>/dev/null || true;
	chmod 700 /tmp/scfw3;
	cd /tmp/scfw3;
}

importList() {
	echo "Importing $1";
	url=$2;
	#Remove comments, empty lines, and leading zeroes
	#Credit (CC BY-SA 4.0): https://stackoverflow.com/a/3432574
	#Credit (CC BY-SA 4.0): https://stackoverflow.com/a/60741627
	if [[ "$list" == "threatview.ipset" ]]; then
		/usr/bin/wget -4 --compression=auto -O - "$url" | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' | sed -E 's/\.0*([1-9])/\.\1/g; s/^0*//' >> "scfw3-combined";
	elif [[ "$list" == "vpn_a.ipset" ]]; then
		/usr/bin/wget -4 --compression=auto -O - "$url" | sed 's/ # .*//' | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> "scfw3-combined";
	else
		/usr/bin/wget -4 --compression=auto -O - "$url" | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> "scfw3-combined";
	fi;
}

importCountryList() {
	countryCode="$1";
	importList country-block-v4-"$countryCode" "https://www.ipdeny.com/ipblocks/data/aggregated/$countryCode-aggregated.zone";
	#importList country-block-v6-"$countryCode" "https://www.ipdeny.com/ipv6/ipaddresses/blocks/$countryCode.zone" true;
}

prepareTorExclusion() {
	wget "https://iplists.firehol.org/files/tor_exits.ipset" -O - | grep -v '^#' | sed 's/\./\\./g' | sed 's/^/\^/' | sed 's/$/\$/' > tor_exclusions.grep;
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
	if [ -f /usr/local/bin/ip-aggregator.py ]; then
		mv "$1" "$1.orig";
		cat "$1.orig" | python3 /usr/local/bin/ip-aggregator.py --stdin --quiet --sort > "$1";
		rm "$1.orig";
		wc -l "$1";
	fi;
}

loadLists() {
	#Create the needed directories
	createWorkDirectory;

	#Setup exclusions
	if [ ! -f /etc/scfw-exclusions.grep ]; then
		echo -e '^127\.0\.0\.1$\n^0\.0\.0\.0/8$\n^10\.0\.0\.0/8$\n^172\.16\.0\.0/12$\n^192\.168\.0\.0/16$\n^169\.254\.0\.0/16$\n^100\.64\.0\.0/10$\n^fd00::/7$\n^fd00::/8$\n^fe80::/10$' > /etc/scfw-exclusions.grep;
	fi;
	if [ "$SCFW_BLOCK_TOR" = false ]; then prepareTorExclusion; fi;

	#Download the lists
	for list in "${blockedLists[@]}"
	do
		if [[ "$list" == "cinscore.ipset" ]]; then
			importList "$list" "https://cinsscore.com/list/ci-badguys.txt";
		elif [[ "$list" == "feodo.ipset" ]]; then
			importList "$list" "https://feodotracker.abuse.ch/downloads/ipblocklist.txt";
		elif [[ "$list" == "ipsum-1.ipset" ]]; then
			importList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/1.txt";
		elif [[ "$list" == "ipsum-2.ipset" ]]; then
			importList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/2.txt";
		elif [[ "$list" == "ipsum-3.ipset" ]]; then
			importList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/3.txt";
		elif [[ "$list" == "ipsum-4.ipset" ]]; then
			importList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/4.txt";
		elif [[ "$list" == "sslbl.ipset" ]]; then
			importList "$list" "https://sslbl.abuse.ch/blacklist/sslipblacklist.txt";
		elif [[ "$list" == "threatview.ipset" ]]; then
			importList "$list" "https://threatview.io/Downloads/IP-High-Confidence-Feed.txt";
		elif [[ "$list" == "vpn_a.ipset" ]]; then
			importList "$list" "https://github.com/az0/vpn_ip/raw/main/data/output/ip.txt";
		elif [[ "$list" == "vpn_x.ipset" ]]; then
			importList "$list" "https://github.com/X4BNet/lists_vpn/raw/main/output/vpn/ipv4.txt";
		else
			importList "$list" "https://iplists.firehol.org/files/$list";
		fi;
	done;

	#Download the country lists
	for country in "${blockedCountries[@]}"
	do
		importCountryList "$country";
	done;

	#Cleanup
	sort -u -o "scfw3-combined" "scfw3-combined";
	removeAllowedEntries "scfw3-combined";

	#Remove old lists+zone
	firewall-cmd --delete-zone=scfw --permanent &>/dev/null || true;
	firewall-cmd --permanent --delete-ipset="scfw3-combined" &>/dev/null || true;
	firewall-cmd --reload;

	#Import the combined ipset
	#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-setting_and_controlling_ip_sets_using_firewalld
	firewall-cmd --new-zone=scfw --permanent;
	firewall-cmd --zone=scfw --set-target=DROP --permanent;
	firewall-cmd --permanent --new-ipset="scfw3-combined" --type=hash:net --option=maxelem=600000 --option=hashsize=16384 --option=family=inet;
	firewall-cmd --permanent --ipset="scfw3-combined" --add-entries-from-file="scfw3-combined";
	firewall-cmd --permanent --zone=scfw --add-source=ipset:"scfw3-combined";

	#Reload to apply
	firewall-cmd --reload;
	echo "[SCFW3] Loaded";
}

#Just run as expected
rm -rfv /tmp/scfw3;
loadLists;
