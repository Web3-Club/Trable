// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { IToken } from "@acala-network/contracts/token/IToken.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";

library AccountHelper {
    using SafeTransferLib for ERC20;

    /**
     * @dev Converts a bytes32 value to an Ethereum address.
     * @param addr The bytes32 value to be converted.
     * @return The Ethereum address converted from the bytes32 value. Returns address(0) if the conversion fails.
     */
    function toEvmAddress(bytes32 addr) public pure returns (address) {
        // starts with `evm:`
        bytes32 prefix = hex"65766d3a00000000000000000000000000000000000000000000000000000000";
        bool checkPrefix = addr & prefix == prefix;
        if (!checkPrefix) {
            return address(0);
        }

        // ends with 8 bytes of zeros
        bytes32 suffix = hex"000000000000000000000000000000000000000000000000ffffffffffffffff";
        bool checkSuffix = addr & suffix == 0;
        if (!checkSuffix) {
            return address(0);
        }

        // convert addr[4..24] to address
        address result = address(bytes20(addr << 32));
        return result;
    }

    /**
     * @dev Transfers ERC20 tokens to a Substrate or EVM account. If the recipient is a Substrate account, the token must be a native token.
     * @param token The ERC20 token to transfer.
     * @param addr The address of the recipient account.
     * @param amount The amount of tokens to transfer.
     */
    function transferToken(ERC20 token, bytes32 addr, uint256 amount) public {
        address recipient = toEvmAddress(addr);
        if (recipient == address(0)) {
            // Substrate account
            // This will fail if token is not a native token.
            IToken(address(token)).transferToAccountId32(addr, amount);
        } else {
            // EVM account
            token.safeTransfer(recipient, amount);
        }
    }
}
