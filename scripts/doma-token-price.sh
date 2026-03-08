#!/bin/bash
# Usage: ./doma-token-price.sh <token_name>
# Requires: DOMA_API_KEY, curl, jq
#
# Example: ./doma-token-price.sh software.ai

set -euo pipefail

TOKEN_NAME="${1:?Usage: doma-token-price.sh <token_name>}"
API_URL="${DOMA_API_URL:-https://api.doma.xyz}"
API_KEY="${DOMA_API_KEY:?Error: DOMA_API_KEY is required}"

QUERY='{"query":"query($name:String){fractionalTokens(name:$name,take:1){items{address priceUsd price24hAgoUsd volumeUsd chain{name chainId} params{name symbol decimals}}}}","variables":{"name":"'"$TOKEN_NAME"'"}}'

RESPONSE=$(curl -s -X POST "$API_URL/v1/graphql" \
  -H "Content-Type: application/json" \
  -H "Api-Key: $API_KEY" \
  -d "$QUERY")

ITEM=$(echo "$RESPONSE" | jq -r '.data.fractionalTokens.items[0]')

if [ "$ITEM" = "null" ] || [ -z "$ITEM" ]; then
  echo "Token '$TOKEN_NAME' not found." >&2
  exit 1
fi

SYMBOL=$(echo "$ITEM" | jq -r '.params.symbol')
PRICE=$(echo "$ITEM" | jq -r '.priceUsd')
PRICE_24H=$(echo "$ITEM" | jq -r '.price24hAgoUsd')
VOLUME=$(echo "$ITEM" | jq -r '.volumeUsd')
CHAIN=$(echo "$ITEM" | jq -r '.chain.name')

if [ "$PRICE_24H" != "0" ] && [ "$PRICE_24H" != "null" ]; then
  CHANGE=$(echo "scale=2; ($PRICE - $PRICE_24H) / $PRICE_24H * 100" | bc 2>/dev/null || echo "0")
else
  CHANGE="0"
fi

echo "Symbol:     $SYMBOL"
echo "Price:      \$$PRICE"
echo "24h Change: ${CHANGE}%"
echo "Volume:     \$$VOLUME"
echo "Chain:      $CHAIN"
