#!/bin/bash
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
if [ ! -f /etc/parsedmarc/kibana_export.ndjson ]; then
	# trigger empty file to trigger below update logic.
	touch /etc/parsedmarc/kibana_export.ndjson
fi
echo "Downloading dashboard from GitHub..."
rm /etc/parsedmarc/kibana_export.ndjson.tmp
curl https://raw.githubusercontent.com/domainaware/parsedmarc/master/kibana/export.ndjson \
	-o /etc/parsedmarc/kibana_export.ndjson.tmp
if [ ${?} -ne 0 ]; then
	echo "Downloading kibana export failed."
else
	fileNew=$(wc -c "/etc/parsedmarc/kibana_export.ndjson.tmp") # always use quoted var
	fileOld=$(wc -c "/etc/parsedmarc/kibana_export.ndjson")

	if [ $fileNew -eq $fileOld ]; then
		echo "File size is the same. Not proceeding."
	else
		echo "File size is different... updating..."
	
		while ! curl -s -f -I http://kibana:5601 >/dev/null; do
			echo "Kibana not responding... waiting 5 secs..."
			sleep 5
		done

		echo "Kibana responded. Waiting 10s, then proceeding with dashboard update..."
		sleep 10
		rm /etc/parsedmarc/kibana_export.ndjson
		mv /etc/parsedmarc/kibana_export.ndjson.tmp /etc/parsedmarc/kibana_export.ndjson
		RES=$(curl -X POST http://kibana:5601/api/saved_objects/_import?overwrite=true \
			-H "kbn-xsrf: true" --form file=@/etc/parsedmarc/kibana_export.ndjson)
		echo "Result: $RES"
		if [ ${?} -ne 0 ]; then
			echo "[!!!] Import might have failed. Manual check recommended."
		fi
		echo "Importing done."
	fi
fi

sleep 3
# Create empty file to let other containers know that we're ready.
touch /ready
sleep infinity # or while true; do sleep 86400; done
exit 0
