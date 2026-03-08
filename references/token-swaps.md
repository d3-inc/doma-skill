# Token Swap Workflows

## Overview

Doma tokens trade on two venues depending on their lifecycle stage:

1. **Launchpad (bonding curve)**: Tokens with `FRACTIONALIZED` status trade against USDC on a per-token launchpad contract using a linear bonding curve.
2. **Uniswap V3**: Tokens that have graduated (`GRADUATION_SUCCESSFUL`) trade on Uniswap V3 pools via SwapRouter02.

The CLI auto-detects which venue to use based on the token's status from the GraphQL API.

## Uniswap V3 Swap Flow

### 1. Resolve Tokens

Map user input to on-chain addresses:
- `ETH` → WETH address (native ETH is wrapped automatically)
- `USDC` → Chain-specific USDC address
- Token name → Search via Doma GraphQL API → Get contract address

### 2. Get Quote

Call QuoterV2 `quoteExactInputSingle` to get the expected output:

```
QuoterV2.quoteExactInputSingle({
  tokenIn: <address>,
  tokenOut: <address>,
  amountIn: <wei amount>,
  fee: 3000,              // 0.3% fee tier
  sqrtPriceLimitX96: 0    // no price limit
})
→ (amountOut, sqrtPriceX96After, initializedTicksCrossed, gasEstimate)
```

### 3. Calculate Slippage Protection

```
amountOutMinimum = expectedAmountOut * (10000 - slippageBps) / 10000
```

Default slippage: 50 bps (0.5%)

### 4. Approve Token Spending

If the input token is an ERC20 (not native ETH):
1. Check current allowance: `ERC20.allowance(wallet, swapRouter)`
2. If insufficient: `ERC20.approve(swapRouter, amountIn)`
3. Wait for approval transaction confirmation

### 5. Execute Swap

#### ERC20 → ERC20

```
SwapRouter02.exactInputSingle({
  tokenIn: <address>,
  tokenOut: <address>,
  fee: 3000,
  recipient: <wallet>,
  amountIn: <wei amount>,
  amountOutMinimum: <calculated>,
  sqrtPriceLimitX96: 0
})
```

#### Native ETH → ERC20

Use `multicall` to bundle `exactInputSingle` + `refundETH`:

```
SwapRouter02.multicall(deadline, [
  exactInputSingle({ tokenIn: WETH, ... }),
  refundETH()
], { value: amountIn })
```

#### ERC20 → Native ETH

Use `multicall` to bundle swap + unwrap:

```
SwapRouter02.multicall(deadline, [
  exactInputSingle({ tokenIn: token, tokenOut: WETH, recipient: router }),
  unwrapWETH9(amountOutMinimum, wallet)
])
```

## Fee Tiers

| Fee | Usage |
|-----|-------|
| 500 (0.05%) | Stable pairs |
| 3000 (0.3%) | Most pairs (default for Doma tokens) |
| 10000 (1%) | Exotic/volatile pairs |

## Bonding Curve Swaps (Launchpad)

Tokens that haven't graduated yet (`FRACTIONALIZED` status) trade on a per-token launchpad contract using a linear bonding curve. The quote token is always USDC.

### Buy Flow (USDC → Fractional Token)

1. Deduct buy fee: `quoteAmountAfterFee = usdcAmount * (10000 - buyFeeRateBps) / 10000`
2. Calculate tokens out: `curveModel.calculateBuyExactQuote(quoteAmountAfterFee, tokensSold)`
3. Cap at remaining supply: `min(tokensOut, launchTokensSupply - tokensSold)`
4. Apply slippage: `minTokenAmount = tokensOut * (10000 - slippageBps) / 10000`
5. Approve USDC → launchpad address
6. Call `launchpad.buy(usdcAmount, minTokenAmount)`

### Sell Flow (Fractional Token → USDC)

1. Calculate USDC out: `curveModel.calculateSellExactFractional(tokenAmount, tokensSold)`
2. Deduct sell fee: `usdcAfterFee = quoteBeforeFee * (10000 - sellFeeRateBps) / 10000`
3. Apply slippage: `minQuoteAmount = usdcAfterFee * (10000 - slippageBps) / 10000`
4. Approve fractional token → launchpad address
5. Call `launchpad.sell(tokenAmount, minQuoteAmount)`

### Sell on Failed Launch

If a launch fails (`GRADUATION_FAILED` status), holders can sell tokens back:
1. Approve fractional token → launchpad address
2. Call `launchpad.sellOnFail(tokenAmount)` (no slippage parameter)

## Common Errors

- **Insufficient liquidity**: The pool doesn't have enough tokens. Try a smaller amount.
- **Slippage exceeded**: Price moved beyond tolerance. Increase `--slippage` value.
- **Approval failed**: Check that the wallet has enough tokens and gas.
- **Pool not found**: The token may not have graduated yet. Check token status.
- **LaunchNotInProgress**: The launchpad sale has ended or hasn't started.
