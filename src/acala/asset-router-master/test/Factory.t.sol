// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/XcmRouter.sol";
import "../src/FeeRegistry.sol";
import "../src/Factory.sol";
import "./MockToken.sol";
import "./MockXtokens.sol";

contract FactoryTest is Test {
    Factory factory;
    FeeRegistry public fees;
    MockToken public token1;
    MockToken public token2;
    MockToken public token3;
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        token1 = new MockToken("Token1", "TK1");
        token2 = new MockToken("Token2", "TK2");
        token3 = new MockToken("token3", "TK3");

        Fee[] memory feeArray = new Fee[](2);
        feeArray[0] = Fee(address(token1), 1 ether);
        feeArray[1] = Fee(address(token2), 2 ether);

        fees = new FeeRegistry(feeArray);
        factory = new Factory();

        MockXtokens mock = new MockXtokens();
        vm.etch(XTOKENS, address(mock).code);
    }

    function testDeployXcmRounter() public {
        XcmInstructions memory inst = XcmInstructions(abi.encodePacked(alice), hex"00");

        XcmRouter router = factory.deployXcmRouter(fees, inst);
        XcmRouter router2 = factory.deployXcmRouter(fees, inst);

        assertEq(address(router), address(router2));

        FeeRegistry fees2 = new FeeRegistry(new Fee[](0));

        XcmRouter router3 = factory.deployXcmRouter(fees2, inst);
        XcmRouter router4 = factory.deployXcmRouter(fees2, inst);

        assertEq(address(router3), address(router4));
        assertTrue(router != router3);

        XcmInstructions memory inst2 = XcmInstructions(abi.encodePacked(bob), hex"00");

        XcmRouter router5 = factory.deployXcmRouter(fees2, inst2);
        XcmRouter router6 = factory.deployXcmRouter(fees2, inst2);

        assertEq(address(router5), address(router6));
        assertTrue(router != router5);
        assertTrue(router3 != router5);
    }

    function testDeployXcmRouterAndRoute() public {
        XcmInstructions memory inst = XcmInstructions(abi.encodePacked(alice), hex"00");

        // deploy router, get address, and revert the router deployment
        // so we can get address without contract deployment
        uint256 snapId = vm.snapshot();
        XcmRouter router = factory.deployXcmRouter(fees, inst);
        vm.revertTo(snapId);

        token1.transfer(address(router), 5 ether);

        vm.prank(bob);
        factory.deployXcmRouterAndRoute(fees, inst, token1);

        assertEq(token1.balanceOf(address(router)), 0);
        assertEq(token1.balanceOf(alice), 4 ether); // amount - fee
        assertEq(token1.balanceOf(bob), 1 ether); // fee
    }

    function testDeployXcmRouterAndRouteNoFee() public {
        XcmInstructions memory inst = XcmInstructions(abi.encodePacked(alice), hex"00");

        // deploy router, get address, and revert the router deployment
        // so we can get address without contract deployment
        uint256 snapId = vm.snapshot();
        XcmRouter router = factory.deployXcmRouter(fees, inst);
        vm.revertTo(snapId);

        token1.transfer(address(router), 5 ether);

        vm.prank(bob);
        factory.deployXcmRouterAndRouteNoFee(fees, inst, token1);

        assertEq(token1.balanceOf(address(router)), 0);
        assertEq(token1.balanceOf(alice), 5 ether);
        assertEq(token1.balanceOf(bob), 0);
    }

    function testRouteMultiToken() public {
        XcmInstructions memory inst = XcmInstructions(abi.encodePacked(alice), hex"00");

        // deploy router, get address, and revert the router deployment
        // so we can get address without contract deployment
        uint256 snapId = vm.snapshot();
        XcmRouter router = factory.deployXcmRouter(fees, inst);
        vm.revertTo(snapId);

        token1.transfer(address(router), 5 ether);
        token2.transfer(address(router), 15 ether);
        token3.transfer(address(router), 25 ether);

        vm.startPrank(bob);
        factory.deployXcmRouterAndRoute(fees, inst, token1);
        factory.deployXcmRouterAndRoute(fees, inst, token2);
        factory.deployXcmRouterAndRouteNoFee(fees, inst, token3);
        vm.stopPrank();

        assertEq(token1.balanceOf(address(router)), 0);
        assertEq(token1.balanceOf(alice), 4 ether); // amount - fee
        assertEq(token1.balanceOf(bob), 1 ether); // fee

        assertEq(token2.balanceOf(address(router)), 0);
        assertEq(token2.balanceOf(alice), 13 ether); // amount - fee
        assertEq(token2.balanceOf(bob), 2 ether); // fee

        assertEq(token3.balanceOf(address(router)), 0);
        assertEq(token3.balanceOf(alice), 25 ether);
        assertEq(token3.balanceOf(bob), 0);
    }
}
