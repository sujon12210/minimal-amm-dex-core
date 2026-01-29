# Minimal AMM DEX Core

A production-ready logic for a decentralized exchange. This contract allows users to swap between two ERC20 tokens and provides incentives for Liquidity Providers (LPs).

## Core Mechanics


- **Swap:** Traders can exchange Token A for Token B based on the current pool ratio.
- **Add Liquidity:** LPs deposit both tokens in equal value and receive LP tokens representing their share of the pool.
- **Remove Liquidity:** LPs burn their LP tokens to reclaim their underlying assets plus accrued fees.

## Mathematics
The price is determined by the Constant Product Formula:
$$x \cdot y = k$$
Where:
- $x$ is the reserve of Token A.
- $y$ is the reserve of Token B.
- $k$ is a constant that must remain unchanged during swaps (ignoring fees).
