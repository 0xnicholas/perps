// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./IVaultUtils.sol";

interface IVault {

    function isInitialized() external view returns (bool);
    function isSwapEnabled() external view returns (bool);
    function isLeverageEnabled() external view returns (bool);

    function setVaultUtils(IVaultUtils _vaultUtils) external;
    function setError(uint256 _errorCode, string calldata _error) external;

    function router() external view returns (address);
    function gov() external view returns (address);

    function maxLeverage() external view returns (uint256);

    
}