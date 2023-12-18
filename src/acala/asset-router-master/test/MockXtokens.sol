// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./MockToken.sol";

contract MockXtokens {
    function transfer(address currencyId, uint256 amount, bytes memory dest, bytes memory /*weight*/ )
        external
        returns (bool)
    {
        address recipient = address(bytes20(dest));
        MockToken(currencyId).forceTransfer(msg.sender, recipient, amount);
        return true;
    }
}
