// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { ERC20 } from "solmate/tokens/ERC20.sol";

contract MockToken is ERC20 {
    mapping(bytes32 => uint256) public balanceOfAccountId32;

    constructor(string memory name, string memory symbol) ERC20(name, symbol, 18) {
        _mint(msg.sender, 10000 ether);
    }

    function forceTransfer(address from, address to, uint256 amount) external {
        _burn(from, amount);
        _mint(to, amount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }

    function transferToAccountId32(bytes32 dest, uint256 amount) external returns (bool) {
        _burn(msg.sender, amount);
        balanceOfAccountId32[dest] += amount;
        return true;
    }
}
