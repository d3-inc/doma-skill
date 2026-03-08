# Subdomain Operations

## Overview

Doma subdomains are claimed by staking fractional tokens of the parent domain. Each subdomain is an NFT with its own token ID, and the staker can set DNS records on it.

## How Subdomains Work

1. A domain owner enables subdomain minting on their fractionalized domain
2. Anyone holding the domain's fractional tokens can stake them to claim a subdomain
3. The staking price depends on the label length (shorter = more expensive)
4. The subdomain is released when the staker unstakes their tokens

## Lifecycle

```
Check availability → Stake tokens → Use subdomain (set DNS) → Unstake (release)
```

## Staking Price

The staking price is determined by label length — shorter labels cost more tokens. The price is read from the Fractionalization contract's `getSubdomainStakingPrice(address token, uint256 length)` function.

## Contract Addresses

| Chain | Fractionalization | ProxyDomaRecord |
|-------|-------------------|----------------|
| Doma Mainnet (97477) | `0xd00000000004f450f1438cfA436587d8f8A55A29` | `0xd0000000000067CB44aE7b6aC3AB5764dE20A3E2` |
| Doma Testnet (97476) | `0x7Fb5543D9740b6bA47c60775330F2d9Af1d1942c` | `0x005815F7de38F192260b26005444cD62126D3D8A` |

## Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "Subdomain minting is not enabled" | Domain owner hasn't enabled it | Contact domain owner |
| "already claimed" | Label is taken | Choose a different label |
| "label is reserved" | Label is on the forbidden list | Choose a different label |
| "Insufficient balance" | Not enough fractional tokens | Buy more tokens first |
| "not the owner" | Trying to unstake someone else's subdomain | Use the correct wallet |
