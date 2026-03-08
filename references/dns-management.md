# DNS Management

## Overview

Doma domains and subdomains support onchain DNS records. Records are set via the `ProxyDomaRecord` contract and automatically synced to PowerDNS nameservers.

## How It Works

1. User calls `setDNSRRSet` on the `ProxyDomaRecord` contract
2. The transaction emits a blockchain event
3. The Doma backend indexes the event and sends a DNS update command
4. PowerDNS nameservers are updated with the new record
5. The record becomes resolvable via standard DNS queries

Records are stored per-token — each domain and subdomain has its own token ID.

## Supported Record Types

| Type | Usage | Example |
|------|-------|---------|
| A | IPv4 address | `1.2.3.4` |
| AAAA | IPv6 address | `2001:db8::1` |
| CNAME | Canonical name alias | `cname.vercel-dns.com` |
| TXT | Text record (verification, SPF, etc.) | `v=spf1 include:...` |
| MX | Mail exchange | `10 mail.example.com` |
| NS | Nameserver delegation | `ns1.example.com` |

## CNAME Exclusivity

Per DNS standards, a CNAME record cannot coexist with other record types (A, AAAA, MX, NS, TXT) at the same host. The CLI enforces this:

- Setting a CNAME fails if A, AAAA, MX, NS, or TXT records exist at that host
- Setting A/AAAA/MX/NS/TXT fails if a CNAME exists at that host

Remove conflicting records first before setting a CNAME.

## Default A Record

New domains come with a default A record pointing to `143.244.211.82` (the Doma landing page). When setting a CNAME, A, or TXT record, the CLI automatically removes this default A record in a separate transaction before setting the new record.

## Domain vs Subdomain Resolution

The CLI uses the Public Suffix List (PSL) to distinguish domains from subdomains:

- `software.ai` → domain (uses domain token ID)
- `myname.software.ai` → subdomain (uses subdomain token ID)

Each has its own token ID, looked up via the GraphQL API.

## Host Names

DNS records have a "host" (also called "name") relative to the domain:

| Host | Meaning |
|------|---------|
| `@` (or empty) | Apex/root of the domain |
| `www` | `www.software.ai` |
| `_vercel` | `_vercel.software.ai` (verification) |

For subdomains like `myname.software.ai`, hosts are relative to the subdomain:
- `@` → `myname.software.ai`
- `www` → `www.myname.software.ai`

## Contract Addresses

| Chain | ProxyDomaRecord |
|-------|----------------|
| Doma Mainnet (97477) | `0xd0000000000067CB44aE7b6aC3AB5764dE20A3E2` |
| Doma Testnet (97476) | `0x005815F7de38F192260b26005444cD62126D3D8A` |

## Propagation

After a transaction is confirmed, DNS records typically propagate within 30-60 seconds. Use `doma dns get <domain>` to verify records after setting them.
