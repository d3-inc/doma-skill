# Supported Chains & Contracts

## Doma Mainnet (Chain ID: 97477)

| Contract | Address |
|----------|---------|
| WETH | `0x4200000000000000000000000000000000000006` |
| USDC | `0x31EEf89D5215C305304a2fA5376a1f1b6C5dc477` |
| SwapRouter02 | `0x50cDfe221F0B478b7F58319d7b42cf61e5d904A9` |
| QuoterV2 | `0x2023ADF9fF50219C34989baABD76A0f5cfe432f4` |
| Uniswap V3 Factory | `0x2e50b586d5bcD04cb6125E028A6a669f7f3cF1C2` |
| Fractionalization | `0xd00000000004f450f1438cfA436587d8f8A55A29` |
| ProxyDomaRecord | `0xd0000000000067CB44aE7b6aC3AB5764dE20A3E2` |

- RPC: `https://rpc.doma.xyz`
- Explorer: `https://explorer.doma.xyz`

## Doma Testnet (Chain ID: 97476)

| Contract | Address |
|----------|---------|
| WETH | `0x4200000000000000000000000000000000000006` |
| USDC (test) | `0x8725f6FDF6E240C303B4e7A60AD13267Fa04d55C` |
| SwapRouter02 | `0x7ce273df74dc43c79e5880dd2c3eb44309236743` |
| QuoterV2 | `0x823022BB81e50aBcD1f6cf9F8eE6e2557A345a9d` |
| Uniswap V3 Factory | `0xF1398cA2C4F1113C5B618D71E4751D2E744f8369` |
| Fractionalization | `0x7Fb5543D9740b6bA47c60775330F2d9Af1d1942c` |
| ProxyDomaRecord | `0x005815F7de38F192260b26005444cD62126D3D8A` |

- RPC: `https://sepolia.rpc.doma.xyz`
- Explorer: `https://sepolia.explorer.doma.xyz`

## Ethereum Mainnet (Chain ID: 1)

| Token | Address |
|-------|---------|
| WETH | `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2` |
| USDC | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` |

- RPC: `https://ethereum-rpc.publicnode.com`
- Explorer: `https://etherscan.io`
- Supported operations: bridge, balance

## Base (Chain ID: 8453)

| Token | Address |
|-------|---------|
| WETH | `0x4200000000000000000000000000000000000006` |
| USDC | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` |

- RPC: `https://mainnet.base.org`
- Explorer: `https://basescan.org`
- Supported operations: bridge, balance

## Token Addressing

### CAIP-10 Format

The Doma API uses CAIP-10 addresses: `eip155:<chainId>:<address>`

Examples:
- `eip155:97477:0x4200000000000000000000000000000000000006` (WETH on Doma mainnet)
- `eip155:97476:0x8725f6FDF6E240C303B4e7A60AD13267Fa04d55C` (USDC on testnet)

### Native Currency

All Doma chains use ETH as the native gas token. The WETH address is `0x4200000000000000000000000000000000000006` on both mainnet and testnet.
