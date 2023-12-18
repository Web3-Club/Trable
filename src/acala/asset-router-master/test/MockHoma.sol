// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./MockToken.sol";

contract MockHoma {
    MockToken stakingToken;
    MockToken liquidToken;

    constructor(MockToken _stakingToken, MockToken _liquidToken) {
        stakingToken = _stakingToken;
        liquidToken = _liquidToken;
    }

    function mint(uint256 mintAmount) external returns (bool) {
        stakingToken.burn(msg.sender, mintAmount);
        liquidToken.mint(msg.sender, mintAmount * 10);
        return true;
    }
}
