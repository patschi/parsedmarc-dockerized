#!/bin/bash
# Copyright 2020, Patrik Kernstock.

set -x

echo "## ELASTICSEARCH"
echo "Setting permissions..."
chmod g+rwx -R /usr/share/elasticsearch/data/
chgrp 0 -R /usr/share/elasticsearch/data/

echo "## NGINX"
echo "Checking nginx certs..."
cd /etc/nginx/ssl/
if [ ! -f "/etc/nginx/ssl/kibana.crt" ] || [ ! -f "/etc/nginx/ssl/kibana.key" ]; then
	echo "No certs found. Generating..."
	openssl req -x509 -nodes -days 365 -newkey rsa:3072 -keyout kibana.key -out kibana.crt \
		-subj "/CN=parsedmarc" -addext "subjectAltName=DNS:parsedmarc"
	echo "Certs generated."
fi

echo "## KIBANA"
exportFile="/etc/parsedmarc/kibana_export.ndjson"
if [ ! -f "${exportFile}" ]; then
	# trigger empty file to trigger below update logic.
	touch ${exportFile}
fi
echo "Downloading dashboard from GitHub..."
rm /etc/parsedmarc/kibana_export.ndjson.tmp
curl https://raw.githubusercontent.com/domainaware/parsedmarc/master/kibana/export.ndjson \
	-o /etc/parsedmarc/kibana_export.ndjson.tmp
if [ ${?} -ne 0 ]; then
	echo "Downloading kibana export failed."
else
	fileNew=$(wc -c "${exportFile}.tmp" | awk -F' ' '{ print $1 }')
	fileOld=$(wc -c "${exportFile}" | awk -F' ' '{ print $1 }')

	if [ "$fileNew" == "$fileOld" ]; then
		echo "File size is the same. Not proceeding."
	else
		echo "File size is different... updating..."

		while ! curl -s -f -I http://kibana:5601 >/dev/null; do
			echo "Kibana not responding... waiting 5 secs..."
			sleep 5
		done

		echo "Kibana responded. Waiting 10s, then proceeding with dashboard update..."
		sleep 10
		rm ${exportFile}
		mv ${exportFile}.tmp ${exportFile}
		RES=$(curl -X POST http://kibana:5601/api/saved_objects/_import?overwrite=true \
			-H "kbn-xsrf: true" --form file=@${exportFile})
		echo "Result: $RES"
		if [ ${?} -ne 0 ]; then
			echo "[!!!] Import might have failed. Manual check recommended."
		else
			# if the flag exists, we already set the defaultRoute once. So we don't do that again.
			if [ ! -f "/etc/parsedmarc/flag.defaultRouteSet" ]; then
				DEF_DASHBOARD_NAME="DMARC Summary"
				echo "Setting '${DEF_DASHBOARD_NAME}' dashboard as default route..."
				DEF_DASHBOARD_ID=$(cat "${exportFile}" | jq --arg DBNAME "${DEF_DASHBOARD_NAME}" 'select(.attributes.title == $DBNAME) | .id' | tr -d '"')
				if [ "$DEF_DASHBOARD_ID" != "" ]; then
					echo "Found dashboard ID: ${DEF_DASHBOARD_ID}"
					DEFAULT_ROUTE="/app/kibana#/dashboard/${DEF_DASHBOARD_ID}"
					echo "DefaultRoute being set to: ${DEFAULT_ROUTE}"
					curl -X POST -H "kbn-xsrf: true" -H "Content-Type: application/json" \
						"http://kibana:5601/api/kibana/settings/defaultRoute" \
						-d "{\"value\": \"${DEFAULT_ROUTE}\"}"
					if [ ${?} -ne 0 ]; then
						echo "[!!!] Setting defaultRoute seems to gone wrong. Manual check recommended."
					else
						echo "DefaultRoute set."
						echo "Notice: This might require a restart of Kibana to take effect. Not done automatically as part of this script."
						echo -e "# This is a flag to remember which defaultRoute we set in the past:\n${DEFAULT_ROUTE}" \
							> /etc/parsedmarc/flag.defaultRouteSet
					fi
				else
					echo "[!] Default dashboard with name '${DEF_DASHBOARD_NAME}' could not be found."
				fi
			fi
		fi
		echo "Dashboard import done."
	fi
fi

sleep 3

# Create empty file to let other containers know that we're ready.
touch /ready
sleep infinity # or while true; do sleep 86400; done

exit 0
