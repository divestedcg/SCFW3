#!/bin/bash
#
#VERSION: 20260915-02
#
#Copyright (c) 2021-2026 Divested Computing Group
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

export SCFW_BLOCK_PROXY=true; #Junk proxies
export SCFW_BLOCK_TOR=false; #Tor exits and other nodes
export SCFW_BLOCK_VPN=false; #Common VPN providers
export SCFW_EXCLUDE_TOR=true; #Explicitly exempt Tor nodes
export SCFW_EXCLUDE_VPN=true; #Explicitly exempt common VPN providers

#Lists
#<10k entries
blockedLists+=('bds_atif.ipset');
blockedLists+=('bitcoin_nodes.ipset');
blockedLists+=('botvrij_dst.ipset');
blockedLists+=('bruteforceblocker.ipset');
#blockedLists+=('cidr_report_bogons.netset'); #broken sometimes
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
if [ "$SCFW_BLOCK_PROXY" = true ]; then blockedLists+=('socks_proxy_30d.ipset'); fi;
blockedLists+=('spamhaus_drop.netset');
blockedLists+=('spamhaus_edrop.netset');
if [ "$SCFW_BLOCK_PROXY" = true ]; then blockedLists+=('sslproxies_30d.ipset'); fi;
blockedLists+=('stopforumspam_7d.ipset');
blockedLists+=('threatview.ipset');
blockedLists+=('turrissentinel.ipset');
if [ "$SCFW_BLOCK_VPN" = true ]; then blockedLists+=('vpn_x.ipset'); fi;
blockedLists+=('vxvault.ipset');
if [ "$SCFW_BLOCK_PROXY" = true ]; then blockedLists+=('xroxy_30d.ipset'); fi;
if [ "$SCFW_BLOCK_TOR" = true ]; then blockedLists+=('dm_tor.ipset' 'et_tor.ipset' 'iblocklist_onion_router.netset' 'tor_exits.ipset'); fi;
blockedLists+=('anubis_alibaba_cloud.ipset' 'anubis_huawei_cloud.ipset');
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

#Internal settings
aggregator="/usr/local/bin/ip-aggregator.py";
resultList="$(mktemp)";
exclusionPatternsTmp="$(mktemp)";
exclusionPatterns="/etc/scfw-exclusions.grep";

safeDownloader() {
	#TODO: fix hsts
	sudo -u nobody /usr/bin/wget -4 --dns-timeout=5 --connect-timeout=15 --read-timeout=60 --quiet --no-local-db --no-use-server-timestamps "$@"
}

genericCleanLine() {
	#strip IPv6 addresses + comments + whitespace + hyphenated ranges
	grep -v -e ":" -e '^#' -e '^[[:space:]]*$' -e "-" "$@"
}

validateLineV4() {
	grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(/[0-9]{1,2})?$'
}

mergeList() {
	local list="$1";
	local url="$2";
	local tmpListRaw;
	tmpListRaw="/tmp/scfw3-list_raw-$RANDOM-$(date +%s%N)";
	local tmpListProcessed;
	tmpListProcessed="$(mktemp)";
	if safeDownloader -O "$tmpListRaw" "$url"; then
		if [ "$(stat -c%s "$tmpListRaw")" -lt "33554432" ]; then
			#Credit (CC BY-SA 4.0): https://stackoverflow.com/a/3432574
			#Credit (CC BY-SA 4.0): https://stackoverflow.com/a/60741627
			if [[ "$list" == "anubis_alibaba_cloud.ipset" ]] || [[ "$list" == "anubis_huawei_cloud.ipset" ]]; then
				#filter, generic
				grep "    - " "$tmpListRaw" | sed 's/.*- //' | genericCleanLine | validateLineV4 >> "$tmpListProcessed";
			elif [[ "$list" == "iblocklist_spyware.ipset" ]]; then
				#decompress, generic
				zcat "$tmpListRaw" | genericCleanLine | validateLineV4 >> "$tmpListProcessed";
			elif [[ "$list" == "ipthreat.ipset" ]]; then
				#decompress, filter first column, generic
				zcat "$tmpListRaw" | awk '{print $1}' | genericCleanLine | validateLineV4 >> "$tmpListProcessed";
			elif [[ "$list" == "threatview.ipset" ]]; then
				#generic, strip leading zeroes in addresses
				genericCleanLine "$tmpListRaw" | sed -E 's/\.0*([1-9])/\.\1/g; s/^0*//' | validateLineV4 >> "$tmpListProcessed";
			elif [[ "$list" == "turrissentinel.ipset" ]]; then
				#skip first two lines, filter first column, generic
				tail -n +3 "$tmpListRaw" | sed 's/,.*//' | genericCleanLine | validateLineV4 >> "$tmpListProcessed";
			elif [[ "$list" == "vpn_a.ipset" ]]; then
				#strip in-line comments, generic
				sed 's/ # .*//' "$tmpListRaw" | genericCleanLine | validateLineV4 >> "$tmpListProcessed";
			elif [[ "$list" == "vpn_l.ipset" ]]; then
				#skip first line, filter first column
				tail -n +2 "$tmpListRaw" | sed 's/,.*//' | genericCleanLine | validateLineV4 >> "$tmpListProcessed";
			elif [[ "$list" == "feodo.ipset" ]]; then
				#convert lines, generic
				cat "$tmpListRaw" | dos2unix | genericCleanLine | validateLineV4 >> "$tmpListProcessed";
			else
				#generic
				genericCleanLine "$tmpListRaw" | validateLineV4 >> "$tmpListProcessed";
			fi;
			if [ "$(stat -c%s "$tmpListProcessed")" -lt "4194304" ]; then
				cat "$tmpListProcessed" >> "$3";
				echo "Imported $(wc --lines --total=only "$tmpListProcessed") entries from $1 into $3";
			else
				echo "WARNING: Processed list from $2 exceeds 4MB size limit, ignoring it!";
			fi;
			rm -f "$tmpListProcessed";
		else
			echo "WARNING: Raw list from $2 exceeds 32MB size limit, ignoring it!";
		fi;
	else
		echo "ERROR: Failed to download list from $2";
	fi;
	rm -f "$tmpListRaw";
	unset list url tmpListRaw tmpListProcessed;
}

importCountryList() {
	local countryCode="$1";
	mergeList country-block-v4-"$countryCode" "https://www.ipdeny.com/ipblocks/data/aggregated/$countryCode-aggregated.zone" "$resultList";
	unset countryCode;
}

prepareExclusions() {
	local exclusionPatternsRawTmp;
	exclusionPatternsRawTmp="$(mktemp)";
	if [ "$SCFW_BLOCK_TOR" = false ] && [ "$SCFW_EXCLUDE_TOR" = true ]; then
		mergeList "tor_exits.ipset" "https://iplists.firehol.org/files/tor_exits.ipset" "$exclusionPatternsRawTmp"
	fi;
	if [ "$SCFW_BLOCK_VPN" = false ] && [ "$SCFW_EXCLUDE_VPN" = true ]; then
		mergeList "vpn_a.ipset" "https://az0-vpnip-public.oooninja.com/ip.txt" "$exclusionPatternsRawTmp";
		mergeList "vpn_l.ipset" "https://github.com/Lars-/PIA-servers/raw/master/export.csv" "$exclusionPatternsRawTmp";
		mergeList "vpn_x.ipset" "https://github.com/X4BNet/lists_vpn/raw/main/output/vpn/ipv4.txt" "$exclusionPatternsRawTmp";
	fi;
	if [ -f "$exclusionPatternsRawTmp" ]; then
		cat "$exclusionPatternsRawTmp" | sed 's/\./\\./g' | sed 's/^/\^/' | sed 's/$/\$/' | sort -u > "$exclusionPatternsTmp";
		rm -f "$exclusionPatternsRawTmp";
		echo "Entries in generated exclusion pattern file: $(wc --lines --total=only "$exclusionPatternsTmp")";
	fi;
	unset exclusionPatternsRawTmp;
}

removeAllowedEntries() {
	echo "Entries before removing exclusions: $(wc --lines --total=only "$1")";
	if [ -f "$exclusionPatternsTmp" ]; then
		if [ "$SCFW_EXCLUDE_TOR" = true ] || [ "$SCFW_EXCLUDE_VPN" = true ]; then
			mv "$1" "$1.orig";
			grep -v -f "$exclusionPatternsTmp" "$1.orig" > "$1";
			rm "$1.orig";
			echo "Entries after removing Tor & VPN exclusions: $(wc --lines --total=only "$1")";
		fi;
		rm -f "$exclusionPatternsTmp"
	fi;
	if [ -f "$exclusionPatterns" ]; then
		mv "$1" "$1.orig";
		grep -v -f "$exclusionPatterns" "$1.orig" > "$1";
		rm "$1.orig";
		echo "Entries after removing config exclusions: $(wc --lines --total=only "$1")";
	fi;
	if [ -f "$aggregator" ]; then
		mv "$1" "$1.orig";
		cat "$1.orig" | python3 "$aggregator" --stdin --quiet --sort > "$1";
		rm "$1.orig";
		echo "Entries after aggregation: $(wc --lines --total=only "$1")";
	fi;
}

checkAggregator() {
	local hash="ab462f35079646b25c4e0bdeb329d0c49b8a498a2a3efb8449ccafbab0ccb8edbd88e27e20b6875ee121384ffe337bb15741cc77fc2d3a79de03518640f60d4f"
	if [ -f "$aggregator" ]; then
		if echo -n "$hash  $aggregator" | sha512sum --check --quiet; then
			return 0;
		else
			echo "ERROR: ip-aggregator.py found with invalid hash!"
			exit 1;
		fi
	else
		echo "ERROR: ip-aggregator.py not found!"
		exit 1;
	fi;
}

loadLists() {
	#Setup exclusions
	if [ ! -f "$exclusionPatterns" ]; then
		echo -e '^127\.0\.0\.1$\n^0\.0\.0\.0/8$\n^10\.0\.0\.0/8$\n^172\.16\.0\.0/12$\n^192\.168\.0\.0/16$\n^169\.254\.0\.0/16$\n^100\.64\.0\.0/10$\n^fd00::/7$\n^fd00::/8$\n^fe80::/10$' > "$exclusionPatterns";
	fi;
	prepareExclusions;

	#Download the lists
	for list in "${blockedLists[@]}"
	do
		if [[ "$list" == "anubis_alibaba_cloud.ipset" ]]; then
			mergeList "$list" "https://raw.githubusercontent.com/TecharoHQ/anubis/refs/heads/main/data/crawlers/alibaba-cloud.yaml" "$resultList";
		elif [[ "$list" == "anubis_huawei_cloud.ipset" ]]; then
			mergeList "$list" "https://raw.githubusercontent.com/TecharoHQ/anubis/refs/heads/main/data/crawlers/huawei-cloud.yaml" "$resultList";
		elif [[ "$list" == "cinscore.ipset" ]]; then
			mergeList "$list" "https://cinsscore.com/list/ci-badguys.txt" "$resultList";
		elif [[ "$list" == "feodo.ipset" ]]; then
			mergeList "$list" "https://feodotracker.abuse.ch/downloads/ipblocklist.txt" "$resultList";
		elif [[ "$list" == "iblocklist_spyware.ipset" ]]; then
			mergeList "$list" "https://list.iblocklist.com/?list=llvtlsjyoyiczbkjsxpf&fileformat=cidr&archiveformat=gz" "$resultList";
		elif [[ "$list" == "ipsum-1.ipset" ]]; then
			mergeList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/1.txt" "$resultList";
		elif [[ "$list" == "ipsum-2.ipset" ]]; then
			mergeList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/2.txt" "$resultList";
		elif [[ "$list" == "ipsum-3.ipset" ]]; then
			mergeList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/3.txt" "$resultList";
		elif [[ "$list" == "ipsum-4.ipset" ]]; then
			mergeList "$list" "https://github.com/stamparm/ipsum/raw/master/levels/4.txt" "$resultList";
		elif [[ "$list" == "ipthreat.ipset" ]]; then
			mergeList "$list" "https://lists.ipthreat.net/file/ipthreat-lists/threat/threat-30.txt.gz" "$resultList";
		elif [[ "$list" == "threatview.ipset" ]]; then
			mergeList "$list" "https://threatview.io/Downloads/IP-High-Confidence-Feed.txt" "$resultList";
		elif [[ "$list" == "turrissentinel.ipset" ]]; then
			mergeList "$list" "https://view.sentinel.turris.cz/greylist-data/greylist-latest.csv" "$resultList";
		elif [[ "$list" == "voipbl.ipset" ]]; then
			mergeList "$list" "https://voipbl.org/update" "$resultList";
		elif [[ "$list" == "vpn_a.ipset" ]]; then
			mergeList "$list" "https://az0-vpnip-public.oooninja.com/ip.txt" "$resultList";
		elif [[ "$list" == "vpn_l.ipset" ]]; then
			mergeList "$list" "https://github.com/Lars-/PIA-servers/raw/master/export.csv" "$resultList";
		elif [[ "$list" == "vpn_x.ipset" ]]; then
			mergeList "$list" "https://github.com/X4BNet/lists_vpn/raw/main/output/vpn/ipv4.txt" "$resultList";
		else
			mergeList "$list" "https://iplists.firehol.org/files/$list" "$resultList";
		fi;
	done;
	unset list;

	#Download the country lists
	for country in "${blockedCountries[@]}"
	do
		importCountryList "$country";
	done;
	unset country;

	#Cleanup
	sort -u -o "$resultList" "$resultList";
	removeAllowedEntries "$resultList";

	#Remove old lists+zone
	firewall-cmd --delete-zone=scfw --permanent &>/dev/null || true;
	firewall-cmd --permanent --delete-ipset="scfw3-combined" &>/dev/null || true;

	#Setup the new zone
	#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-setting_and_controlling_ip_sets_using_firewalld
	firewall-cmd --new-zone=scfw --permanent;
	firewall-cmd --zone=scfw --set-target=DROP --permanent;

	#Import the IPv4 ipset
	firewall-cmd --permanent --new-ipset="scfw3-combined" --type=hash:net --option=maxelem=600000 --option=hashsize=16384 --option=family=inet;
	firewall-cmd --permanent --ipset="scfw3-combined" --add-entries-from-file="$resultList";
	firewall-cmd --permanent --zone=scfw --add-source=ipset:"scfw3-combined";

	#Reload to apply
	time firewall-cmd --reload;
	echo "[SCFW3] Loaded";
}

#Just run as expected
checkAggregator;
loadLists;
mv "$resultList" "/tmp/scfw3-combined"; #save for review or other usage
