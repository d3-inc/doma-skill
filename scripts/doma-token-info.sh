#!/bin/bash
# Usage: ./doma-token-info.sh <token_name>
# Requires: DOMA_API_KEY, curl, jq
#
# Example: ./doma-token-info.sh software.ai

set -euo pipefail

TOKEN_NAME="${1:?Usage: doma-token-info.sh <token_name>}"
API_URL="${DOMA_API_URL:-https://api.doma.xyz}"
API_KEY="${DOMA_API_KEY:?Error: DOMA_API_KEY is required}"

QUERY='{"query":"query($name:String){fractionalTokens(name:$name,take:1){items{id address status poolAddress graduatedAt priceUsd price1hAgoUsd price24hAgoUsd volumeUsd tvlUsd currentFDV initialFDV fractionalTokenHolderCount chain{name chainId networkId} params{name symbol decimals totalSupply}}}}","variables":{"name":"'"$TOKEN_NAME"'"}}'

RESPONSE=$(curl -s -X POST "$API_URL/v1/graphql" \
  -H "Content-Type: application/json" \
  -H "Api-Key: $API_KEY" \
  -d "$QUERY")

ITEM=$(echo "$RESPONSE" | jq -r '.data.fractionalTokens.items[0]')

if [ "$ITEM" = "null" ] || [ -z "$ITEM" ]; then
  echo "Token '$TOKEN_NAME' not found." >&2
  exit 1
fi

echo "$ITEM" | jq '{
  name: .params.name,
  symbol: .params.symbol,
  address: .address,
  chain: "\(.chain.name) (\(.chain.chainId))",
  status: .status,
  pool: .poolAddress,
  price_usd: .priceUsd,
  market_cap: .currentFDV,
  tvl: .tvlUsd,
  volume: .volumeUsd,
  holders: .fractionalTokenHolderCount,
  decimals: .params.decimals,
  total_supply: .params.totalSupply
}'
