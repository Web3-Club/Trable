
import { BigNumber } from 'ethers';
import { decodeAddress } from '@polkadot/util-crypto';
import { formatUnits, parseEther } from 'ethers/lib/utils';

// convert evm addr to bytes32 with prefix of `evm:` and suffix of 8 bytes of zeros
const EVM_PREFIX = '65766d3a';    // evm:
export const evmToAddr32 = (addr: string) => `0x${EVM_PREFIX}${addr.slice(2)}${'0'.repeat(16)}`;

export const nativeToAddr32 = (addr: string) => '0x' + Buffer.from(decodeAddress(addr)).toString('hex');

export const toHuman = (amount: BigNumber, decimals: number) => Number(formatUnits(amount, decimals));

export const almostEq = (a: BigNumber, b: BigNumber) => {
  const diff = a.sub(b).abs();
  return a.div(diff).gt(100);   // within 1% diff
};

export const ONE_ACA = parseEther('1');
