// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { ERC20 } from "solmate/tokens/ERC20.sol";

import { FeeRegistry } from "./FeeRegistry.sol";
import { HomaRouter, HomaInstructions } from "./HomaRouter.sol";

contract HomaFactory {
    ERC20 public immutable STAKING_TOKEN;
    ERC20 public immutable LIQUID_TOKEN;

    constructor(ERC20 stakingToken, ERC20 liquidToken) {
        STAKING_TOKEN = stakingToken;
        LIQUID_TOKEN = liquidToken;
    }

    function deployHomaRouter(FeeRegistry fees, bytes32 recipient) public returns (HomaRouter) {
        // no need to use salt as we want to keep the router address the same for the same fees &instructions
        bytes32 salt;

        HomaInstructions memory inst =
            HomaInstructions({ stakingToken: STAKING_TOKEN, liquidToken: LIQUID_TOKEN, recipient: recipient });

        HomaRouter router;
        try new HomaRouter{salt: salt}(fees, inst) returns (HomaRouter router_) {
            router = router_;
        } catch {
            router = HomaRouter(
                address(
                    uint160(
                        uint256(
                            keccak256(
                                abi.encodePacked(
                                    bytes1(0xff),
                                    address(this),
                                    salt,
                                    keccak256(abi.encodePacked(type(HomaRouter).creationCode, abi.encode(fees, inst)))
                                )
                            )
                        )
                    )
                )
            );
        }

        return router;
    }

    function deployHomaRouterAndRoute(FeeRegistry fees, bytes32 recipient, ERC20 token) public {
        HomaRouter router = deployHomaRouter(fees, recipient);
        router.route(token, msg.sender);
    }

    function deployHomaRouterAndRouteNoFee(FeeRegistry fees, bytes32 recipient, ERC20 token) public {
        HomaRouter router = deployHomaRouter(fees, recipient);
        router.routeNoFee(token);
    }
}
