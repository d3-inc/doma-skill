#!/bin/bash
# Usage: ./doma-balance.sh <wallet_address> [chain]
# Requires: curl, jq
# Note: Read-only balance check via RPC. For full functionality use the CLI: doma balance
#
# Example: ./doma-balance.sh 0x1234...abcd
# Example: ./doma-balance.sh 0x1234...abcd ethereum

set -euo pipefail

WALLET="${1:?Usage: doma-balance.sh <wallet_address> [chain]}"
CHAIN="${2:-doma}"

# Resolve chain to RPC URL and USDC address
case "$(echo "$CHAIN" | tr '[:upper:]' '[:lower:]')" in
  doma)
    RPC_URL="https://rpc.doma.xyz"
    USDC_ADDRESS="0x31EEf89D5215C305304a2fA5376a1f1b6C5dc477"
    CHAIN_NAME="Doma"
    ;;
  doma-testnet|doma_testnet)
    RPC_URL="https://sepolia.rpc.doma.xyz"
    USDC_ADDRESS="0x8725f6FDF6E240C303B4e7A60AD13267Fa04d55C"
    CHAIN_NAME="Doma Testnet"
    ;;
  ethereum|eth)
    RPC_URL="https://ethereum-rpc.publicnode.com"
    USDC_ADDRESS="0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
    CHAIN_NAME="Ethereum"
    ;;
  base)
    RPC_URL="https://mainnet.base.org"
    USDC_ADDRESS="0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"
    CHAIN_NAME="Base"
    ;;
  *)
    echo "Unknown chain: $CHAIN. Use: doma, doma-testnet, ethereum, base" >&2
    exit 1
    ;;
esac

# Get ETH balance
ETH_WEI=$(curl -s -X POST "$RPC_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getBalance","params":["'"$WALLET"'","latest"],"id":1}' \
  | jq -r '.result')

if [ "$ETH_WEI" = "null" ] || [ -z "$ETH_WEI" ]; then
  echo "Failed to fetch ETH balance." >&2
  exit 1
fi

# Convert hex wei to ETH (18 decimals)
ETH_DEC=$(printf "%d" "$ETH_WEI" 2>/dev/null || echo "0")
ETH_BALANCE=$(echo "scale=6; $ETH_DEC / 1000000000000000000" | bc)

# Get USDC balance via balanceOf(address) — selector 0x70a08231
PADDED_WALLET=$(printf '%064s' "${WALLET#0x}" | tr ' ' '0')
USDC_HEX=$(curl -s -X POST "$RPC_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"'"$USDC_ADDRESS"'","data":"0x70a08231'"$PADDED_WALLET"'"},"latest"],"id":2}' \
  | jq -r '.result')

USDC_DEC=$(printf "%d" "$USDC_HEX" 2>/dev/null || echo "0")
USDC_BALANCE=$(echo "scale=2; $USDC_DEC / 1000000" | bc)

echo "Chain:   $CHAIN_NAME"
echo "Wallet:  $WALLET"
echo "ETH:     $ETH_BALANCE"
echo "USDC:    $USDC_BALANCE"
