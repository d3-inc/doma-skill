#!/bin/bash
# Usage: ./doma-swap-quote.sh <tokenIn_name> <tokenOut_name> <amount>
# Requires: DOMA_API_KEY, curl, jq
# Note: This is a simplified quote using API data, not an on-chain QuoterV2 call.
#       For accurate quotes, use the CLI: doma quote <from> <to> <amount>
#
# Example: ./doma-swap-quote.sh USDC software.ai 100

set -euo pipefail

TOKEN_IN="${1:?Usage: doma-swap-quote.sh <tokenIn> <tokenOut> <amount>}"
TOKEN_OUT="${2:?Usage: doma-swap-quote.sh <tokenIn> <tokenOut> <amount>}"
AMOUNT="${3:?Usage: doma-swap-quote.sh <tokenIn> <tokenOut> <amount>}"
API_URL="${DOMA_API_URL:-https://api.doma.xyz}"
API_KEY="${DOMA_API_KEY:?Error: DOMA_API_KEY is required}"

# Get currencies for USDC/ETH prices
CURRENCIES=$(curl -s -X POST "$API_URL/v1/graphql" \
  -H "Content-Type: application/json" \
  -H "Api-Key: $API_KEY" \
  -d '{"query":"{ currencies { symbol usdExchangeRate } }"}')

get_usd_price() {
  local symbol="$1"
  echo "$CURRENCIES" | jq -r ".data.currencies[] | select(.symbol == \"$symbol\") | .usdExchangeRate // empty"
}

get_token_price() {
  local name="$1"
  local query='{"query":"query($name:String){fractionalTokens(name:$name,take:1){items{priceUsd params{symbol}}}}","variables":{"name":"'"$name"'"}}'
  curl -s -X POST "$API_URL/v1/graphql" \
    -H "Content-Type: application/json" \
    -H "Api-Key: $API_KEY" \
    -d "$query" | jq -r '.data.fractionalTokens.items[0].priceUsd // empty'
}

# Resolve input token price
IN_UPPER=$(echo "$TOKEN_IN" | tr '[:lower:]' '[:upper:]')
if [ "$IN_UPPER" = "USDC" ]; then
  IN_PRICE=1
elif [ "$IN_UPPER" = "ETH" ] || [ "$IN_UPPER" = "WETH" ]; then
  IN_PRICE=$(get_usd_price "ETH")
else
  IN_PRICE=$(get_token_price "$TOKEN_IN")
fi

# Resolve output token price
OUT_UPPER=$(echo "$TOKEN_OUT" | tr '[:lower:]' '[:upper:]')
if [ "$OUT_UPPER" = "USDC" ]; then
  OUT_PRICE=1
elif [ "$OUT_UPPER" = "ETH" ] || [ "$OUT_UPPER" = "WETH" ]; then
  OUT_PRICE=$(get_usd_price "ETH")
else
  OUT_PRICE=$(get_token_price "$TOKEN_OUT")
fi

if [ -z "$IN_PRICE" ] || [ -z "$OUT_PRICE" ] || [ "$OUT_PRICE" = "0" ]; then
  echo "Could not resolve token prices. Use the CLI for accurate on-chain quotes." >&2
  exit 1
fi

ESTIMATED_OUT=$(echo "scale=6; $AMOUNT * $IN_PRICE / $OUT_PRICE" | bc)
EXEC_PRICE=$(echo "scale=6; $IN_PRICE / $OUT_PRICE" | bc)

echo "Input:    $AMOUNT $TOKEN_IN"
echo "Output:   ~$ESTIMATED_OUT $TOKEN_OUT (estimated)"
echo "Price:    ~$EXEC_PRICE $TOKEN_OUT/$TOKEN_IN"
echo ""
echo "Note: This is an estimate based on API prices."
echo "For accurate on-chain quotes: doma quote $TOKEN_IN $TOKEN_OUT $AMOUNT"
