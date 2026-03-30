# doma-skill

[skills.sh](https://skills.sh)-compatible agent skill for interacting with the [Doma Protocol](https://doma.xyz). Works with Claude Code, Cursor, GitHub Copilot, and 30+ other AI agents.

Trade tokens, bridge assets, manage DNS records and nameservers, and claim subdomains — all through natural language.

## Install

```bash
npx skills add d3-inc/doma-skill
```

## Prerequisites

```bash
npm install -g @doma-protocol/doma-cli
```

Configure with `doma config set` or environment variables:

```bash
doma config set privateKey "0x..."
doma config set apiKey "your-api-key"
```

## What You Can Ask

- "What's the price of software.ai?"
- "Buy 100 USDC worth of software.ai"
- "Bridge 0.1 ETH from Ethereum to Doma"
- "Claim the subdomain myname.software.ai"
- "Point myname.software.ai to my Vercel site"
- "Check my wallet balance on all chains"
- "Show domain info for software.ai"
- "What are the nameservers for software.ai?"
- "Set nameservers on mydomain.com to ns1.doma.xyz ns2.doma.xyz"

## Structure

```
doma-skill/
├── README.md
└── doma/
    ├── SKILL.md              # Agent instructions
    ├── scripts/              # Shell script fallbacks
    └── references/           # Detailed technical docs
```

## License

MIT
