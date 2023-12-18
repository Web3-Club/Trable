// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/HomaRouter.sol";
import "../src/FeeRegistry.sol";
import "./MockToken.sol";
import "./MockHoma.sol";

contract HomaRouterTest is Test {
    FeeRegistry public fees;
    MockToken public stakingToken;
    MockToken public liquidToken;
    MockToken public otherToken;
    address public alice = address(0x01010101010101010101);
    address public bob = address(0x02020202020202020202);
    address public charlie = address(0x03030303030303030303);
    bytes32 public alice32 = hex"0404040404040404040404040404040404040404040404040404040404040404";
    bytes32 public bob32 = hex"0505050505050505050505050505050505050505050505050505050505050505";

    function setUp() public {
        stakingToken = new MockToken("StakingToken", "ST");
        liquidToken = new MockToken("LiquidToken", "LT");
        otherToken = new MockToken("OtherToken", "OT");

        Fee[] memory feeArray = new Fee[](2);
        feeArray[0] = Fee(address(stakingToken), 1 ether);
        feeArray[1] = Fee(address(liquidToken), 2 ether);

        fees = new FeeRegistry(feeArray);

        MockHoma mock = new MockHoma(stakingToken, liquidToken);
        vm.etch(HOMA, address(mock).code);
        vm.store(address(HOMA), bytes32(uint256(0)), bytes32(uint256(uint160(address(stakingToken)))));
        vm.store(address(HOMA), bytes32(uint256(1)), bytes32(uint256(uint160(address(liquidToken)))));
    }

    function fromEvmAddress(address addr) public pure returns (bytes32) {
        // convert addr to bytes32 with prefix of `evm:` and suffix of 8 bytes of zeros
        bytes32 prefix = bytes32(uint256(0x65766d3a00000000000000000000000000000000000000000000000000000000));
        bytes32 result = bytes32(uint256(uint160(addr))) << 64;
        return result | prefix;
    }

    function testRouteWithFee() public {
        HomaInstructions memory inst = HomaInstructions(stakingToken, liquidToken, fromEvmAddress(alice));
        HomaRouter router = new HomaRouter(fees, inst);

        stakingToken.transfer(address(router), 5 ether);

        vm.prank(bob);
        router.route(stakingToken, bob);

        assertEq(stakingToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOf(alice), 40 ether); // (amount - fee) * 10
        assertEq(stakingToken.balanceOf(bob), 1 ether); // fee
    }

    function testRouteWithFeeWithAccountId() public {
        HomaInstructions memory inst = HomaInstructions(stakingToken, liquidToken, alice32);
        HomaRouter router = new HomaRouter(fees, inst);

        stakingToken.transfer(address(router), 5 ether);

        vm.prank(bob);
        router.route(stakingToken, bob);

        assertEq(stakingToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOfAccountId32(alice32), 40 ether); // (amount - fee) * 10
        assertEq(stakingToken.balanceOf(bob), 1 ether); // fee
    }

    function testRouteWithFeeWithOtherRecipient() public {
        HomaInstructions memory inst = HomaInstructions(stakingToken, liquidToken, fromEvmAddress(alice));
        HomaRouter router = new HomaRouter(fees, inst);

        stakingToken.transfer(address(router), 5 ether);

        vm.prank(bob);
        router.route(stakingToken, charlie);

        assertEq(stakingToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOf(alice), 40 ether); // (amount - fee) * 10
        assertEq(stakingToken.balanceOf(charlie), 1 ether); // fee
    }

    function testRouteWithFeeWithOtherRecipientWithAccountId() public {
        HomaInstructions memory inst = HomaInstructions(stakingToken, liquidToken, alice32);
        HomaRouter router = new HomaRouter(fees, inst);

        stakingToken.transfer(address(router), 5 ether);

        vm.prank(bob);
        router.route(stakingToken, charlie);

        assertEq(stakingToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOfAccountId32(alice32), 40 ether); // (amount - fee) * 10
        assertEq(stakingToken.balanceOf(charlie), 1 ether); // fee
    }

    function testRouteWithoutFee() public {
        HomaInstructions memory inst = HomaInstructions(stakingToken, liquidToken, fromEvmAddress(alice));
        HomaRouter router = new HomaRouter(fees, inst);

        stakingToken.transfer(address(router), 5 ether);

        vm.prank(bob);
        router.routeNoFee(stakingToken);

        assertEq(stakingToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOf(alice), 50 ether);
        assertEq(stakingToken.balanceOf(bob), 0);
    }

    function testRouteWithoutFeeWithAccountId() public {
        HomaInstructions memory inst = HomaInstructions(stakingToken, liquidToken, alice32);
        HomaRouter router = new HomaRouter(fees, inst);

        stakingToken.transfer(address(router), 5 ether);

        vm.prank(bob);
        router.routeNoFee(stakingToken);

        assertEq(stakingToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOf(address(router)), 0);
        assertEq(liquidToken.balanceOfAccountId32(alice32), 50 ether);
        assertEq(stakingToken.balanceOf(bob), 0);
    }

    function testRouteForUnknownToken() public {
        HomaInstructions memory inst = HomaInstructions(stakingToken, liquidToken, fromEvmAddress(alice));
        HomaRouter router = new HomaRouter(fees, inst);

        otherToken.transfer(address(router), 5 ether);

        vm.prank(bob);
        vm.expectRevert("zero fee");
        router.route(otherToken, bob);

        router.routeNoFee(otherToken);

        assertEq(otherToken.balanceOf(address(router)), 0);
        assertEq(otherToken.balanceOf(alice), 5 ether);
        assertEq(otherToken.balanceOf(bob), 0);
    }

    function testRouteForUnknownTokenWithAccountId() public {
        HomaInstructions memory inst = HomaInstructions(stakingToken, liquidToken, alice32);
        HomaRouter router = new HomaRouter(fees, inst);

        otherToken.transfer(address(router), 5 ether);

        vm.prank(bob);
        vm.expectRevert("zero fee");
        router.route(otherToken, bob);

        router.routeNoFee(otherToken);

        assertEq(otherToken.balanceOf(address(router)), 0);
        assertEq(otherToken.balanceOfAccountId32(alice32), 5 ether);
        assertEq(otherToken.balanceOf(bob), 0);
    }
}
