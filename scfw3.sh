#!/bin/bash
#
#VERSION: 20250219-01
#
#Copyright (c) 2021-2024 Divested Computing Group
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.
#
#You should have received a copy of the GNU Affero General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

#TODO: Enable/Fixup IPv6 support
export SCFW_BLOCK_PROXY=true; #Junk proxies
export SCFW_BLOCK_TOR=false; #Tor exits and other nodes
export SCFW_BLOCK_VPN=false; #Common VPN providers
export SCFW_EXCLUDE_TOR=true; #Explicitely exempt Tor nodes
export SCFW_EXCLUDE_VPN=true; #Explicitely exempt common VPN providers

#Lists
#<10k entries
blockedLists+=('bds_atif.ipset');
blockedLists+=('bitcoin_nodes.ipset');
blockedLists+=('botvrij_dst.ipset');
blockedLists+=('bruteforceblocker.ipset');
#blockedLists+=('cidr_report_bogons.netset'); #broken sometimes
#blockedLists+=('cybercure.ipset'); #demo
blockedLists+=('cybercrime.ipset');
blockedLists+=('dyndns_ponmocup.ipset');
blockedLists+=('et_block.netset');
blockedLists+=('et_compromised.ipset');
blockedLists+=('et_dshield.netset');
blockedLists+=('feodo.ipset');
blockedLists+=('gpf_comics.ipset');
blockedLists+=('greensnow.ipset');
blockedLists+=('iblocklist_spyware.ipset');
#blockedLists+=('ipsum-4.ipset');
blockedLists+=('ipthreat.ipset');
blockedLists+=('myip.ipset');
blockedLists+=('php_commenters_30d.ipset' 'php_dictionary_30d.ipset' 'php_harvesters_30d.ipset' 'php_spammers_30d.ipset');
blockedLists+=('sblam.ipset');
blockedLists+=('snort.ipset');
if [ "$SCFW_BLOCK_PROXY" = true ]; then blockedLists+=('socks_proxy_30d.ipset'); fi;
blockedLists+=('spamhaus_drop.netset');
blockedLists+=('spamhaus_edrop.netset');
blockedLists+=('sslbl.ipset');
if [ "$SCFW_BLOCK_PROXY" = true ]; then blockedLists+=('sslproxies_30d.ipset'); fi;
blockedLists+=('stopforumspam_7d.ipset');
blockedLists+=('threatview.ipset');
blockedLists+=('turrissentinel.ipset');
if [ "$SCFW_BLOCK_VPN" = true ]; then blockedLists+=('vpn_x.ipset'); fi;
blockedLists+=('vxvault.ipset');
if [ "$SCFW_BLOCK_PROXY" = true ]; then blockedLists+=('xroxy_30d.ipset'); fi;
if [ "$SCFW_BLOCK_TOR" = true ]; then blockedLists+=('dm_tor.ipset' 'et_tor.ipset' 'iblocklist_onion_router.netset' 'tor_exits.ipset'); fi;
#<25k entries
blockedLists+=('botscout_30d.ipset');
blockedLists+=('cinscore.ipset');
blockedLists+=('cleantalk_7d.ipset');
#blockedLists+=('ipsum-3.ipset');
if [ "$SCFW_BLOCK_VPN" = true ]; then blockedLists+=('vpn_a.ipset'); fi;
if [ "$SCFW_BLOCK_VPN" = true ]; then blockedLists+=('vpn_l.ipset'); fi;
#<50k entries
blockedLists+=('blocklist_de.ipset');
blockedLists+=('ciarmy.ipset');
#blockedLists+=('ipsum-2.ipset');
#<100k entries
blockedLists+=('voipbl.ipset');
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
	#Credit (CC BY-SA 4.0): https://stackoverflow.com/a/3432574
	#Credit (CC BY-SA 4.0): https://stackoverflow.com/a/60741627
	if [[ "$list" == "cybercure.ipset" ]]; then
		#Download, replace commas with newlines, strip IPv6 addresses + comments + whitespace
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "$url" | sed 's/,/\n/g' | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> "scfw3-combined";
	elif [[ "$list" == "iblocklist_spyware.ipset" ]]; then
		#Download, decompress, strip IPv6 addresses + comments + whitespace
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "$url" | zcat | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> "scfw3-combined";
	elif [[ "$list" == "ipthreat.ipset" ]]; then
		#Download, decompress, filter first column, strip IPv6 addresses + comments + whitespace + hyphenated ranges
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "$url" | zcat | awk '{print $1}' | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' -e "-" >> "scfw3-combined";
	elif [[ "$list" == "threatview.ipset" ]]; then
		#Download, strip IPv6 addresses + comments + whitespace, strip leading zeroes in addresses
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "$url" | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' | sed -E 's/\.0*([1-9])/\.\1/g; s/^0*//' >> "scfw3-combined";
	elif [[ "$list" == "turrissentinel.ipset" ]]; then
		#Download, skip first two lines, filter first column, strip IPv6 addresses + comments + whitespace
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "$url" | tail -n +3 | sed 's/,.*//' | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> "scfw3-combined";
	elif [[ "$list" == "vpn_a.ipset" ]]; then
		#Download, strip in-line comments, strip IPv6 addresses + comments + whitespace
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "$url" | sed 's/ # .*//' | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> "scfw3-combined";
	elif [[ "$list" == "vpn_l.ipset" ]]; then
		#Download, skip first line, filter first column, strip IPv6 addresses + comments + whitespace
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "$url" | tail -n +2 | sed 's/,.*//' | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> "scfw3-combined";
	else
		#Download, strip IPv6 addresses + comments + whitespace
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "$url" | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> "scfw3-combined";
	fi;
}

importCountryList() {
	countryCode="$1";
	importList country-block-v4-"$countryCode" "https://www.ipdeny.com/ipblocks/data/aggregated/$countryCode-aggregated.zone";
	#importList country-block-v6-"$countryCode" "https://www.ipdeny.com/ipv6/ipaddresses/blocks/$countryCode.zone" true;
}

prepareExclusions() {
	#rm -f exclusions.grep exclusions.txt;
	if [ "$SCFW_BLOCK_TOR" = false ] && [ "$SCFW_EXCLUDE_TOR" = true ]; then
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "https://iplists.firehol.org/files/tor_exits.ipset" | grep -v '^#' >> exclusions.txt;
	fi;
	if [ "$SCFW_BLOCK_VPN" = false ] && [ "$SCFW_EXCLUDE_VPN" = true ]; then
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "https://github.com/az0/vpn_ip/raw/main/data/output/ip.txt" | sed 's/ # .*//' | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> exclusions.txt;
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "https://github.com/Lars-/PIA-servers/raw/master/export.csv" | tail -n +2 | sed 's/,.*//' | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> exclusions.txt;
		/usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 -O - "https://github.com/X4BNet/lists_vpn/raw/main/output/vpn/ipv4.txt" | grep -v -e ":" -e '^#' -e '^[[:space:]]*$' >> exclusions.txt;
	fi;
	if [ -f exclusions.txt ]; then
		cat exclusions.txt | sed 's/\./\\./g' | sed 's/^/\^/' | sed 's/$/\$/' | sort -u > exclusions.grep;
		wc -l exclusions.grep;
	fi;
}

removeAllowedEntries() {
	wc -l "$1";
	if [ -f /tmp/scfw3/exclusions.grep ]; then
		if [ "$SCFW_EXCLUDE_TOR" = true ] || [ "$SCFW_EXCLUDE_VPN" = true ]; then
			mv "$1" "$1.orig";
			grep -v -f exclusions.grep "$1.orig" > "$1";
			rm "$1.orig";
			wc -l "$1";
		fi;
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
	prepareExclusions;

	#Download the lists
	for list in "${blockedLists[@]}"
	do
		if [[ "$list" == "cinscore.ipset" ]]; then
			importList "$list" "https://cinsscore.com/list/ci-badguys.txt";
		elif [[ "$list" == "cybercure.ipset" ]]; then
			importList "$list" "https://api.cybercure.ai/feed/get_ips?type=csv";
		elif [[ "$list" == "feodo.ipset" ]]; then
			importList "$list" "https://feodotracker.abuse.ch/downloads/ipblocklist.txt";
		elif [[ "$list" == "iblocklist_spyware.ipset" ]]; then
			importList "$list" "https://list.iblocklist.com/?list=llvtlsjyoyiczbkjsxpf&fileformat=cidr&archiveformat=gz";
		elif [[ "$list" == "ipsum-1.ipset" ]]; then
			importList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/1.txt";
		elif [[ "$list" == "ipsum-2.ipset" ]]; then
			importList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/2.txt";
		elif [[ "$list" == "ipsum-3.ipset" ]]; then
			importList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/3.txt";
		elif [[ "$list" == "ipsum-4.ipset" ]]; then
			importList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/4.txt";
		elif [[ "$list" == "ipthreat.ipset" ]]; then
			importList "$list" "https://lists.ipthreat.net/file/ipthreat-lists/threat/threat-30.txt.gz";
		elif [[ "$list" == "snort.ipset" ]]; then
			importList "$list" "https://snort.org/downloads/ip-block-list";
		elif [[ "$list" == "sslbl.ipset" ]]; then
			importList "$list" "https://sslbl.abuse.ch/blacklist/sslipblacklist.txt";
		elif [[ "$list" == "threatview.ipset" ]]; then
			importList "$list" "https://threatview.io/Downloads/IP-High-Confidence-Feed.txt";
		elif [[ "$list" == "turrissentinel.ipset" ]]; then
			importList "$list" "https://view.sentinel.turris.cz/greylist-data/greylist-latest.csv";
		elif [[ "$list" == "voipbl.ipset" ]]; then
			importList "$list" "https://voipbl.org/update";
		elif [[ "$list" == "vpn_a.ipset" ]]; then
			importList "$list" "https://github.com/az0/vpn_ip/raw/main/data/output/ip.txt";
		elif [[ "$list" == "vpn_l.ipset" ]]; then
			importList "$list" "https://github.com/Lars-/PIA-servers/raw/master/export.csv";
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
