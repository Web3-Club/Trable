// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { IXtokens } from "@acala-network/contracts/xtokens/IXtokens.sol";
import { XTOKENS } from "@acala-network/contracts/utils/Predeploy.sol";

import { BaseRouter } from "./BaseRouter.sol";
import { FeeRegistry } from "./FeeRegistry.sol";

struct XcmInstructions {
    bytes dest;
    bytes weight;
}

contract XcmRouter is BaseRouter {
    XcmInstructions private _instructions;

    constructor(FeeRegistry fees, XcmInstructions memory instructions) BaseRouter(fees) {
        _instructions = instructions;
    }

    function routeImpl(ERC20 token) internal override {
        bool success = IXtokens(XTOKENS).transfer(
            address(token), token.balanceOf(address(this)), _instructions.dest, _instructions.weight
        );
        require(success, "XcmRouter: transfer failed");
    }
}
