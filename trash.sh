#!/bin/bash
#
#VERSION: 20250815-00
#
#Copyright (c) 2023-2025 Divested Computing Group
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

#Known bad, some sourced from BlockBotAddon (3-clause BSD license): https://git.friendi.ca/friendica/friendica-addons/src/branch/develop/blockbot/blockbot.php
badStrings=("360Spider" "7Siters/" "adscanner/" "AHC/" "AhrefsBot/" "ALittle Client" "AwarioRssBot/" "AwarioSmartBot/" "axios/" "Barkrowler/" "BLEXBot/" "BoardReader Favicon Fetcher" "brainstorm" "Cliqzbot/" "Cloud mapping experiment" "CrowdTanglebot/" "datagnionbot" "dataminr\.com" "Datanyze" "Dataprovider\.com" "dcrawl/" "DecompilationBot/" "Diffbot/" "DNSResearchBot/" "DomainStatsBot/" "DotBot/" "EdgeWatch/" "Embed PHP library" "evc-batch/" "Exabot/" "FemtosearchBot/" "FunWebProducts" "GetHPinfo\.com-Bot/" "GigablastOpenSource/" "Google-Adwords-Instant" "Hatena-Favicon/" "heritrix/" "HTTP Banner Detection" "HubSpot Crawler" "IndieWebCards/" "InfoTigerBot/" "InternetMeasurement/" "Jooblebot/" "kirkland-signature" "KOCMOHABT" "ldspider" "linkdexbot/" "linkfluence\.com" "LivelapBot/" "ltx71" "Lucifer Search Bot" "lychee/" "Mediapartners-Google" "Mediatoolkitbot" "Mediumbot-MetaTagFetcher/" "MegaIndex\.ru/" "MetaInspector/" "MJ12bot/" "NetcraftSurveyAgent/" "netEstate NE Crawler" "newspaper/" "Nextcloud Server Crawler" "Nimbostratus-Bot/" "Nuzzel" "oBot/" "onionlandsearchengine/" "opensiteexplorer" "PaperLiBot/" "pdrlabs" "PetalBot;" "Pinterestbot/" "proximic;" "Qwantify/Bleriot/" "Re-re Studio" "SaaSHub" "SabsimBot/" "Scrapy/" "SeekportBot;" "Seekport Crawler;" "Semanticbot/" "SemrushBot" "SemrushBot-BA;" "SEOkicks;" "s~feedly-nikon3" "SMTBot/" "SMUrlExpander" "Snacktory" "Sogou web spider/" "Spawning-AI" "startmebot/" "StractBot/" "SummalyBot/" "SurdotlyBot/" "TrendsmapResolver/" "TweetmemeBot/" "um-LN/" "Wappalyzer" "WbSrch/" "webprosbot/" "woorankreview/" "WordPress/" "wpif" "XoviOnpageCrawler;" "YaK/" "Yeti/" "YisouSpider" "YurichevBot/" "ZaldamoSearchBot" "zgrab/" "zoominfobot" "fidget-spinner-bot" "Timpibot/" "AntBot" "test-bot" "2ip bot/" "Bytespider;");

badStrings+=(" \"Magellan\"$" " \"undici\"$");
badStrings+=("compatible; Optimizer");

#"All" bots
#badStrings+=("bot/" "bot;");

#AI crawlers
#Credit: ai.robots.txt, License: MIT, ff9fc264041ba06d1f4d4f46834ee73e35efc792
#https://github.com/ai-robots-txt/ai.robots.txt/blob/main/robots.txt
badStrings+=("AddSearchBot" "AI2Bot" "Ai2Bot-Dolma" "aiHitBot" "Amazonbot/" "Andibot" "anthropic-ai" "bedrockbot" "bigsur\.ai" "Brightbot 1.0" "ChatGPT Agent" "ChatGPT-User" "ClaudeBot/" "Claude-SearchBot" "Claude-User" "Claude-Web" "CloudVertexBot" "cohere-ai" "cohere-training-data-crawler" "Cotoyogi" "Crawlspace" "Datenbank Crawler" "Echobot Bot" "EchoboxBot" "Factset_spyderbot" "FirecrawlAgent" "FriendlyCrawler" "Gemini-Deep-Research" "GoogleAgent-Mariner" "Google-CloudVertexBot" "GPTBot/" "iaskspider/2.0" "ICC-Crawler" "ImagesiftBot" "img2dataset" "ISSCyberRiskCrawler" "Kangaroo Bot" "LinerBot" "Meta-ExternalAgent/" "MistralAI-User" "MyCentralAIScraperBot" "netEstate Imprint Crawler" "NovaAct" "OAI-SearchBot" "omgilibot" "PanguBot" "Panscient" "panscient\.com" "PerplexityBot" "Perplexity-User" "PhindBot" "Poseidon Research Crawler" "QualifiedBot" "QuillBot" "quillbot\.com" "SBIntuitionsBot" "SemrushBot-OCOB" "SemrushBot-SWA" "Sidetrade indexer bot" "Thinkbot" "VelenPublicWebCrawler" "WARDBot" "Webzio-Extended" "YouBot");

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

#Honeypot
badStrings+=("/mishka_has_a_nice_tree"); #pages
badStrings+=("/mishka_is_very_talented"); #robots.txt

#Outdated macOS, https://endoflife.date/macos
for version in {1..14} #macOS 10.14 was EOL 2021/10/25
do
	badStrings+=("Macintosh; Intel Mac OS X 10_$version""_");
done

#Outdated iOS, https://endoflife.date/ios
for version in {1..14} #iOS 14 was EOL 2021/10/01
do
	badStrings+=("iPhone OS $version""_");
done

#Outdated Chromium, https://chromiumdash.appspot.com/schedule
for version in {1..130} #Chrome 130 reached stable on 2024/10/15
do
	#Exclude:
	#LTS: 126
	#49: last version for Windows XP/Vista
	#81: last version for Android KitKat (4), https://groups.google.com/a/chromium.org/g/chromium-dev/c/p1nOzmB2zig
	#95: last version for Android Lolipop (5), https://groups.google.com/a/chromium.org/g/chromium-dev/c/2MwR9KqwY9I
	#106: last version for Android Marshmallow (6), https://groups.google.com/a/chromium.org/g/chromium-dev/c/z_RvoPoIeoM
	#109: last version for Windows 7/8
	#119: last version for Android Nougat (7), https://groups.google.com/a/chromium.org/g/chromium-dev/c/B9AYI3WAvRo
	#138: last version for Android Oreo (8) & Pie (9), https://groups.google.com/a/chromium.org/g/chromium-dev/c/vEZz0721rUY
	if [[ $version != "126" ]] && [[ $version != "49" ]] && [[ $version != "81" ]] && [[ $version != "95" ]] && [[ $version != "106" ]] && [[ $version != "109" ]] && [[ $version != "119" ]] && [[ $version != "138" ]]; then
		badStrings+=("Chrome/$version\.0\.");
	fi;
done

#Outdated Firefox, https://whattrainisitnow.com/calendar/
for version in {1..130} #Firefox 130 reached stable on 2024/09/03
do
	#Exclude:
	#Next ESR: 140
	#Current ESR: 128
	#Previous two ESR: 115, 102
	#115: last version for Windows 7/8, https://support.mozilla.org/en-US/kb/firefox-users-windows-7-8-and-81-moving-extended-support
	#68: last version for Android KitKat (4)
	#52: last version for Windows XP/Vista, https://support.mozilla.org/en-US/kb/end-support-windows-xp-and-vista
	if [[ $version != "140" ]] && [[ $version != "128" ]] && [[ $version != "115" ]] && [[ $version != "102" ]] && [[ $version != "68" ]] && [[ $version != "52" ]]; then
		badStrings+=("Firefox/$version\.0");
	fi;
done

#Generate the pattern file
rm /tmp/trash-patterns.grep &>/dev/null || true;
for badString in "${badStrings[@]}"
do
	echo "$badString" >> /tmp/trash-patterns.grep;
done

#Search for the trash in Apache logs
if [ -d "/var/log/httpd/" ]; then
	#Filter out known bad patterns
	mapfile -t -O "${#trash[@]}" trash < <( grep -a -i -f /tmp/trash-patterns.grep /var/log/httpd/access_log* -h | awk '{ print $1 } ' | sort -u );

	#Filter out all non HEAD & GET requests
	mapfile -t -O "${#trash[@]}" trash < <( grep -a -v -e "] \"GET " -e "] \"HEAD " /var/log/httpd/access_log* -h | awk '{ print $1 } ' | sort -u );
fi;

#Search for the trash in rsyncd logs
if [ -f "/var/log/rsyncd.log" ]; then
	mapfile -t -O "${#trash[@]}" trash < <( grep -a denied /var/log/rsyncd.log | awk '{ print $11 } ' | sort -u | sed 's/(//' | sed 's/)//' );
fi;

#Search for the trash in murmur logs
if [ -f "/usr/lib/systemd/system/murmur.service" ]; then
	#This relies on the built-in autoban mechanism being configured
	mapfile -t -O "${#trash[@]}" trash < <( journalctl -u murmur.service | grep -e " => Ignoring connection: " | awk '{ print $12 } ' | grep -v -e "<<" -e ">>" | sed 's/\(.*\):.*/\1 /' | sort -u );
fi;

#Search for the trash in sshd logs
if [ -f "/usr/lib/systemd/system/sshd.service" ]; then
	mapfile -t -O "${#trash[@]}" trash < <( journalctl -u sshd.service | grep -e "Invalid user" -e "Unable to negotiate with" -e "Disconnecting authenticating user root .* Too many authentication failures" | awk '{ print $10 } ' | sort -u );
	mapfile -t -O "${#trash[@]}" trash < <( journalctl -u sshd.service | grep -e "fatal: Timeout before authentication" -e "error: maximum authentication attempts exceeded" -e "Disconnected from authenticating user root" | awk '{ print $11 } ' | sort -u );
	mapfile -t -O "${#trash[@]}" trash < <( journalctl -u sshd.service | grep -e "Connection closed by authenticating user" | awk '{ print $12 } ' | sort -u );
fi;

#Return the trash
for rubbish in "${trash[@]}"
do
	if [[ $rubbish == *":"* ]]; then
		echo "$rubbish" >> /etc/trash-v6.ipset;
	elif [[ $rubbish == *"."* ]]; then
		echo "$rubbish" >> /etc/trash-v4.ipset;
	fi
done

#Ensure they exist, in case there is none of one
touch /etc/trash-v4.ipset;
touch /etc/trash-v6.ipset;

#Deduplicate
sort -u -o /etc/trash-v4.ipset /etc/trash-v4.ipset;
sort -u -o /etc/trash-v6.ipset /etc/trash-v6.ipset;

#Remove exclusions
if [ -f /etc/scfw-exclusions.grep ]; then
	if [ -f "/usr/lib/systemd/system/sshd.service" ]; then
		journalctl -u sshd.service | grep -e "Accepted keyboard-interactive/pam for root from " | awk '{ print $11 } ' | sort -u | sed 's/\./\\./g' | sed 's/^/\^/' | sed 's/$/\$/' >> /etc/scfw-exclusions.grep;
		sort -u -o /etc/scfw-exclusions.grep /etc/scfw-exclusions.grep;
	fi;

	mv /etc/trash-v4.ipset /etc/trash-v4.ipset.orig;
	mv /etc/trash-v6.ipset /etc/trash-v6.ipset.orig;

	grep -v -f /etc/scfw-exclusions.grep /etc/trash-v4.ipset.orig > /etc/trash-v4.ipset;
	grep -v -f /etc/scfw-exclusions.grep /etc/trash-v6.ipset.orig > /etc/trash-v6.ipset;

	rm /etc/trash-v4.ipset.orig /etc/trash-v6.ipset.orig;
fi;

#Fixups
sed -i '/^127\.0\.0\.1$/d' /etc/trash-v4.ipset;

#Print a count
wc -l /etc/trash-*.ipset

#Remove old lists+zone
firewall-cmd --delete-zone=trash --permanent || true;
firewall-cmd --permanent --delete-ipset="trash-v4" &>/dev/null || true;
firewall-cmd --permanent --delete-ipset="trash-v6" &>/dev/null || true;

#Setup the new zone
firewall-cmd --new-zone=trash --permanent || true;
firewall-cmd --zone=trash --set-target=DROP --permanent;

#Import the IPv4 ipset
firewall-cmd --permanent --new-ipset="trash-v4" --type=hash:net --option=maxelem=200000 --option=hashsize=16384 --option=family=inet;
firewall-cmd --permanent --ipset="trash-v4" --add-entries-from-file=/etc/trash-v4.ipset;
firewall-cmd --permanent --zone=trash --add-source=ipset:"trash-v4";

#Import the IPv6 ipset
firewall-cmd --permanent --new-ipset="trash-v6" --type=hash:net --option=maxelem=200000 --option=hashsize=16384 --option=family=inet6;
firewall-cmd --permanent --ipset="trash-v6" --add-entries-from-file=/etc/trash-v6.ipset;
firewall-cmd --permanent --zone=trash --add-source=ipset:"trash-v6";

#Reload to apply
time firewall-cmd --reload;
echo "[trash] Loaded";
