// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";

import { FeeRegistry } from "./FeeRegistry.sol";

abstract contract BaseRouter {
    using SafeTransferLib for ERC20;

    FeeRegistry public fees;

    event RouterCreated(address indexed addr);
    event RouterDestroyed(address indexed addr);

    constructor(FeeRegistry fees_) {
        fees = fees_;
        emit RouterCreated(address(this));
    }

    function routeImpl(ERC20 token) internal virtual;

    function routeNoFee(ERC20 token) public {
        routeImpl(token);

        // selfdestruct only if balance is zero to make sure this cannot be used to steal native tokens
        if (address(this).balance == 0) {
            emit RouterDestroyed(address(this));
            selfdestruct(payable(msg.sender));
        }
    }

    function route(ERC20 token, address relayer) public {
        uint256 fee = fees.getFee(address(token));

        // should use routeNoFee if relayer is not expecting a fee
        require(fee > 0, "zero fee");

        token.safeTransfer(relayer, fee);
        routeNoFee(token);
    }
}
