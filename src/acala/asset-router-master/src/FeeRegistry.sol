// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

struct Fee {
    address token;
    uint256 amount;
}

contract FeeRegistry {
    mapping(address => uint256) private _fees;

    constructor(Fee[] memory myArra) {
        for (uint256 i = 0; i < myArra.length; i++) {
            _fees[myArra[i].token] = myArra[i].amount;
        }
    }

    function getFee(address token) public view returns (uint256) {
        return _fees[token];
    }
}
