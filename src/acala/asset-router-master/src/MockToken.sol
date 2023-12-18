// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/console.sol";

import { ERC20 } from "solmate/tokens/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol, 18) {
        _mint(msg.sender, 10000 ether);
    }

    function forceTransfer(address from, address to, uint256 amount) external {
        _burn(from, amount);
        _mint(to, amount);
    }
}
