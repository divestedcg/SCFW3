#!/bin/bash
#Copyright (c) 2023 Divested Computing Group
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

#Known bad, some sourced from BlockBotAddon (3-clause BSD license): https://git.friendi.ca/friendica/friendica-addons/src/branch/develop/blockbot/blockbot.php
badStrings=("360Spider" "7Siters/" "adscanner/" "AHC/" "AhrefsBot/" "AwarioRssBot/" "AwarioSmartBot/" "BLEXBot/" "BoardReader Favicon Fetcher" "brainstorm" "Cliqzbot/" "Cloud mapping experiment" "CrowdTanglebot/" "datagnionbot" "Datanyze" "Dataprovider.com" "dcrawl/" "Diffbot/" "DNSResearchBot/" "DomainStatsBot/" "DotBot/" "Embed PHP library" "evc-batch/" "Exabot/" "FemtosearchBot/" "FunWebProducts" "GetHPinfo.com-Bot/" "Google-Adwords-Instant" "Hatena-Favicon/" "heritrix/" "HTTP Banner Detection" "HubSpot Crawler" "IndieWebCards/" "InfoTigerBot/" "InternetMeasurement/" "Jooblebot/" "KOCMOHABT" "ldspider" "linkdexbot/" "LivelapBot/" "ltx71" "Mediapartners-Google" "Mediatoolkitbot" "Mediumbot-MetaTagFetcher/" "MegaIndex.ru/" "MJ12bot/" "NetcraftSurveyAgent/" "netEstate NE Crawler" "newspaper/" "Nimbostratus-Bot/" "Nuzzel" "oBot/" "opensiteexplorer" "PaperLiBot/" "PetalBot;" "pdrlabs" "Pinterestbot/" "proximic" "Qwantify/Bleriot/" "Re-re Studio" "SabsimBot/" "Scrapy/" "Seekport Crawler;" "Semanticbot/" "SemrushBot" "s~feedly-nikon3" "SMTBot/" "SMUrlExpander" "Snacktory" "Sogou web spider/" "startmebot/" "StractBot/" "SummalyBot/" "SurdotlyBot/" "TrendsmapResolver/" "TweetmemeBot/" "um-LN/" "Wappalyzer" "WbSrch/" "woorankreview/" "wpif" "XoviOnpageCrawler;" "YaK/" "YisouSpider" "YurichevBot/" "zgrab/" "zoominfobot");

#"All" bots
#badStrings+=("bot/" "bot;");

#Search Engines
#badStrings+=("Applebot/" "Baiduspider/" "bingbot/" "BingPreview/" "DuckDuckBot-Https/" "DuckDuckGo-Favicons-Bot/" "Googlebot/" "Googlebot-Image/" "Google Favicon" "GoogleImageProxy" "Google-SearchByImage" "https://developers.google.com/+/web/snippet/" "SeznamBot/" "yacybot" "YandexBot/" "YandexImages/");

#Social Media
#badStrings+=("Akkoma" "facebookexternalhit/" "github-camo" "Mastodon/" "Pleroma" "SkypeUriPreview Preview/" "Synapse" "TelegramBot" "Twitterbot/" "WhatsApp/" "XenForo/");

#Archival
#badStrings+=("archive.org_bot" "ArchiveTeam ArchiveBot/" "CCBot/" "Crawling at Home Project");

#Monitors
#badStrings+=("urlwatch/");

#Generic
#badStrings+=("curl/" "uclient-fetch" "wget/");
#badStrings+=("Dart/" "Ktor client" "okhttp/");
badStrings+=("aiohttp/" "analytics" "apache-httpclient/" "crawler" "go-http-client/" "Google-Apps-Script; beanserver;" "headless" "HeadlessChrome" "httpunit" "httrack" "libwww-perl/" "PhantomJS/" "php-curl-class/" "powershell/" "python-requests/" "python-urllib/" "scraper" "selenium" "sindresorhus/got" "spider" "webdriver");

#Unset UA
badStrings+=(" \"-\"$");

#Security Scanners
badStrings+=("CensysInspect" "Nmap Scripting Engine;" "paloaltonetwork");

#Malware
badStrings+=("jndi:ldap:");
badStrings+=("cpuminer/" "MinerName/" "XMRig/");

#Internet Explorer
badStrings+=("Trident/");

#Outdated macOS, https://endoflife.date/macos
for version in {1..13}
do
	badStrings+=("Macintosh; Intel Mac OS X 10_$version""_");
done

#Outdated iOS, https://endoflife.date/ios
for version in {1..14}
do
	if [[ $version != "12" ]]; then
		badStrings+=("iPhone OS $version""_");
	fi;
done

#Outdated Chromium, https://chromiumdash.appspot.com/schedule
for version in {1..113}
do
	badStrings+=("Chrome/$version\.0\.");
done

#Outdated Firefox, https://whattrainisitnow.com/calendar/
for version in {1..113}
do
	if [[ $version != "128" ]] && [[ $version != "115" ]] && [[ $version != "102" ]]; then #exclude ESR
		badStrings+=("Firefox/$version\.0");
	fi;
done

#Search for the trash
for badString in "${badStrings[@]}"
do
	mapfile -t -O "${#trash[@]}" trash < <( grep -i "$badString" /var/log/httpd/access_log* -h | awk '{ print $1 } ' | sort | uniq );
done

#Return the trash
for rubbish in "${trash[@]}"
do
	if [[ $rubbish == *":"* ]]; then
		echo "$rubbish" >> /etc/trash-v6.ipset;
	else
		echo "$rubbish" >> /etc/trash-v4.ipset;
	fi
done

#Deduplicate
sort -u -o /etc/trash-v4.ipset /etc/trash-v4.ipset;
sort -u -o /etc/trash-v6.ipset /etc/trash-v6.ipset;

#Fixups
sed -i '/127.0.0.1/d' /etc/trash-v4.ipset;

#Print a count
wc -l /etc/trash-*.ipset

#Setup the zone
firewall-cmd --delete-zone=trash --permanent || true;
firewall-cmd --reload;
firewall-cmd --new-zone=trash --permanent || true;
firewall-cmd --zone=trash --set-target=DROP --permanent;
firewall-cmd --reload;

#Import the IPv4 ipset
firewall-cmd --permanent --delete-ipset="trash-v4" &>/dev/null || true;
firewall-cmd --permanent --new-ipset="trash-v4" --type=hash:net --option=maxelem=200000 --option=hashsize=16384 --option=family=inet;
firewall-cmd --permanent --ipset="trash-v4" --add-entries-from-file=/etc/trash-v4.ipset;
firewall-cmd --permanent --zone=trash --add-source=ipset:"trash-v4";

#Import the IPv6 ipset
firewall-cmd --permanent --delete-ipset="trash-v6" &>/dev/null || true;
firewall-cmd --permanent --new-ipset="trash-v6" --type=hash:net --option=maxelem=200000 --option=hashsize=16384 --option=family=inet6;
firewall-cmd --permanent --ipset="trash-v6" --add-entries-from-file=/etc/trash-v6.ipset;
firewall-cmd --permanent --zone=trash --add-source=ipset:"trash-v6";

#Deploy
firewall-cmd --reload;
