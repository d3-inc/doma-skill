# Bridging

## Overview

The Doma CLI bridges ETH and USDC between Doma, Ethereum, and Base using [Relay](https://relay.link), a cross-chain bridging protocol.

## Supported Routes

Any combination of Doma, Ethereum, and Base is supported for ETH and USDC.

## How It Works

1. **Quote**: CLI calls Relay's `/quote/v2` API with origin/destination chains and amount
2. **Review**: User sees expected output, fees, and estimated time
3. **Execute**: CLI submits transaction steps from the quote (may include ERC20 approval + deposit)
4. **Poll**: CLI polls Relay's `/intents/status/v3` until the bridge completes or times out

## USDC Addresses

| Chain | Address |
|-------|---------|
| Doma (97477) | `0x31EEf89D5215C305304a2fA5376a1f1b6C5dc477` |
| Ethereum (1) | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` |
| Base (8453) | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` |

## Timeouts

| Operation | Timeout |
|-----------|---------|
| Transaction submission | 60 seconds |
| Transaction confirmation | 300 seconds (5 minutes) |
| Bridge completion polling | 120 seconds (2 minutes) |

If the bridge is still pending after the polling timeout, the CLI prints the request ID so you can check status later.

## Fees

Relay charges two types of fees:
- **Gas fee**: Cost of on-chain transactions on origin and destination chains
- **Relayer fee**: Relay's service fee for facilitating the bridge

Both are shown in the quote before confirmation.

## Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "Source and destination must be different" | Same chain for --from and --to | Use different chains |
| "Unsupported bridge token" | Token other than ETH or USDC | Only ETH and USDC are bridgeable |
| "Transaction submission timed out" | RPC didn't respond in 60s | Check connectivity, try again |
| Relay API error | Quote or status API failed | Check amount, chains, and try again |
