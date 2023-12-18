// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/AccountHelper.sol";
import "./MockToken.sol";
import "./MockHoma.sol";

contract HomaRouterTest is Test {
    MockToken public token;
    address public alice = address(0x01010101010101010101);
    bytes32 public bob = hex"0404040404040404040404040404040404040404040404040404040404040404";

    function setUp() public {
        token = new MockToken("Token", "TKN");
    }

    function fromEvmAddress(address addr) public pure returns (bytes32) {
        // convert addr to bytes32 with prefix of `evm:` and suffix of 8 bytes of zeros
        bytes32 prefix = bytes32(uint256(0x65766d3a00000000000000000000000000000000000000000000000000000000));
        bytes32 result = bytes32(uint256(uint160(addr))) << 64;
        return result | prefix;
    }

    function testToEvmAddress() public {
        assertEq(
            AccountHelper.toEvmAddress(bytes32(hex"65766d3aabababababababababababababababababababab0000000000000000")),
            address(0xABaBaBaBABabABabAbAbABAbABabababaBaBABaB)
        );
        assertEq(
            AccountHelper.toEvmAddress(bytes32(hex"65766d3aabababababababababababababababababababab0000000000000001")),
            address(0)
        );
         assertEq(
            AccountHelper.toEvmAddress(bytes32(hex"55766d3aabababababababababababababababababababab0000000000000000")),
            address(0)
        );
    }

    function testTransferToken() public {
        AccountHelper.transferToken(token, fromEvmAddress(alice), 1 ether);
        assertEq(token.balanceOf(alice), 1 ether);

        AccountHelper.transferToken(token, bob, 2 ether);
        assertEq(token.balanceOfAccountId32(bob), 2 ether);
    }
}
