import { BigNumber, Contract } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { XTOKENS } from '@acala-network/contracts/utils/Predeploy';
import { Xtokens__factory } from '@acala-network/contracts/typechain';
import { ethers } from 'hardhat';
import { expect } from 'chai';

import { ADDRESSES } from '../scripts/consts';
import { Factory, XcmInstructionsStruct } from '../typechain-types/src/Factory';
import { FeeRegistry, MockToken } from '../typechain-types';

const {
  feeAddr,
  usdcAddr,
  factoryAddr,
} = ADDRESSES.KARURA_TESTNET;

describe('XcmRouter', () => {
  // fixed
  let usdc: MockToken;
  let fee: FeeRegistry;
  let xTokens: Contract;
  let factory: Factory;
  let decimals: number;
  let routingFee: BigNumber;
  let deployer: SignerWithAddress;
  let relayer: SignerWithAddress;

  // dynamic
  let routerAddr: string;
  let bal0: Awaited<ReturnType<typeof fetchTokenBalances>>;
  let bal1: Awaited<ReturnType<typeof fetchTokenBalances>>;
  let bal2: Awaited<ReturnType<typeof fetchTokenBalances>>;
  let xcmInstruction: XcmInstructionsStruct;

  const fetchTokenBalances = async () => {
    const [deployerBal, relayerBal, routerBal] = await Promise.all([
      usdc.balanceOf(deployer.address),
      usdc.balanceOf(relayer.address),
      usdc.balanceOf(routerAddr),
    ]);

    const userBal = BigNumber.from(0);    // TODO: fetch basilisk balance

    console.log({
      deployerBal: Number(ethers.utils.formatUnits(deployerBal, decimals)),
      relayerBal: Number(ethers.utils.formatUnits(relayerBal, decimals)),
      routerBal: Number(ethers.utils.formatUnits(routerBal, decimals)),
      userBal: userBal.toNumber(),
    });

    return {
      deployerBal,
      relayerBal,
      routerBal,
      userBal,
    };
  };

  before('setup', async () => {
    ([deployer, , relayer] = await ethers.getSigners());

    const Token = await ethers.getContractFactory('MockToken');
    const Fee = await ethers.getContractFactory('FeeRegistry');
    const Factory = await ethers.getContractFactory('Factory');

    usdc = Token.attach(usdcAddr);
    fee = Fee.attach(feeAddr);
    factory = Factory.attach(factoryAddr);
    xTokens = Xtokens__factory.connect(XTOKENS, deployer);
    decimals = await usdc.decimals();
    routingFee = await fee.getFee(usdc.address);

    console.log(`usdc address: ${usdc.address}`);
    console.log(`feeRegistry address: ${fee.address}`);
    console.log(`factory address: ${factory.address}`);
    console.log(`xTokens address: ${xTokens.address}`);
    console.log(`token decimals: ${decimals}`);
    console.log(`router fee: ${Number(ethers.utils.formatUnits(routingFee, decimals))}`);
  });

  it('predict router address', async () => {
    /* -----                      ## hardcoded dest for now ## TODO: use api to encode
    const dest = {
      V3: {
        parents: 1,
        interior: {
          X2: [
            { parachain: 2090 },
            { accountId32: 'rPWzRkpPjuceq6Po91sfHLZJ9wo6wzx4PAdjUH91ckv81nv' },
          ],
        },
      },
    };

    https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fkarura-testnet.aca-staging.network%2Frpc%2Fkarura%2Fws#/extrinsics/decode/0xe1028400d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d01545773f0488bad93ad9750930809f02c194b3189daa4f5024c03879e24cf19669e76e5acdd38e81959ea94e3aa94695e7c6ad393621b9308b353be9db1ed2687f400310300360002e5ba1e8e6bbbdc8bbc72a58d68e74b13fcd6e4c7e803000000000000000000000000000003010200a9200100d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d00
                                                                                                                                                                                                                                                                          ----- */
    const dest = '0x03010200a9200100d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d';
    const weight = '0x00';    // unlimited

    xcmInstruction = { dest, weight };
    routerAddr = await factory.callStatic.deployXcmRouter(fee.address, xcmInstruction);
    console.log({ predictedRouterAddr: routerAddr });
  });

  it('init state', async () => {
    console.log('\n-------------------- init state --------------------');
    bal0 = await fetchTokenBalances();

    // router shouldn't exist
    const routerCode = await relayer.provider!.getCode(routerAddr);
    expect(routerCode).to.eq('0x');
  });

  it('after wormhole withdraw to router', async () => {
    console.log('\n-------------------- after wormhole withdraw to router --------------------');
    const ROUTE_AMOUNT = 0.01;
    const routeAmount = ethers.utils.parseUnits(String(ROUTE_AMOUNT), decimals);
    await (await usdc.connect(deployer).transfer(
      routerAddr,
      routeAmount,
    )).wait();

    bal1 = await fetchTokenBalances();
    expect(bal1.userBal).to.eq(bal0.userBal);
    expect(bal1.relayerBal).to.eq(bal0.relayerBal);
    expect(bal1.routerBal).to.eq(routeAmount);
  });

  it('after router xcm to user', async () => {
    console.log('\n-------------------- after router xcm to user --------------------');
    const deployAndRoute = factory.connect(relayer).deployXcmRouterAndRoute(
      fee.address,
      xcmInstruction,
      usdc.address,
    );

    const XcmRouter = await ethers.getContractFactory('XcmRouter');
    const xcmRouter = XcmRouter.attach(routerAddr);

    await expect(deployAndRoute)
      .to.emit(xcmRouter, 'RouterCreated').withArgs(routerAddr)
      .to.emit(xTokens, 'TransferredMultiAssets')
      .to.emit(xcmRouter, 'RouterDestroyed').withArgs(routerAddr);

    bal2 = await fetchTokenBalances();
    // expect(bal2.userBal).to.eq(bal0.userBal.add(routeAmount));   // TODO: uncomment me when basilisk is ready
    expect(bal2.relayerBal).to.eq(bal0.relayerBal.add(routingFee));
    expect(bal2.routerBal).to.eq(0);

    // router should be destroyed
    const routerCode = await relayer.provider!.getCode(routerAddr);
    expect(routerCode).to.eq('0x');
  });
});
