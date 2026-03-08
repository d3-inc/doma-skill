#!/bin/bash
# Usage: ./doma-dns-get.sh <domain_or_subdomain> [host]
# Requires: DOMA_API_KEY, curl, jq
#
# Example: ./doma-dns-get.sh software.ai
# Example: ./doma-dns-get.sh myname.software.ai
# Example: ./doma-dns-get.sh software.ai --host www

set -euo pipefail

NAME="${1:?Usage: doma-dns-get.sh <domain_or_subdomain> [host]}"
HOST_FILTER="${2:-}"
API_URL="${DOMA_API_URL:-https://api.doma.xyz}"
API_KEY="${DOMA_API_KEY:?Error: DOMA_API_KEY is required}"

# Parse domain — extract registered domain and subdomain part
IFS='.' read -ra PARTS <<< "$NAME"
PART_COUNT=${#PARTS[@]}

if [ "$PART_COUNT" -gt 2 ]; then
  REGISTERED_DOMAIN="${PARTS[$((PART_COUNT-2))]}.${PARTS[$((PART_COUNT-1))]}"
  SUBDOMAIN_PREFIX=""
  for ((i=0; i<PART_COUNT-2; i++)); do
    if [ -n "$SUBDOMAIN_PREFIX" ]; then
      SUBDOMAIN_PREFIX="$SUBDOMAIN_PREFIX."
    fi
    SUBDOMAIN_PREFIX="$SUBDOMAIN_PREFIX${PARTS[$i]}"
  done
  HOST="${HOST_FILTER:-$SUBDOMAIN_PREFIX}"
else
  REGISTERED_DOMAIN="$NAME"
  HOST="$HOST_FILTER"
fi

# Build GraphQL query
if [ -n "$HOST" ]; then
  VARIABLES='{"name":"'"$REGISTERED_DOMAIN"'","host":"'"$HOST"'"}'
else
  VARIABLES='{"name":"'"$REGISTERED_DOMAIN"'","host":null}'
fi

QUERY='{"query":"query($name:String!,$host:String){recordSets(name:$name,host:$host){items{host ttl type records}}}","variables":'"$VARIABLES"'}'

RESPONSE=$(curl -s -X POST "$API_URL/v1/graphql" \
  -H "Content-Type: application/json" \
  -H "Api-Key: $API_KEY" \
  -d "$QUERY")

ITEMS=$(echo "$RESPONSE" | jq '.data.recordSets.items')
COUNT=$(echo "$ITEMS" | jq 'length')

if [ "$COUNT" = "0" ] || [ "$ITEMS" = "null" ]; then
  echo "No DNS records found for $NAME."
  exit 0
fi

echo "DNS records for $NAME"
echo ""
printf "  %-8s %-20s %-40s %s\n" "Type" "Name" "Value" "TTL"
printf "  %-8s %-20s %-40s %s\n" "--------" "--------------------" "----------------------------------------" "------"

echo "$ITEMS" | jq -r '.[] | "\(.type)\t\(.host // "@")\t\(.records | join("; "))\t\(.ttl)"' | while IFS=$'\t' read -r TYPE REC_HOST VALUE TTL; do
  DISPLAY_NAME="$REC_HOST"
  if [ -n "${SUBDOMAIN_PREFIX:-}" ]; then
    if [ "$REC_HOST" = "$SUBDOMAIN_PREFIX" ]; then
      DISPLAY_NAME="@"
    elif [[ "$REC_HOST" == *".$SUBDOMAIN_PREFIX" ]]; then
      DISPLAY_NAME="${REC_HOST%.$SUBDOMAIN_PREFIX}"
    fi
  fi
  printf "  %-8s %-20s %-40s %s\n" "$TYPE" "$DISPLAY_NAME" "$VALUE" "$TTL"
done
