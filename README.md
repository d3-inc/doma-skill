# doma-skill

[skills.sh](https://skills.sh)-compatible agent skill for interacting with the [Doma Protocol](https://doma.xyz). Works with Claude Code, Cursor, GitHub Copilot, and 30+ other AI agents.

Trade tokens, bridge assets, manage DNS records, and claim subdomains — all through natural language.

## Install

```bash
npx skills add d3-inc/doma-skill
```

## Prerequisites

```bash
npm install -g @doma-protocol/doma-cli
```

Set environment variables or create `~/.doma/config.json`:

```bash
export DOMA_API_KEY="your-api-key"
export PRIVATE_KEY="0x..."
```

## What You Can Ask

- "What's the price of software.ai?"
- "Buy 100 USDC worth of software.ai"
- "Bridge 0.1 ETH from Ethereum to Doma"
- "Claim the subdomain myname.software.ai"
- "Point myname.software.ai to my Vercel site"
- "Check my wallet balance on all chains"

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
