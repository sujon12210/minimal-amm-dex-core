// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleDEX is ERC20 {
    IERC20 public token0;
    IERC20 public token1;

    uint256 public reserve0;
    uint256 public reserve1;

    constructor(address _token0, address _token1) ERC20("DEX LP Token", "DLP") {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "Invalid token");
        require(_amountIn > 0, "Amount in must be > 0");

        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint256 resIn, uint256 resOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // Constant Product Formula: (resIn + amountIn) * (resOut - amountOut) = k
        // amountOut = (resOut * amountIn) / (resIn + amountIn)
        uint256 amountInWithFee = (_amountIn * 997) / 1000; // 0.3% fee
        amountOut = (resOut * amountInWithFee) / (resIn + amountInWithFee);

        tokenOut.transfer(msg.sender, amountOut);
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint256 shares) {
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = _min((_amount0 * _totalSupply) / reserve0, (_amount1 * _totalSupply) / reserve1);
        }

        require(shares > 0, "Shares must be > 0");
        _mint(msg.sender, shares);
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function removeLiquidity(uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
        uint256 _totalSupply = totalSupply();
        amount0 = (_shares * reserve0) / _totalSupply;
        amount1 = (_shares * reserve1) / _totalSupply;

        _burn(msg.sender, _shares);
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}
