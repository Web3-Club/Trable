// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { ITokenBridge } from "wormhole/bridge/interfaces/ITokenBridge.sol";

import { BaseRouter } from "./BaseRouter.sol";
import { FeeRegistry } from "./FeeRegistry.sol";

struct WormholeInstructions {
    uint16 recipientChain;
    bytes32 recipient;
    uint32 nonce;
    uint256 arbiterFee;
}

contract WormholeRouter is BaseRouter {
    address private _tokenBridgeAddress;
    WormholeInstructions private _instructions;

    constructor(FeeRegistry fees, WormholeInstructions memory instructions, address tokenBridgeAddress)
        BaseRouter(fees)
    {
        _instructions = instructions;
        _tokenBridgeAddress = tokenBridgeAddress;
    }

    function routeImpl(ERC20 token) internal override {
        bool approved = token.approve(_tokenBridgeAddress, token.balanceOf(address(this)));
        require(approved, "WormholeRouter: approve failed");

        ITokenBridge(_tokenBridgeAddress).transferTokens(
            address(token),
            token.balanceOf(address(this)),
            _instructions.recipientChain,
            _instructions.recipient,
            _instructions.arbiterFee,
            _instructions.nonce
        );
    }
}
