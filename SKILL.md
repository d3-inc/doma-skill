---
name: doma
description: >
  Use this skill when the user asks about Doma Protocol — token trading, swapping
  tokens, checking token prices, domain management, DNS records, nameservers,
  subdomain staking, cross-chain bridging, or interacting with the Doma blockchain.
  Trigger on any mention of Doma tokens, domain token prices, buying/selling tokens
  on Doma, bridging assets to/from Doma, DNS records for .ai or Doma domains,
  nameserver management, subdomain claiming, or api.doma.xyz.
  Always prefer this skill's CLI over writing raw API calls or contract interactions.
license: MIT
metadata:
  author: doma-protocol
  version: "1.1"
compatibility: Requires Node.js 18+ and npm.
allowed-tools: Bash(doma *), Bash(npx -y @doma-protocol/doma-cli *), Bash(which doma)
---

# Doma Protocol Skill

You are an expert at using the `doma` CLI to interact with the Doma Protocol. You help users trade tokens, manage domains/subdomains, configure DNS records and nameservers, and bridge assets across chains.

## Prerequisites

The `doma` CLI can be installed globally or run via `npx`:

```bash
# Option 1: Global install (faster repeated usage)
npm install -g @doma-protocol/doma-cli

# Option 2: No install needed — npx runs it on demand
npx -y @doma-protocol/doma-cli <command>
```

## Agent Rules

1. **Detect CLI availability once per conversation** — run `which doma` before your first doma command. If it succeeds, use `doma` directly for all commands. If it fails, prefix every command with `npx -y @doma-protocol/doma-cli` instead. All command examples below use `doma` for brevity; substitute the npx prefix when needed.
2. **Always** pass `-f json` to every command so you can parse structured output.
3. **Always** pass `-y` to transactional commands (`swap`, `bridge`, `subdomain claim`, `subdomain unstake`, `dns set`, `dns delete`, `nameservers set`) to skip interactive confirmation prompts.
4. Never ask the user for their private key or API key — assume they are already configured.
5. **Always check balances before write operations** — verify the wallet has sufficient tokens/ETH before swaps, bridges, or claims.
6. **Verify after mutations** — after setting DNS records, run `doma dns list` to confirm. After claiming a subdomain, run `doma subdomain list` to verify.

## Setup

The CLI reads configuration from `~/.doma/config.json` or environment variables. Use `doma config set <key> <value>` to configure. On macOS, private keys are stored in Keychain.

| Config Key      | Environment Variable   | Description                                    | Default |
|-----------------|------------------------|------------------------------------------------|---------|
| `privateKey`    | `DOMA_PRIVATE_KEY`     | Wallet private key (required for transactions) | —       |
| `apiKey`        | `DOMA_API_KEY`         | API key for Doma                               | —       |
| `apiUrl`        | `DOMA_API_URL`         | API endpoint (overridden by --testnet)         | —       |
| `chainId`       | `DOMA_CHAIN_ID`        | Default chain ID                               | `97477` |
| `testnet`       | `DOMA_TESTNET`         | Use testnet                                    | `false` |

## Supported Chains

| Chain | ID | Name flag | Operations |
|---|---|---|---|
| Doma Mainnet | 97477 | `doma` | All (default) |
| Doma Testnet | 97476 | `doma-testnet` | All |
| Ethereum | 1 | `ethereum` | Bridge + balance |
| Base | 8453 | `base` | Bridge + balance |

Use `-c <chainId>` or `--chain <name>` on any command to target a specific chain.

## Token Resolution

Tokens can be specified as:
- Well-known symbols: `ETH`, `USDC`, `WETH`
- Token name (e.g., `software.ai`)
- Contract address (`0x…`)

Amounts are always in human-readable decimals (e.g., `1.5` means 1.5 tokens).

## Commands

### token — Get detailed token information

```bash
doma token <token> -f json
```

Returns: name, symbol, address, status, tradingVenue, priceUsd, change24hPercent, marketCapUsd, tvlUsd, volume24hUsd, holders, launchpad info, and more.

### balance — Check wallet balances

```bash
doma balance -f json                       # ETH + USDC on Doma
doma balance <token> -f json               # Specific token
doma balance --chain ethereum -f json      # ETH + USDC on Ethereum
```

### quote — Get a swap quote

```bash
doma quote <tokenIn> <tokenOut> <amount> -f json
```

Auto-detects the best route: launchpad bonding curve, Uniswap V3, or multi-step.

### swap — Execute a token swap

```bash
doma swap <tokenIn> <tokenOut> <amount> -y -f json
doma swap <tokenIn> <tokenOut> <amount> -s <slippageBps> -y -f json
```

| Flag | Default |
|---|---|
| `-s, --slippage <bps>` | 50 (0.5%) |

### bridge — Bridge ETH or USDC across chains

```bash
doma bridge <token> <amount> --from <chain> --to <chain> -y -f json
```

Only ETH and USDC are bridgeable. Uses Relay protocol.

### domain — Get on-chain domain information

```bash
doma domain <name> -f json
```

Returns: sld, tld, icann, registrarIanaId, expiresAt, expired, nameservers, dsKeys, claimedBy, supportedCapabilities, nameTokens, complianceHold.

Reads directly from the Doma chain — does not require the domain to use Doma nameservers.

### dns list — List DNS records

```bash
doma dns list <name> -f json
doma dns list <name> --host <host> -f json
```

### dns set — Set a DNS record onchain

```bash
doma dns set <domain> <name> <type> <value> -y -f json
```

Use `@` for name to set a record at the apex.

| Flag | Default |
|---|---|
| `--ttl <seconds>` | 3600 |

### dns delete — Delete a DNS record onchain

```bash
doma dns delete <domain> <name> <type> -y -f json
```

Use `@` for name to delete a record at the apex.

### nameservers list — List nameservers

```bash
doma nameservers list <domain> -f json
```

### nameservers set — Set nameservers

```bash
doma nameservers set <domain> <ns1> [ns2] [ns3] [ns4] -y -f json
```

Supports 1 to 4 nameservers. Only root domains are supported — subdomains cannot have nameservers set.

### subdomain check — Check availability and staking price

```bash
doma subdomain check <label> <domain> -f json
```

### subdomain claim — Stake tokens to claim a subdomain

```bash
doma subdomain claim <label> <domain> -y -f json
```

### subdomain unstake — Release a subdomain and recover staked tokens

```bash
doma subdomain unstake <nameOrId> -y -f json
```

`<nameOrId>` — Full subdomain name (e.g., `alice.software.ai`) or on-chain numeric ID.

### subdomain list — List subdomains

```bash
doma subdomain list <domain> -f json
doma subdomain list --mine -f json
```

### config — Show and manage configuration

```bash
doma config -f json                        # Show current config
doma config set <key> <value>              # Set a config value
doma config delete <key>                   # Remove a config value
```

## Multi-Step Workflows

Most user requests require multiple commands. The key insight: **always check what the wallet has before attempting any transaction**, and **automatically bridge and swap to get the funds needed** rather than failing and asking the user to do it manually.

### Buying a Token

When a user says "buy software.ai" or "swap 100 USDC for software.ai":

1. **Check Doma balance first**: `doma balance -f json`
2. **If enough USDC on Doma** → swap directly: `doma swap USDC software.ai <amount> -y -f json`
3. **If not enough USDC on Doma** → check other chains:
   - `doma balance --chain ethereum -f json`
   - `doma balance --chain base -f json`
4. **If funds exist on another chain** → bridge them first:
   - `doma bridge USDC <amount> --from ethereum --to doma -y -f json`
   - Wait for bridge to complete, then swap: `doma swap USDC software.ai <amount> -y -f json`
5. **If no funds anywhere** → tell the user they need to deposit funds

The agent should do all of this automatically — don't stop at "insufficient balance" and ask the user what to do. Check every chain, bridge what's needed, then complete the swap.

### Claiming a Subdomain

When a user says "claim alice.software.ai":

1. **Check availability and price**:
   - `doma subdomain check alice software.ai -f json` → get `stakingPrice` and `available`
   - If not available, tell the user and stop
   - `doma token software.ai -f json` → get the token's contract `address`

2. **Check if wallet has enough of the domain's fractional token**:
   - `doma balance <token-address> -f json`
   - Compare balance to `stakingPrice` from step 1

3. **If not enough tokens → acquire them**:
   - First check USDC on Doma: `doma balance -f json`
   - If not enough USDC on Doma, check other chains:
     - `doma balance --chain ethereum -f json`
     - `doma balance --chain base -f json`
   - Bridge USDC to Doma if needed: `doma bridge USDC <amount> --from <chain> --to doma -y -f json`
   - Swap USDC for the token: `doma swap USDC software.ai <amount> -y -f json`
   - Use `doma quote USDC software.ai <amount> -f json` first to estimate how much USDC is needed for the required token amount

4. **Claim the subdomain**: `doma subdomain claim alice software.ai -y -f json`

5. **Verify**: `doma subdomain list software.ai -f json`

### Setting Up a Domain for Vercel

When a user says "point blog.software.ai to my Vercel site" or "set up DNS for Vercel":

1. **Determine if it's a subdomain or apex domain**:
   - Subdomain (e.g., `blog.software.ai`) → use CNAME
   - Apex domain (e.g., `software.ai`) → use A record

2. **For subdomains** — check if it's claimed, claim if needed:
   - `doma subdomain list software.ai -f json` → check if subdomain exists
   - If not claimed, follow the "Claiming a Subdomain" workflow above first

3. **Set DNS records**:
   - Subdomain: `doma dns set blog.software.ai @ CNAME cname.vercel-dns.com -y -f json`
   - Apex: `doma dns set software.ai @ A 76.76.21.21 -y -f json`

4. **Add domain to Vercel project** — check if `vercel` CLI is available and use it to automate the Vercel side:
   ```bash
   # Check if Vercel CLI is installed
   which vercel

   # Add the domain to the Vercel project (auto-detects project from cwd or use --project)
   vercel domains add blog.software.ai

   # If the user specified a project name:
   vercel domains add blog.software.ai --project <project-name>
   ```
   - If `vercel` CLI is not installed, tell the user to add the domain manually in Vercel dashboard (Project → Settings → Domains)
   - If the user hasn't linked a Vercel project, ask them which project to use

5. **Check if Vercel requires TXT verification** — after adding the domain, Vercel may return a verification token:
   - The `vercel domains add` output or `vercel domains inspect blog.software.ai` will show if verification is needed and provide the TXT value
   - If verification is needed: `doma dns set blog.software.ai _vercel TXT "<verification-value>" -y -f json`
   - Then verify: `vercel domains verify blog.software.ai`

6. **Confirm everything**: `doma dns list blog.software.ai -f json`

If `vercel` CLI is not available, fall back to asking the user to:
1. Add the domain in Vercel dashboard
2. Provide the TXT verification value if Vercel requires one
3. Click "Refresh" in Vercel to verify

**Hosting provider DNS cheat sheet:**

| Provider | Subdomain Record | Apex Record | Verification TXT name |
|----------|-----------------|-------------|----------------------|
| Vercel | CNAME → `cname.vercel-dns.com` | A → `76.76.21.21` | `_vercel` |
| Netlify | CNAME → `<site>.netlify.app` | A → `75.2.60.5` | (ask user) |
| GitHub Pages | CNAME → `<user>.github.io` | A → `185.199.108.153` | (ask user) |

If the user doesn't specify a provider, ask which one they're using.

### Selling a Token

1. Check balance: `doma balance <token> -f json`
2. Swap to USDC: `doma swap <token> USDC <amount> -y -f json`
3. If the user wants funds on another chain, bridge out: `doma bridge USDC <amount> --from doma --to ethereum -y -f json`

## References

For detailed technical documentation, read these files as needed:

- [references/chains.md](references/chains.md) — Contract addresses, RPC URLs, CAIP-10 format
- [references/token-swaps.md](references/token-swaps.md) — Bonding curve and Uniswap V3 swap mechanics
- [references/graphql-api.md](references/graphql-api.md) — Doma GraphQL API queries and types
- [references/dns-management.md](references/dns-management.md) — Onchain DNS, record types, CNAME rules, propagation
- [references/nameservers.md](references/nameservers.md) — Registry-level nameserver management, contracts, capabilities
- [references/subdomains.md](references/subdomains.md) — Staking mechanics, contract interface
- [references/bridging.md](references/bridging.md) — Relay protocol, supported routes, timeouts

## Shell Script Fallbacks

For environments without Node.js, read-only shell scripts are available in `scripts/`:

```bash
scripts/doma-token-price.sh <token_name>              # Requires: DOMA_API_KEY, curl, jq
scripts/doma-token-info.sh <token_name>
scripts/doma-swap-quote.sh <tokenIn> <tokenOut> <amount>
scripts/doma-balance.sh <wallet_address> [chain]       # Requires: curl, jq
scripts/doma-dns-get.sh <domain_or_subdomain> [host]   # Requires: DOMA_API_KEY, curl, jq
scripts/doma-subdomain-list.sh <domain>                # Requires: DOMA_API_KEY, curl, jq
```

These are read-only — write operations (swap, bridge, dns set/delete, nameservers set) require the full CLI.
