// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/FeeRegistry.sol";

contract FeeRegistryTest is Test {
    FeeRegistry public fees;
    address public constant Token1 = address(0x1);
    address public constant Token2 = address(0x2);
    address public constant Token3 = address(0x3);

    function setUp() public {
        // make fee array
        Fee[] memory feeArray = new Fee[](2);
        feeArray[0] = Fee(Token1, 111);
        feeArray[1] = Fee(Token2, 222);

        fees = new FeeRegistry(feeArray);
    }

    function testGetFee() public {
        assertEq(fees.getFee(Token1), 111);
        assertEq(fees.getFee(Token2), 222);
        assertEq(fees.getFee(Token3), 0);
    }
}
