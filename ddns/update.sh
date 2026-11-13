#!/bin/sh
# Keeps a Cloudflare A record pointed at this host's public IP.
# Config comes from the environment (see .env.example).

: "${CF_API_TOKEN:?set CF_API_TOKEN}"
: "${CF_ZONE_ID:?set CF_ZONE_ID}"
: "${CF_RECORD_ID:?set CF_RECORD_ID}"
: "${CF_RECORD_NAME:?set CF_RECORD_NAME}"
INTERVAL="${DDNS_INTERVAL:-300}"

while true
do
  PUBLIC_IP=$(curl -s --max-time 15 ifconfig.me)
  echo "Running update from IP ${PUBLIC_IP} at $(date)"

  if [ -n "$PUBLIC_IP" ]; then
    curl -s --max-time 30 --request PUT \
      --url "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records/${CF_RECORD_ID}" \
      --header "Content-Type: application/json" \
      --header "Authorization: Bearer ${CF_API_TOKEN}" \
      --data "{\"type\":\"A\",\"name\":\"${CF_RECORD_NAME}\",\"content\":\"${PUBLIC_IP}\",\"ttl\":3600,\"proxied\":true}"
    echo
  else
    echo "Could not determine public IP; skipping update"
  fi

  echo "Sleeping for ${INTERVAL} seconds..."
  sleep "$INTERVAL"
done
