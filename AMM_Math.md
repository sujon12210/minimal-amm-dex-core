The contract implements the Uniswap V2 'x * y = k' curve. 
To ensure security:
1. Reentrancy: Standard ERC20 transfer calls are used; in production, use ReentrancyGuard.
2. Slippage: Swaps should include a 'minAmountOut' parameter to protect users from front-running.
3. Decimals: This contract assumes both tokens use the same decimals for simplified logic.
