import { BigNumber } from 'ethers';
import { DOT, LDOT } from '@acala-network/contracts/utils/AcalaTokens';
import { EVMAccounts__factory, IHoma__factory } from '@acala-network/contracts/typechain';
import { EVM_ACCOUNTS, HOMA } from '@acala-network/contracts/utils/Predeploy';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { ethers } from 'hardhat';
import { expect } from 'chai';
import { formatEther, parseEther, parseUnits } from 'ethers/lib/utils';

import { ADDRESSES } from '../scripts/consts';
import { FeeRegistry, HomaFactory, HomaRouter__factory, MockToken } from '../typechain-types';
import { ONE_ACA, almostEq, evmToAddr32, nativeToAddr32, toHuman } from '../scripts/utils';

const { homaFactoryAddr, feeAddr, accountHelperAddr } = ADDRESSES.ACALA;

const ALICE = '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY';

describe('Homa Router', () => {
  // fixed
  let dot: MockToken;
  let ldot: MockToken;
  let pepe: MockToken;
  let fee: FeeRegistry;
  let factory: HomaFactory;
  let decimals: number;
  let routingFee: BigNumber;
  let stakeAmount: BigNumber;
  let user: SignerWithAddress;
  let relayer: SignerWithAddress;
  let userNativeAddr32: string;
  let userEvmAddr32: string;

  // dynamic
  let routerAddr: string;
  let bal0: Awaited<ReturnType<typeof fetchTokenBalances>>;
  let bal1: Awaited<ReturnType<typeof fetchTokenBalances>>;

  const fetchTokenBalances = async () => {
    const [
      userBalDot,
      relayerBalDot,
      routerBalDot,
      userBalLdot,
      relayerBalLdot,
      routerBalLdot,
    ] = await Promise.all([
      dot.balanceOf(user.address),
      dot.balanceOf(relayer.address),
      dot.balanceOf(routerAddr),
      ldot.balanceOf(user.address),
      ldot.balanceOf(relayer.address),
      ldot.balanceOf(routerAddr),
    ]);

    console.log({
      userBalDot: toHuman(userBalDot, decimals),
      relayerBalDot: toHuman(relayerBalDot, decimals),
      routerBalDot: toHuman(routerBalDot, decimals),
      userBalLdot: toHuman(userBalLdot, decimals),
      relayerBalLdot: toHuman(relayerBalLdot, decimals),
      routerBalLdot: toHuman(routerBalLdot, decimals),
    });

    return {
      userBalDot,
      relayerBalDot,
      routerBalDot,
      userBalLdot,
      relayerBalLdot,
      routerBalLdot,
    };
  };

  before('setup', async () => {
    ([user, relayer] = await ethers.getSigners());

    const evmAccounts = EVMAccounts__factory.connect(EVM_ACCOUNTS, user);
    const Token = await ethers.getContractFactory('MockToken');
    const Fee = await ethers.getContractFactory('FeeRegistry');
    const Factory = await ethers.getContractFactory('HomaFactory', {
      libraries: {
        AccountHelper: accountHelperAddr,
      },
    });

    dot = Token.attach(DOT);
    ldot = Token.attach(LDOT);
    fee = Fee.attach(feeAddr);
    factory = Factory.attach(homaFactoryAddr).connect(relayer);
    decimals = await dot.decimals();
    routingFee = await fee.getFee(dot.address);
    stakeAmount = parseUnits('101', decimals);
    userNativeAddr32 = await evmAccounts.getAccountId(user.address);
    userEvmAddr32 = evmToAddr32(user.address);

    // user should be bound to alice
    expect(userNativeAddr32).to.eq(nativeToAddr32(ALICE));

    pepe = await Token.deploy('pepe dog', 'PEPEDOG');
    await pepe.deployed();

    console.log(`dot address: ${dot.address}`);
    console.log(`feeRegistry address: ${fee.address}`);
    console.log(`factory address: ${factory.address}`);
    console.log(`pepe address: ${pepe.address}`);
    console.log(`user address: ${user.address}`);
    console.log(`user address32: ${userNativeAddr32}`);
    console.log(`relayer address: ${relayer.address}`);
    console.log(`token decimals: ${decimals}`);
    console.log(`router fee: ${Number(ethers.utils.formatUnits(routingFee, decimals))}`);

    // make sure user and relayer have enough balance to send txs
    const [userBal, relayerBal] = await Promise.all([
      user.getBalance(),
      relayer.getBalance(),
    ]);

    expect(userBal).to.be.gt(ONE_ACA.mul(100));
    if (relayerBal.lt(ONE_ACA.mul(30))) {
      await (await user.sendTransaction({
        to: relayer.address,
        value: ONE_ACA.mul(30),
      })).wait();
    }
  });

  const testHomaRouter = async (addr32: string) => {
    routerAddr = await factory.callStatic.deployHomaRouter(fee.address, addr32);
    console.log({ predictedRouterAddr: routerAddr });

    console.log('\n-------------------- init state --------------------');
    bal0 = await fetchTokenBalances();
    expect(bal0.userBalDot).to.gte(stakeAmount);

    // router shouldn't exist
    let routerCode = await relayer.provider!.getCode(routerAddr);
    // expect(routerCode).to.eq('0x');

    console.log('\n-------------------- after user deposited to router --------------------');

    await (await dot.connect(user).transfer(
      routerAddr,
      stakeAmount,
    )).wait();

    await fetchTokenBalances();

    console.log('\n-------------------- after router routed and staked --------------------');
    const deployAndRoute = await factory.deployHomaRouterAndRoute(
      fee.address,
      addr32,
      DOT,
    );
    await deployAndRoute.wait();

    bal1 = await fetchTokenBalances();

    // router should have no remaining balance
    expect(bal1.routerBalDot).to.eq(0);
    expect(bal1.routerBalLdot).to.eq(0);

    // user should receive LDOT
    const homa = IHoma__factory.connect(HOMA, user);
    const exchangeRate = parseEther((1 / Number(formatEther(await homa.getExchangeRate()))).toString());    // 10{18} DOT => ? LDOT
    const expectedLdot = stakeAmount.sub(routingFee).mul(exchangeRate).div(ONE_ACA);
    const ldotReceived = bal1.userBalLdot.sub(bal0.userBalLdot);

    expect(almostEq(expectedLdot, ldotReceived)).to.be.true;
    expect(bal0.userBalDot.sub(bal1.userBalDot)).to.eq(stakeAmount);

    // relayer should receive fee
    expect(bal1.relayerBalDot.sub(bal0.relayerBalDot)).to.eq(routingFee);

    // router should be destroyed
    routerCode = await relayer.provider!.getCode(routerAddr);
    expect(routerCode).to.eq('0x');
  };

  it('route to evm address', async () => {
    await testHomaRouter(userEvmAddr32);
  });

  it('route to substrate address', async () => {
    await testHomaRouter(userNativeAddr32);
  });

  const testHomaRouterRefund = async (addr32: string, token: MockToken, needRescue = false) => {
    const tokenDecimals = await token.decimals();

    routerAddr = await factory.callStatic.deployHomaRouter(fee.address, addr32);
    console.log({ predictedRouterAddr: routerAddr });

    console.log('\n-------------------- init state --------------------');
    const tokenBal0= await token.balanceOf(user.address);
    console.log({ tokenBal0: toHuman(tokenBal0, tokenDecimals) });

    // router shouldn't exist
    let routerCode = await relayer.provider!.getCode(routerAddr);
    // expect(routerCode).to.eq('0x');

    console.log('\n-------------------- after user deposited to router --------------------');
    const randTokenAmount = parseUnits(String(Math.floor(Math.random() * 100) + 1), tokenDecimals);
    expect(tokenBal0).to.gte(randTokenAmount, 'user does not have enough token to transfer!');

    await (await token.connect(user).transfer(
      routerAddr,
      randTokenAmount,
    )).wait();

    const tokenBal1 = await token.balanceOf(user.address);
    let tokenBalRouter = await token.balanceOf(routerAddr);
    console.log({
      tokenBal1: toHuman(tokenBal1, tokenDecimals),
      tokenBalRouter: toHuman(tokenBalRouter, tokenDecimals),
    });

    console.log('\n-------------------- after router returned token --------------------');
    if (needRescue) {
      // cannot tranfer non-native erc20 to substrate addr
      await expect(factory.deployHomaRouterAndRouteNoFee(
        fee.address,
        addr32,
        token.address,
      )).to.be.reverted;

      // deploy router and rescue
      console.log('deploying homa router ...');
      const receipt = await (await factory.deployHomaRouter(fee.address, addr32)).wait();
      const routerAddr_ = receipt.logs[0]?.topics?.[1];
      console.log('deployed!', { routerAddr_ });

      const router = HomaRouter__factory.connect(routerAddr, relayer);

      await expect(router.rescure(token.address)).to.be.revertedWith('HomaRouter: not recipient');    // relayer is not the recipient

      await (await router.connect(user).rescure(token.address)).wait();   // user is the recipient
    } else {
      const deployAndRoute = await factory.deployHomaRouterAndRouteNoFee(
        fee.address,
        addr32,
        token.address,
      );
      await deployAndRoute.wait();
    }

    const tokenBal2 = await token.balanceOf(user.address);
    tokenBalRouter = await token.balanceOf(routerAddr);
    console.log({
      tokenBal2: toHuman(tokenBal2, tokenDecimals),
      tokenBalRouter: toHuman(tokenBalRouter, tokenDecimals),
    });

    // user should receive full token refund
    expect(tokenBal0).to.eq(tokenBal2);

    if (!needRescue) {
      routerCode = await relayer.provider!.getCode(routerAddr);
      expect(routerCode).to.eq('0x');
    }
  };

  describe('able to refund unsupported token', () => {
    it('native token to evm addr', async () => {
      await testHomaRouterRefund(userEvmAddr32, ldot.connect(user));
    });

    it('native token to substrate addr', async () => {
      await testHomaRouterRefund(userNativeAddr32, ldot.connect(user));
    });

    it('erc20 to evm addr', async () => {
      await testHomaRouterRefund(userEvmAddr32, pepe);
    });

    it('erc20 to substrate addr', async () => {
      const needRescue = true;      // only non-native erc20 => substrate addr needs rescue
      await testHomaRouterRefund(userNativeAddr32, pepe, needRescue);
    });
  });
});
