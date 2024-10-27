// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../libraries/tokens/ERC4626.sol";
import "../libraries/utils/ReentrancyGuard.sol";

import "./interfaces/IVault.sol";



contract PToken is IVault, ReentrancyGuard, ERC4626 {
    
    struct Position {
        uint256 size;
        
        uint256 collateral;
        uint256 averagePrice;
        uint256 openingFee;
        uint256 reserveAmount;
        int256 realisedPnl;
        uint256 lastIncreasedTime;
    }

    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    uint256 public constant FUNDING_RATE_PRECISION = 1000000;
    uint256 public constant PRICE_PRECISION = 10 ** 30;
    uint256 public constant MIN_LEVERAGE = 10000;

}