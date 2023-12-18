// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/XcmRouter.sol";
import "../src/FeeRegistry.sol";
import "./MockToken.sol";
import "./MockXtokens.sol";

contract XcmRouterTest is Test {
    FeeRegistry public fees;
    MockToken public token1;
    MockToken public token2;
    MockToken public token3;
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);

    function setUp() public {
        token1 = new MockToken("Token1", "TK1");
        token2 = new MockToken("Token2", "TK2");
        token3 = new MockToken("token3", "TK3");

        Fee[] memory feeArray = new Fee[](2);
        feeArray[0] = Fee(address(token1), 1 ether);
        feeArray[1] = Fee(address(token2), 2 ether);

        fees = new FeeRegistry(feeArray);

        MockXtokens mock = new MockXtokens();
        vm.etch(XTOKENS, address(mock).code);
    }

    function testRouteWithFee() public {
        XcmInstructions memory inst = XcmInstructions(abi.encodePacked(alice), hex"00");
        XcmRouter router = new XcmRouter(fees, inst);

        token1.transfer(address(router), 5 ether);

        vm.prank(bob);
        router.route(token1, bob);

        assertEq(token1.balanceOf(address(router)), 0);
        assertEq(token1.balanceOf(alice), 4 ether); // amount - fee
        assertEq(token1.balanceOf(bob), 1 ether); // fee
    }

    function testRouteWithFeeWithOtherRecipient() public {
        XcmInstructions memory inst = XcmInstructions(abi.encodePacked(alice), hex"00");
        XcmRouter router = new XcmRouter(fees, inst);

        token1.transfer(address(router), 5 ether);

        vm.prank(bob);
        router.route(token1, charlie);

        assertEq(token1.balanceOf(address(router)), 0);
        assertEq(token1.balanceOf(alice), 4 ether); // amount - fee
        assertEq(token1.balanceOf(charlie), 1 ether); // fee
    }

    function testRouteWithoutFee() public {
        XcmInstructions memory inst = XcmInstructions(abi.encodePacked(alice), hex"00");
        XcmRouter router = new XcmRouter(fees, inst);

        token1.transfer(address(router), 5 ether);

        vm.prank(bob);
        router.routeNoFee(token1);

        assertEq(token1.balanceOf(address(router)), 0);
        assertEq(token1.balanceOf(alice), 5 ether);
        assertEq(token1.balanceOf(bob), 0);
    }

    function testRouteForUnknownToken() public {
        XcmInstructions memory inst = XcmInstructions(abi.encodePacked(alice), hex"00");
        XcmRouter router = new XcmRouter(fees, inst);

        token3.transfer(address(router), 5 ether);

        vm.prank(bob);
        vm.expectRevert("zero fee");
        router.route(token3, bob);

        router.routeNoFee(token3);

        assertEq(token3.balanceOf(address(router)), 0);
        assertEq(token3.balanceOf(alice), 5 ether);
        assertEq(token3.balanceOf(bob), 0);
    }
}
