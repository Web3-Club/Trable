import { Bridge__factory } from '@certusone/wormhole-sdk/lib/cjs/ethers-contracts';
import { CONTRACTS, ChainName, tryNativeToHexString } from '@certusone/wormhole-sdk';
import { JsonRpcProvider } from '@ethersproject/providers';
import { expect } from 'chai';

import {
  CHAIN,
  CHAIN_NAME,
  CHAIN_NAME_TO_WORMHOLE_CHAIN_ID,
  ROUTER_CHAIN,
  ROUTER_TOKEN_INFO,
} from '../scripts/consts';
import { MockToken__factory } from '../dist/typechain-types';

const getProvider = (networkName: string) => {
  const ethRpc = ({
    [CHAIN.ACALA]: 'https://eth-rpc-acala.aca-api.network',
    [CHAIN.KARURA]: 'https://eth-rpc-karura.aca-api.network',
    [CHAIN.ETH]: 'https://ethereum.publicnode.com',
    [CHAIN.ARB]: 'https://endpoints.omniatech.io/v1/arbitrum/one/public',
    [CHAIN.BSC]: 'https://bsc.publicnode.com',
    [CHAIN.POLYGON]: 'https://polygon.llamarpc.com',
  })[networkName];
  if (!ethRpc) throw new Error(`unsupported network ${networkName}`);

  return new JsonRpcProvider(ethRpc);
};

const getWrappedAddr = async (
  dstNetwork: ROUTER_CHAIN,
  srcNetwork: string,
  srcTokenAddr: string,
) => {
  const dstTokenBridge = CONTRACTS.MAINNET[dstNetwork.toLowerCase() as ChainName].token_bridge;
  const srcWormholeChainId = CHAIN_NAME_TO_WORMHOLE_CHAIN_ID[srcNetwork as CHAIN_NAME];

  if (!dstTokenBridge || !srcWormholeChainId) {
    throw new Error('cannot find dstTokenBridge or srcWormholeChainId!');
  }

  const tokenBridge = Bridge__factory.connect(dstTokenBridge, getProvider(dstNetwork));
  return tokenBridge.wrappedAsset(
    srcWormholeChainId,
    Buffer.from(tryNativeToHexString(srcTokenAddr, srcWormholeChainId), 'hex'),
  );
};

describe('config', () => {
  it('source token and dst token match', async () => {
    for (const [tokenName, info] of Object.entries(ROUTER_TOKEN_INFO)) {
      process.stdout.write(`verifying ${tokenName} ...`);
      const srcToken = MockToken__factory.connect(info.originAddr, getProvider(info.originChain));

      const [
        symbol,
        decimals,
        wrappedAddrKarura,
        wrappedAddrAcala,
      ] = await Promise.all([
        srcToken.symbol(),
        srcToken.decimals(),
        getWrappedAddr(CHAIN.KARURA, info.originChain, info.originAddr),
        getWrappedAddr(CHAIN.ACALA, info.originChain, info.originAddr),
      ]);

      expect(symbol).to.equal(tokenName.toUpperCase());
      expect(decimals).to.equal(info.decimals);

      if (info.karuraAddr) {
        expect(wrappedAddrKarura).to.equal(info.karuraAddr);
      }

      if (info.acalaAddr) {
        expect(wrappedAddrAcala).to.equal(info.acalaAddr);
      }
      console.log('ok');
    }
  });
});
