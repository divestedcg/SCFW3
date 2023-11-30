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
badStrings=("360Spider" "7Siters/" "adscanner/" "AHC/" "AhrefsBot/" "ALittle Client" "AwarioRssBot/" "AwarioSmartBot/" "axios/" "Barkrowler/" "BLEXBot/" "BoardReader Favicon Fetcher" "brainstorm" "Cliqzbot/" "Cloud mapping experiment" "CrowdTanglebot/" "datagnionbot" "dataminr\.com" "Datanyze" "Dataprovider\.com" "dcrawl/" "DecompilationBot/" "Diffbot/" "DNSResearchBot/" "DomainStatsBot/" "DotBot/" "EdgeWatch/" "Embed PHP library" "evc-batch/" "Exabot/" "FemtosearchBot/" "FunWebProducts" "GetHPinfo\.com-Bot/" "GigablastOpenSource/" "Google-Adwords-Instant" "Hatena-Favicon/" "heritrix/" "HTTP Banner Detection" "HubSpot Crawler" "IndieWebCards/" "InfoTigerBot/" "InternetMeasurement/" "Jooblebot/" "kirkland-signature" "KOCMOHABT" "ldspider" "linkdexbot/" "linkfluence\.com" "LivelapBot/" "ltx71" "Lucifer Search Bot" "lychee/" "Mediapartners-Google" "Mediatoolkitbot" "Mediumbot-MetaTagFetcher/" "MegaIndex\.ru/" "MetaInspector/" "MJ12bot/" "NetcraftSurveyAgent/" "netEstate NE Crawler" "newspaper/" "Nextcloud Server Crawler" "Nimbostratus-Bot/" "Nuzzel" "oBot/" "onionlandsearchengine/" "opensiteexplorer" "PaperLiBot/" "pdrlabs" "PetalBot;" "Pinterestbot/" "proximic;" "Qwantify/Bleriot/" "Re-re Studio" "SaaSHub" "SabsimBot/" "Scrapy/" "SeekportBot;" "Seekport Crawler;" "Semanticbot/" "SemrushBot" "SemrushBot-BA;" "SEOkicks;" "s~feedly-nikon3" "SMTBot/" "SMUrlExpander" "Snacktory" "Sogou web spider/" "Spawning-AI" "startmebot/" "StractBot/" "SummalyBot/" "SurdotlyBot/" "TrendsmapResolver/" "TweetmemeBot/" "um-LN/" "Wappalyzer" "WbSrch/" "webprosbot/" "woorankreview/" "WordPress/" "wpif" "XoviOnpageCrawler;" "YaK/" "Yeti/" "YisouSpider" "YurichevBot/" "ZaldamoSearchBot" "zgrab/" "zoominfobot" "fidget-spinner-bot" "Timpibot/" "AntBot" "test-bot" "2ip bot/");

badStrings+=(" \"Magellan\"$" " \"undici\"$");
badStrings+=("compatible; Optimizer");

#"All" bots
#badStrings+=("bot/" "bot;");

#Search Engines
#badStrings+=("Applebot/" "Baiduspider/" "bingbot/" "BingPreview/" "coccocbot-image/" "DuckDuckBot-Https/" "DuckDuckGo-Favicons-Bot/" "Googlebot/" "Googlebot-Image/" "Google Favicon" "GoogleImageProxy" "GoogleOther" "Google-SearchByImage" "https://developers\.google\.com/+/web/snippet/" "MojeekBot/" "Qwantify/" "Qwantify-prod/" "SeznamBot/" "yacybot" "Y!J-DLC/" "YandexBot/" "YandexFavicons/" "YandexImages/");

#Social Media
#badStrings+=("Akkoma" "Discordbot/" "facebookexternalhit/" "Friendica" "github-camo" "Mastodon/" "matrix-media-repo" "Misskey/" "MisskeyMediaProxy/" "Pleroma " "SkypeUriPreview Preview/" "Slackbot " "Slackbot-LinkExpanding" "Synapse " "TelegramBot" "Twitterbot/" "Viber/" "WhatsApp/" "XenForo/");

#Archival
#badStrings+=("archive\.org_bot" "ArchiveTeam ArchiveBot/" "CCBot/" "Crawling at Home Project");
badStrings+=("httrack");

#Monitors
#badStrings+=("huginn/huginn" "urlwatch/");
#badStrings+=("hstspreload-bot" "Do Not Track Verifier");
#badStrings+=("DowntimeDetector/" "isitup\.org");

#Readers
#badStrings+=("Tiny Tiny RSS/" "android:com\.laurencedawson.\reddit_sync" "android:io.syncapps.lemmy_sync" "Notion/" "ReadYou / ");

#Other Allowed
#badStrings+=("xarantolus/filtrite-list");
#badStrings+=("Hypatia");
#badStrings+=("com\.machiav3lli\.fdroid-" "com\.machiav3lli.\fdroid\.neo-");
#badStrings+=("pfSense/pfBlockerNG");

#Generic
#badStrings+=("aria2/" "curl/" "uclient-fetch" "wget/");
#badStrings+=("Dart/" "Ktor client" "okhttp/");
#badStrings+=("CFNetwork/"); #TODO: check more
badStrings+=("aiohttp/" "Apache-HttpAsyncClient/" "Apache-HttpClient/" "go-http-client/" "Google-Apps-Script; beanserver;" "httpunit" "libwww-perl/" "php-curl-class/" "powershell/" "python-requests/" "python-urllib/" "python-urllib3/" "sindresorhus/got");
badStrings+=("analytics" "crawler" "headless" "HeadlessChrome" "PhantomJS/" "scraper" "selenium" "spider" "webdriver");

#Unset UA
badStrings+=(" \"-\"$");

#Security Scanners
badStrings+=("CensysInspect/" "masscan/" "Nmap Scripting Engine;" "paloaltonetwork");

#Malware
badStrings+=("jndi:ldap:");
badStrings+=("cpuminer/" "MinerName/" "XMRig/" "xmr-stak-cpu/");
badStrings+=(" \"xfa1\"$");

#Internet Explorer, EOL since 2022/06/15, replaced by Edge in 2015
badStrings+=("Trident/");

#Other
badStrings+=(" \.NET CLR ");
badStrings+=("Mozilla/4\.0" " \"Mozilla/5\.0\"$" " \"Mozilla/5\.0 (compatible)\"$");
badStrings+=("QR Scanner Android");
badStrings+=("/wp-login\.php");

#Outdated macOS, https://endoflife.date/macos
for version in {1..12} #macOS 10.12 was EOL 2019/10/01
do
	badStrings+=("Macintosh; Intel Mac OS X 10_$version""_");
done

#Outdated iOS, https://endoflife.date/ios
for version in {1..13} #iOS 13 was EOL 2020/09/16
do
	if [[ $version != "12" ]]; then
		badStrings+=("iPhone OS $version""_");
	fi;
done

#Outdated Chromium, https://chromiumdash.appspot.com/schedule
for version in {1..100} #Chrome 101 reached stable on 2022/04/26
do
	#Exclude:
	#108: last version of popular Bromite
	#81: last version for Android KitKat, https://groups.google.com/a/chromium.org/g/chromium-dev/c/p1nOzmB2zig
	#95: last version for Android Lolipop, https://groups.google.com/a/chromium.org/g/chromium-dev/c/2MwR9KqwY9I
	#106: last version for Android Marshmallow, https://groups.google.com/a/chromium.org/g/chromium-dev/c/z_RvoPoIeoM
	#119: last version for Android Nougat, https://groups.google.com/a/chromium.org/g/chromium-dev/c/B9AYI3WAvRo
	if [[ $version != "108" ]] && [[ $version != "81" ]] && [[ $version != "95" ]] && [[ $version != "106" ]] && [[ $version != "119" ]]; then
		badStrings+=("Chrome/$version\.0\.");
	fi;
done

#Outdated Firefox, https://whattrainisitnow.com/calendar/
for version in {1..100} #Firefox 101 reached stable on 2022/05/31
do
	#Exclude:
	#Next ESR: 128
	#Current ESR: 115
	#Previous two ESR: 102, 91
	#115: last version for Windows 7/8, https://support.mozilla.org/en-US/kb/firefox-users-windows-7-8-and-81-moving-extended-support
	#68: last version for Android KitKat
	#52: last version for Windows XP/Vista, https://support.mozilla.org/en-US/kb/end-support-windows-xp-and-vista
	if [[ $version != "128" ]] && [[ $version != "115" ]] && [[ $version != "102" ]] && [[ $version != "91" ]] && [[ $version != "68" ]] && [[ $version != "52" ]]; then #
		badStrings+=("Firefox/$version\.0");
	fi;
done

#Search for the trash
for badString in "${badStrings[@]}"
do
	mapfile -t -O "${#trash[@]}" trash < <( grep -i "$badString" /var/log/httpd/access_log* -h | awk '{ print $1 } ' | sort | uniq );
done

#Filter out all non HEAD & GET requests
mapfile -t -O "${#trash[@]}" trash < <( grep -v -e "] \"GET " -e "] \"HEAD " /var/log/httpd/access_log* -h | awk '{ print $1 } ' | sort | uniq );

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
