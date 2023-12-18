import { EVM as EVM_ADDR } from '@acala-network/contracts/utils/Predeploy';
import { EVM__factory } from '@acala-network/contracts/typechain';
import { ethers } from 'hardhat';

import { ADDRESSES } from './consts';

const targetContract = ADDRESSES.ACALA.homaFactoryAddr;

async function main() {
  const [deployer] = await ethers.getSigners();
  const evm = EVM__factory.connect(EVM_ADDR, deployer);
  const developerStatus = evm.developerStatus(deployer.address);
  if (!developerStatus) {
    console.log('enabling developer status ...');
    await (await evm.developerEnable()).wait();
  }

  console.log(`publishing contract ${targetContract} ...`);
  await (await evm.publishContract(targetContract)).wait();

  console.log('done 🎉');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
