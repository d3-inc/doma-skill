#!/bin/bash
# Usage: ./doma-subdomain-list.sh <domain>
# Requires: DOMA_API_KEY, curl, jq
#
# Example: ./doma-subdomain-list.sh software.ai

set -euo pipefail

DOMAIN="${1:?Usage: doma-subdomain-list.sh <domain>}"
API_URL="${DOMA_API_URL:-https://api.doma.xyz}"
API_KEY="${DOMA_API_KEY:?Error: DOMA_API_KEY is required}"

QUERY='{"query":"query($parentDomain:String,$take:Int){subdomains(parentDomain:$parentDomain,take:$take){items{tokenId name host ownerAddress createdAt fractionalizationInfo{stakedAmount fractionalTokenAddress}}totalCount}}","variables":{"parentDomain":"'"$DOMAIN"'","take":50}}'

RESPONSE=$(curl -s -X POST "$API_URL/v1/graphql" \
  -H "Content-Type: application/json" \
  -H "Api-Key: $API_KEY" \
  -d "$QUERY")

TOTAL=$(echo "$RESPONSE" | jq -r '.data.subdomains.totalCount // 0')
ITEMS=$(echo "$RESPONSE" | jq '.data.subdomains.items')

if [ "$TOTAL" = "0" ] || [ "$ITEMS" = "null" ]; then
  echo "No subdomains found for $DOMAIN."
  exit 0
fi

echo "Subdomains for $DOMAIN ($TOTAL total)"
echo ""

echo "$ITEMS" | jq -r '.[] | {
  name: (if .host then "\(.host).\(.name)" else .name end),
  owner: (.ownerAddress | split(":") | last | "\(.[0:6])...\(.[-4:])"),
  staked: (.fractionalizationInfo.stakedAmount // "N/A")
} | "  \(.name)\t owner=\(.owner)\t staked=\(.staked)"' | while IFS= read -r line; do
  echo "$line"
done
