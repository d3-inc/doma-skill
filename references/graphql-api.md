# Doma GraphQL API Reference

## Endpoint

```
POST https://api.doma.xyz/v1/graphql
```

## Authentication

Include the API key in the `Api-Key` header (no Bearer prefix):

```bash
curl -X POST https://api.doma.xyz/v1/graphql \
  -H "Content-Type: application/json" \
  -H "Api-Key: YOUR_API_KEY" \
  -d '{"query": "{ currencies { symbol usdExchangeRate } }"}'
```

## Key Queries

### currencies

Get all supported currencies with USD exchange rates.

```graphql
query {
  currencies {
    name
    symbol
    decimals
    usdExchangeRate
  }
}
```

### fractionalTokens

Search for fractional tokens by name. Returns paginated results.

```graphql
query SearchTokens($name: String, $networkIds: [String!], $take: Int) {
  fractionalTokens(name: $name, networkIds: $networkIds, take: $take) {
    items {
      id
      address
      status
      poolAddress
      graduatedAt
      priceUsd
      price1hAgoUsd
      price24hAgoUsd
      volumeUsd
      tvlUsd
      currentFDV
      initialFDV
      fractionalTokenHolderCount
      chain { chainId networkId name }
      params { name symbol decimals totalSupply }
    }
  }
}
```

### fractionalToken

Get a specific fractional token by CAIP-10 address.

```graphql
query GetToken($address: AddressCAIP10!) {
  fractionalToken(address: $address) {
    # Same fields as above
  }
}
```

CAIP-10 format: `eip155:<chainId>:<address>` (e.g., `eip155:97477:0x1234...`)

### pools

Get Uniswap V3 pool information.

```graphql
query GetPools($tokenSymbol: String, $take: Int) {
  pools(tokenSymbol: $tokenSymbol, take: $take) {
    items {
      address
      feeTier
      tvlUsd
      volumeUsd
      volume24hUsd
      apr
      token0Info { name symbol decimals }
      token1Info { name symbol decimals }
    }
  }
}
```

### recordSets

Get DNS records for a domain.

```graphql
query GetRecordSets($name: String!, $host: String) {
  recordSets(name: $name, host: $host) {
    items {
      host
      ttl
      type
      records
    }
  }
}
```

### subdomains

List subdomains for a domain.

```graphql
query GetSubdomains($parentDomain: String, $owner: AddressCAIP10, $take: Int) {
  subdomains(parentDomain: $parentDomain, owner: $owner, take: $take) {
    items {
      tokenId
      name
      host
      ownerAddress
      createdAt
      fractionalizationInfo {
        stakedAmount
        fractionalTokenAddress
        fractionalTokenPrice
      }
    }
    totalCount
  }
}
```

## Token Statuses

- `FRACTIONALIZED` — Token created, launchpad active
- `GRADUATION_SUCCESSFUL` — Launchpad complete, Uniswap V3 pool created
- `GRADUATION_FAILED` — Launchpad did not reach target
- `BOUGHT_OUT` — Token was bought out

## Rate Limits

The API has rate limiting. Handle HTTP 429 responses with exponential backoff.
