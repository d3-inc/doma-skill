# Nameserver Management

## Overview

Doma domains support setting nameservers at the registry level. This is distinct from NS DNS records — nameservers control which DNS servers are authoritative for the domain at the registrar/registry level.

Nameservers can only be set on root domains (e.g., `software.ai`), not subdomains. The domain must be tokenized on the Doma chain.

## How It Works

1. User calls `setNameservers(tokenId, nameservers[])` on the `ProxyDomaRecord` (same diamond as `ProxyDomaRecord`)
2. The proxy facet validates the caller is the token owner, the token is not synthetic, and the domain has the `REGISTRY_RECORDS_MANAGEMENT` capability
3. The call is relayed cross-chain to the Doma registrar chain
4. The registrar updates the nameservers at the registry level

The token ID is a namehash of the domain, looked up via the GraphQL API.

## Reading Nameservers

Nameservers can be read two ways:

### Via GraphQL API

```graphql
query {
  name(name: "software.ai") {
    nameservers {
      ldhName
    }
  }
}
```

### Via On-Chain Contract

The `DomaRecordFacet` on the Doma registrar chain exposes a `nameInfo(sld, tld)` view function that returns the full domain record including nameservers, DS keys, expiration, and more. This is a public view function — no permissions required.

| Chain | DomaRecord (registrar diamond) |
|-------|-------------------------------|
| Doma Mainnet (97477) | `0xd000000000003eC7096c7B280b274F20b305b82a` |
| Doma Testnet (97476) | `0x92eC6C7e93261c02Bd9160FE75D9091A4B911237` |

## Setting Nameservers

Nameservers are set via `setNameservers` on the `ProxyDomaRecord` contract.

```solidity
function setNameservers(
    uint256 tokenId,
    string[] calldata nameservers
) public payable
```

Access control:
- Caller must be the ownership token owner (`onlyTokenOwner`)
- Token must not be synthetic (`notSynthetic`)
- Token must not be expired (`notExpired`)
- Domain must have `CAPABILITY_REGISTRY_RECORDS_MANAGEMENT`

### Contract Addresses (ProxyDomaRecord)

| Chain | Address |
|-------|---------|
| Doma Mainnet (97477) | `0xd0000000000067CB44aE7b6aC3AB5764dE20A3E2` |
| Doma Testnet (97476) | `0x005815F7de38F192260b26005444cD62126D3D8A` |

## Limits

- 1 to 4 nameservers per domain
- Only root domains — subdomains are not supported at the contract level

## Doma Nameservers

Domains using Doma-managed nameservers typically have:
- `ns1.doma.xyz`
- `ns2.doma.xyz`

When a domain uses Doma nameservers, on-chain DNS records (A, AAAA, CNAME, TXT, etc.) are automatically synced to PowerDNS. Domains using non-Doma nameservers manage their DNS externally.

## Propagation

After a `setNameservers` transaction is confirmed on the proxy chain, the change is relayed cross-chain to the registrar. Registry-level nameserver updates may take longer to propagate than DNS record changes, depending on the TLD registry.
